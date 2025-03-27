import 'dart:convert';

import 'package:http_cache_core/http_cache_core.dart';
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

    final encrypted = await cipher.encryptContent(data);
    expect(encrypted, equals('terces peek ot gnihtemoS'.codeUnits));

    final decrypted = await cipher.decryptContent(encrypted);
    expect(decrypted, equals(data));
  });

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

    final encrypted = await cipher.encryptContent(null);
    expect(encrypted, isNull);

    final decrypted = await cipher.decryptContent(null);
    expect(decrypted, isNull);
  });
}
