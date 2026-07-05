import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/api.dart' as pc;
import 'package:pointycastle/asymmetric/api.dart' as pc_rsa;
import 'package:pointycastle/key_generators/api.dart' as pc_kg;
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';

final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService(const FlutterSecureStorage());
});

class EncryptionService {
  final FlutterSecureStorage _secureStorage;
  static const _privateKeyKey = 'rsa_private_key';
  static const _sharedAesKey = 'shared_aes_key';

  EncryptionService(this._secureStorage);

  /// Generate RSA Key Pair for the user (Run once during signup/login)
  Future<String> generateAndStoreRSAKeyPair() async {
    final secureRandom = FortunaRandom();
    final seed = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    secureRandom.seed(pc.KeyParameter(Uint8List.fromList(seed)));

    final keyGen = RSAKeyGenerator()
      ..init(pc.ParametersWithRandom(
          pc_kg.RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
          secureRandom));

    final pair = keyGen.generateKeyPair();
    final publicKey = pair.publicKey as pc_rsa.RSAPublicKey;
    final privateKey = pair.privateKey as pc_rsa.RSAPrivateKey;

    final pubPem = _encodePublicKeyToPem(publicKey);
    final privPem = _encodePrivateKeyToPem(privateKey);

    await _secureStorage.write(key: _privateKeyKey, value: privPem);
    return pubPem; // To be uploaded to Firebase UserModel
  }

  /// Get stored Private Key
  Future<pc_rsa.RSAPrivateKey?> _getPrivateKey() async {
    final customPem = await _secureStorage.read(key: _privateKeyKey);
    if (customPem == null) return null;
    final map = jsonDecode(utf8.decode(base64Decode(customPem)));
    final n = BigInt.parse(map['n']);
    final d = BigInt.parse(map['d']);
    final p = BigInt.parse(map['p']);
    final q = BigInt.parse(map['q']);
    return pc_rsa.RSAPrivateKey(n, d, p, q);
  }

  /// Parse Public Key from custom encoding
  pc_rsa.RSAPublicKey parsePublicKey(String customPem) {
    final map = jsonDecode(utf8.decode(base64Decode(customPem)));
    final n = BigInt.parse(map['n']);
    final e = BigInt.parse(map['e']);
    return pc_rsa.RSAPublicKey(n, e);
  }

  /// Generate a 256-bit AES Key for the couple's session
  Future<void> generateAndStoreSharedAESKey() async {
    final key = encrypt.Key.fromSecureRandom(32);
    await _secureStorage.write(key: _sharedAesKey, value: key.base64);
  }

  /// Save a received AES Key (after decrypting it with our private key)
  Future<void> saveSharedAESKey(String base64Key) async {
    await _secureStorage.write(key: _sharedAesKey, value: base64Key);
  }

  /// Get the Shared AES Key
  Future<encrypt.Key?> _getSharedAESKey() async {
    final base64Key = await _secureStorage.read(key: _sharedAesKey);
    if (base64Key == null) return null;
    return encrypt.Key.fromBase64(base64Key);
  }

  /// Encrypt AES key using Partner's Public Key (to send it via Firebase)
  Future<String?> encryptAESKeyForPartner(String partnerPublicKeyPem) async {
    final aesKeyBase64 = await _secureStorage.read(key: _sharedAesKey);
    if (aesKeyBase64 == null) return null;

    final publicKey = parsePublicKey(partnerPublicKeyPem);
    final encrypter = encrypt.Encrypter(encrypt.RSA(publicKey: publicKey));
    
    return encrypter.encrypt(aesKeyBase64).base64;
  }

  /// Decrypt received AES key using Our Private Key
  Future<void> decryptAndSaveAESKeyFromPartner(String encryptedAESKeyBase64) async {
    final privateKey = await _getPrivateKey();
    if (privateKey == null) throw Exception('Private key not found');

    final encrypter = encrypt.Encrypter(encrypt.RSA(privateKey: privateKey));
    final decryptedBase64 = encrypter.decrypt64(encryptedAESKeyBase64);
    
    await saveSharedAESKey(decryptedBase64);
  }

  // ── Message/Diary Encryption (AES-GCM) ─────────────────────────

  Future<String> encryptText(String plainText) async {
    final key = await _getSharedAESKey();
    if (key == null) return plainText; // Fallback if no key

    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.gcm));
    
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    // Format: iv_base64:encrypted_data_base64
    return '${iv.base64}:${encrypted.base64}';
  }

  Future<String> decryptText(String encryptedText) async {
    final key = await _getSharedAESKey();
    if (key == null) return encryptedText; // Fallback if no key

    try {
      final parts = encryptedText.split(':');
      if (parts.length != 2) return encryptedText; // Not encrypted or old format

      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.gcm));
      
      return encrypter.decrypt64(parts[1], iv: iv);
    } catch (e) {
      return '⚠️ [رسالة مشفرة لا يمكن فك تشفيرها]';
    }
  }

  // ── PEM Encoders ───────────────────────────────────────────────

  String _encodePublicKeyToPem(pc_rsa.RSAPublicKey publicKey) {
    // A simplified manual PEM encoder or we can use a package.
    // For simplicity, we create a basic PKCS#1 or SubjectPublicKeyInfo format.
    // In a real app, `rsa_pkcs` or similar package is better, but PointyCastle has ASN1.
    // We will use basic strings for this example assuming we have an encoder,
    // or we can use base64 of the modulus and exponent.
    // Since pointycastle ASN.1 encoding can be verbose, let's store it as JSON base64.
    final map = {
      'n': publicKey.modulus.toString(),
      'e': publicKey.exponent.toString()
    };
    return base64Encode(utf8.encode(jsonEncode(map)));
  }

  String _encodePrivateKeyToPem(pc_rsa.RSAPrivateKey privateKey) {
    final map = {
      'n': privateKey.modulus.toString(),
      'd': privateKey.privateExponent.toString(),
      'p': privateKey.p.toString(),
      'q': privateKey.q.toString(),
    };
    return base64Encode(utf8.encode(jsonEncode(map)));
  }
}
