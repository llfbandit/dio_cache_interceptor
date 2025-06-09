# http_cache_mmkv_store

A Dart package that provides a caching store for Dio HTTP requests using MMKV for fast and persistent storage. This package offers an efficient way to cache responses, with support for encryption and multiple storage spaces.

Features
	•	Efficient Caching: Uses MMKV for quick and reliable storage of HTTP responses.
	•	Encryption Support: Optionally secure your cache data using a custom encryption key.
	•	Customizable Storage: Define a custom root directory and unique instance identifiers for different caching needs.
	•	Easy Initialization: Provides convenient methods to initialize MMKV before use.
	•	Testability: Supports dependency injection by allowing the use of a custom MMKV instance.

Installation

Add the following dependencies to your pubspec.yaml:

```yaml
dependencies:
  http_cache_mmkv_store: ^<latest_version>
```

Then, run:

```bash
flutter pub get
```

### Getting Started

Before using the cache store, MMKV must be initialized. You can do this in one of two ways:

1. Initialize MMKV Directly

```dart
import 'package:mmkv/mmkv.dart';

void main() async {
  // Initialize MMKV and obtain the root directory.
  final rootDir = await MMKV.initialize();
  print('MMKV initialized with rootDir: $rootDir');

  // Continue with your app initialization.
  runApp(MyApp());
}
```

2. Initialize Using MMKVCacheStore Convenience Method

```dart
import 'package:http_cache_mmkv_store/http_cache_mmkv_store.dart';

void main() async {
  // Initialize MMKV through MMKVCacheStore.
  final rootDir = await MMKVCacheStore.initialise();
  print('MMKVCacheStore initialized with rootDir: $rootDir');

  // Use cacheStore with your Dio cache interceptor.
  runApp(MyApp());
}
```

### Testing

For testing purposes, MMKVCacheStore provides a constructor that accepts a pre-initialized MMKV instance:

```dart
    MMKVCacheStore.fromMMKV(mockMMKV);
```

### Usage with Dio

Integrate the cache store with your Dio client by setting up the DioCacheInterceptor with the MMKVCacheStore. This setup will help you manage cached responses efficiently.

```dart
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:http_cache_mmkv_store/http_cache_mmkv_store.dart';

void setupDio() async {
  // Initialize MMKV
  final rootDir = await MMKVCacheStore.initialise();
  
  // Create cache store
  final cacheStore = MMKVCacheStore();

  // Create cache options
  final cacheOptions = CacheOptions(
    store: cacheStore,
    policy: CachePolicy.request, // Customize cache policy as needed.
  );

  // Create Dio instance and add cache interceptor
  final dio = Dio()
    ..interceptors.add(DioCacheInterceptor(options: cacheOptions));

  // Use Dio for your API calls.
}
```