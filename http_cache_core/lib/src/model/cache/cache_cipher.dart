/// Encrypt content/headers method.
typedef Encrypt = Future<List<int>> Function(List<int> bytes);

/// Decrypt content/headers method.
typedef Decrypt = Future<List<int>> Function(List<int> bytes);

class CacheCipher {
  /// Optional method to decrypt cache content
  final Decrypt decrypt;

  /// Optional method to encrypt cache content
  final Encrypt encrypt;

  const CacheCipher({required this.decrypt, required this.encrypt});

  Future<List<int>?> decryptContent(List<int>? bytes) {
    if (bytes != null) {
      return decrypt(bytes);
    }
    return Future.value(bytes);
  }

  Future<List<int>?> encryptContent(List<int>? bytes) {
    if (bytes != null) {
      return encrypt(bytes);
    }
    return Future.value(bytes);
  }
}
