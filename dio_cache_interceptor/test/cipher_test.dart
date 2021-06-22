import 'dart:convert';

import 'package:dio_cache_interceptor/src/model/cache_cipher.dart';
import 'package:test/test.dart';

void main() {
  test('Encrypt/decrypt', () async {
    // Encrypt => Upside down all content
    // Decrypt => do the same to get back our content
    // So powerful !
    final cipher = CacheCipher(
      decrypt: (bytes) {
        return Future.value(bytes.reversed.toList(growable: false));
      },
      encrypt: (bytes) async {
        return Future.value(bytes.reversed.toList(growable: false));
      },
    );

    final data = utf8.encode('Something to keep secret');

    final encrypted = await cipher.encrypt(data);
    expect(encrypted, equals('terces peek ot gnihtemoS'.codeUnits));

    final decrypted = await cipher.decrypt(encrypted);
    expect(decrypted, equals(data));
  });
}
