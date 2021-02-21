import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:path_provider/path_provider.dart';

import './common_store_test.dart' as common;

void main() async {
  final store = FileCacheStore((await getApplicationDocumentsDirectory())!);
  common.testGroup('Common File store tests', store);
}
