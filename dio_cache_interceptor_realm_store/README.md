# dio_cache_interceptor_realm_store

Realm cache store implementation.

## Tests

In order to run unit tests locally on your machine, install the Realm library on your host machine:

```bash
dart run realm_dart install
```

## Troubleshoot

If you are using Realm version prior to 3.1.0, you may encounter this error message:

```
Error: The argument type 'ByteBuffer' can't be assigned to the parameter type 'Uint8List'
```

This is because 2 of the packages that Realm depends on `sane_uuid` and `ejson` introduced breaking changes in their new versions that weren't resolved until Realm 3.1.0.

To workaround, add this to your `pubspec.yaml` dependency_overrides:

```yaml
dependency_overrides:
  sane_uuid: 1.0.0-alpha.5
  ejson: 0.3.0
```

See also:

- https://pub.dev/packages/realm_dart/changelog#310-2024-06-25
- https://github.com/realm/realm-dart/issues/1729
