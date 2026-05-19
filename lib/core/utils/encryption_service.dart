import 'package:encrypt/encrypt.dart';

/// AES-256-CBC encryption utility for sensitive Firestore data.
///
/// Encrypts fields like student_name, purpose, faculty_name before
/// writing to Firestore, and decrypts when reading.
///
/// In production, store the key in a secure vault (e.g. Cloud Secret Manager).
/// For this app, we use a compile-time constant.
class EncryptionService {
  // 32-byte key for AES-256
  static const _keyStr = 'FacAppt2026SecureKey32BytesLong!';
  static final _key = Key.fromUtf8(_keyStr);
  static final _iv = IV.fromLength(16);
  static final _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));

  /// Encrypt a plaintext string. Returns base64-encoded ciphertext.
  static String encrypt(String plainText) {
    if (plainText.isEmpty) return plainText;
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (_) {
      return plainText;
    }
  }

  /// Decrypt a base64-encoded ciphertext. Returns plaintext.
  static String decrypt(String cipherText) {
    if (cipherText.isEmpty) return cipherText;
    try {
      final decrypted = _encrypter.decrypt64(cipherText, iv: _iv);
      return decrypted;
    } catch (_) {
      // If decryption fails, assume it's already plaintext (legacy data)
      return cipherText;
    }
  }

  /// Encrypt a map's sensitive fields before writing to Firestore.
  /// Only encrypts known sensitive keys; leaves others untouched.
  static Map<String, dynamic> encryptFields(
    Map<String, dynamic> data, {
    List<String> fields = const [
      'student_name',
      'faculty_name',
      'purpose',
      'full_name',
      'email',
      'phone',
      'location_or_link',
    ],
  }) {
    final result = Map<String, dynamic>.from(data);
    for (final field in fields) {
      if (result.containsKey(field) && result[field] is String) {
        result[field] = encrypt(result[field] as String);
      }
    }
    return result;
  }

  /// Decrypt a map's sensitive fields after reading from Firestore.
  static Map<String, dynamic> decryptFields(
    Map<String, dynamic> data, {
    List<String> fields = const [
      'student_name',
      'faculty_name',
      'purpose',
      'full_name',
      'email',
      'phone',
      'location_or_link',
    ],
  }) {
    final result = Map<String, dynamic>.from(data);
    for (final field in fields) {
      if (result.containsKey(field) && result[field] is String) {
        result[field] = decrypt(result[field] as String);
      }
    }
    return result;
  }
}
