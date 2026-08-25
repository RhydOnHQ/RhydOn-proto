# RhydOn — Contracts

Protobuf definitions for the RhydOn platform. Own Go module, tagged
independently (v0.x.0). Consumed by github.com/rhydonhq/rhydon.

## Layout
- `rhydon/<service>/v1/*.proto` — one directory per service, versioned
- `rhydon/common/v1/types.proto` — shared types (Coordinate, Money, paging)
- `gen/go/` — generated code, COMMITTED. Never hand-edit.

## Hard rules
- Fields are ADD-ONLY. Never renumber, retype, rename, or delete.
- Retire fields with `reserved`, never by deletion.
- Breaking changes require a new package version (`v2/`), not an edit to `v1`.
- `buf breaking` runs in CI against main and will fail the build.

## Workflow after editing a .proto
```
make format && make lint && make breaking && make generate
```
Commit `.proto` and `gen/` together — CI verifies they match.

## Conventions
- Enums: prefixed, always `*_UNSPECIFIED = 0` first.
- Timestamps: `google.protobuf.Timestamp`, never int64.
- Money: `common.v1.Money` (minor units + currency), never a float.
- Coordinates: `common.v1.Coordinate`, never loose doubles.

## Related
- Consumer: github.com/rhydonhq/rhydon — sibling checkout at ../rhydon
  when using go.work.
- See CONTRIBUTING.md for the full change and release process.
