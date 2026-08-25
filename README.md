# proto

gRPC contracts for [RhydOn](https://github.com/RhydOnHQ) — the wire format
between every service on the platform.

Independently versioned. Consumers pin a tag:

```bash
go get github.com/rhydonhq/proto@v0.1.0
```

## Contents

| Package | Service | Purpose |
|---|---|---|
| `rhydon.common.v1` | — | Coordinate, Money, pagination |
| `rhydon.auth.v1` | auth | Signup, login, token rotation, JWKS |
| `rhydon.location.v1` | location | Streaming position updates, nearby search |
| `rhydon.trip.v1` | trip | Lifecycle state machine, fares, history |
| `rhydon.dispatch.v1` | dispatch | Assignment, offer streaming, responses |

## Usage

```bash
make help       # list targets
make lint       # lint protos
make format     # format in place
make generate   # regenerate gen/go
make breaking   # diff against main for breaking changes
make check      # what CI runs
```

Requires [buf](https://buf.build/docs/installation).

## Compatibility

Fields are add-only. Field numbers are the wire format — renumbering
produces silently wrong data in consumers, not a compile error. CI
enforces this with `buf breaking`.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the change and release process.
