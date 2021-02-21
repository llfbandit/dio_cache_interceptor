abstract class Cipher {
  Future<List<int>> encrypt(List<int> bytes);
  Future<List<int>> decrypt(List<int> bytes);
}
