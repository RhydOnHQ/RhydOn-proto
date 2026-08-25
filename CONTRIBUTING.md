# Contributing to `proto`

This repo defines the wire contract between every RhydOn service. A mistake here doesn't break one service — it breaks whichever consumer happens to deploy next, at a time unrelated to when the mistake was made. Hence the rules.

---

## The compatibility rules

### Fields are add-only

| Allowed | Forbidden |
|---|---|
| Add a new field with a fresh number | Change an existing field's number |
| Add a new enum value | Change an existing field's type |
| Add a new message | Rename a field *(breaks JSON/gRPC-gateway)* |
| Add a new RPC | Remove a field |
| Deprecate a field | Reuse a retired field number |

Field numbers are the wire format. A consumer compiled against `v0.3.0` decodes field `4` as whatever `v0.3.0` said field `4` was. Renumbering doesn't produce an error — it produces **silently wrong data**, which is considerably worse.

### Retiring a field

Never delete outright. Reserve it, so nobody can reuse the number:

```protobuf
message Trip {
  reserved 13, 14;
  reserved "cancelled_by", "cancellation_reason";

  string trip_id = 1;
  // ...
}
```

To soft-deprecate first:

```protobuf
string vehicle_class = 15 [deprecated = true];
```

### Breaking changes require a new package version

If you genuinely must break compatibility, create `rhydon/trip/v2/` alongside `v1`. Both ship. Consumers migrate on their own schedule, and `v1` is deleted only once nothing imports it.

Do not break `v1` in place. `buf breaking` will stop you in CI anyway.

---

## Making a change

```bash
# 1. Edit the .proto
vim rhydon/trip/v1/trip.proto

# 2. Format and lint
make format
make lint

# 3. Check you haven't broken anything
make breaking

# 4. Regenerate — gen/ IS committed
make generate

# 5. Commit proto AND generated code together
git add rhydon/ gen/
git commit -m "feat(trip): add vehicle_class to Trip"
```

CI verifies that `gen/` matches the `.proto` files. If you edit a proto without regenerating, the build fails.

---

## Releasing

Consumers pin a version, so a change isn't real until it's tagged.

```bash
git tag v0.4.0
git push origin v0.4.0
```

Then in each consumer:

```bash
go get github.com/rhydonhq/proto@v0.4.0
```

**Versioning while pre-1.0:**

| Change | Bump |
|---|---|
| New field, new RPC, new message | minor — `v0.3.0` → `v0.4.0` |
| Comment or doc change only | patch — `v0.3.0` → `v0.3.1` |
| New package version (`v2/`) | minor, and note it in the release |

Once the platform is stable, move to real semver: additive changes become minor, and a breaking change would require `v1` → `v2` of the **Go module path** (`github.com/rhydonhq/proto/v2`), which is deliberately painful. That pain is the point.

---

## Style

- **Package path mirrors directory:** `rhydon/trip/v1/trip.proto` declares `package rhydon.trip.v1`.
- **Enums are prefixed and zero-valued:** every enum starts with `FOO_UNSPECIFIED = 0`. Proto3 can't distinguish an unset field from a zero value, so `UNSPECIFIED` is the difference between "the client didn't say" and "the client said the first option."
- **Timestamps:** `google.protobuf.Timestamp`, never a bare int64. Nobody remembers whether your int64 was seconds or milliseconds.
- **Money:** `common.v1.Money`, never a float. Floating-point currency is a bug with a delay fuse.
- **Coordinates:** `common.v1.Coordinate`, never two loose doubles — it eliminates lat/lng ordering mistakes at every call site.
- **Comment the *why*.** The field name says what it is. The comment should say why it exists, what invariant it carries, or what breaks if you get it wrong.

---

## What not to put here

- **Validation logic.** Contracts describe shape, not business rules. "Fare must be positive" belongs in the service.
- **Internal-only messages.** If nothing crosses a service boundary with it, it's a Go struct in the owning service.
- **Database models.** The wire format and the storage schema will diverge, and coupling them means every migration becomes a contract change.
