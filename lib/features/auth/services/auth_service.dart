import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/digests/sha256.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // الحصول على حالة التوثيق الحالية (Stream)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // الحصول على المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  // تسجيل الدخول
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Save offline credentials cache on successful login
      if (credential.user != null) {
        await _saveOfflineCache(email, password, credential.user!.uid);
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        // Handle offline login validation fallback
        final offlineUid = await _verifyOfflineCredentials(email, password);
        if (offlineUid != null) {
          // Return a mock user credential to bypass auth guard without internet
          return _createMockUserCredential(offlineUid, email);
        }
      }
      throw _handleAuthException(e);
    } catch (e) {
      // Check if it's a general exception due to no internet, and try offline login
      final offlineUid = await _verifyOfflineCredentials(email, password);
      if (offlineUid != null) {
        return _createMockUserCredential(offlineUid, email);
      }
      throw Exception('حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.');
    }
  }

  // إنشاء حساب جديد
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await _saveOfflineCache(email, password, credential.user!.uid);
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('حدث خطأ أثناء إنشاء الحساب.');
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    // Clear the active session but keep the credentials for offline re-login
    await prefs.remove('offline_active_uid');
  }

  // إعادة تعيين كلمة المرور
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('حدث خطأ أثناء إرسال رابط استعادة كلمة المرور.');
    }
  }

  // ── Offline Credentials Verification ───────────────────────────
  
  String _hashPassword(String password) {
    final bytes = utf8.encode('ymlover_salt_$password');
    final digest = SHA256Digest().process(Uint8List.fromList(bytes));
    return base64Encode(digest);
  }

  Future<void> _saveOfflineCache(String email, String password, String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'offline_user_${email.trim().toLowerCase()}';
    final data = {
      'email': email.trim().toLowerCase(),
      'passwordHash': _hashPassword(password),
      'uid': uid,
    };
    await _secureStorage.write(key: cacheKey, value: jsonEncode(data));
    await prefs.setString('offline_active_uid', uid);
  }

  Future<String?> _verifyOfflineCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'offline_user_${email.trim().toLowerCase()}';
    final cacheDataStr = await _secureStorage.read(key: cacheKey);
    
    if (cacheDataStr != null) {
      final Map<String, dynamic> data = jsonDecode(cacheDataStr);
      final passwordHash = _hashPassword(password);
      if (data['email'] == email.trim().toLowerCase() && (data['passwordHash'] == passwordHash || data['password'] == password)) {
        await prefs.setString('offline_active_uid', data['uid']);
        return data['uid'];
      }
    }
    return null;
  }

  UserCredential _createMockUserCredential(String uid, String email) {
    // Generate a simulated UserCredential that Riverpod can bind
    return _MockUserCredential(uid, email);
  }

  // معالجة أخطاء Firebase وتحويلها لرسائل عربية مفهومة
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('لم يتم العثور على حساب بهذا البريد الإلكتروني.');
      case 'wrong-password':
        return Exception('كلمة المرور غير صحيحة.');
      case 'email-already-in-use':
        return Exception('هذا البريد الإلكتروني مسجل مسبقاً.');
      case 'invalid-email':
        return Exception('صيغة البريد الإلكتروني غير صالحة.');
      case 'weak-password':
        return Exception('كلمة المرور ضعيفة جداً. يرجى استخدام كلمة مرور أقوى.');
      case 'network-request-failed':
        return Exception('فشل الاتصال بالإنترنت. يرجى التحقق من اتصالك.');
      default:
        return Exception(e.message ?? 'حدث خطأ في عملية التوثيق.');
    }
  }
}

// ── Mock UserCredential Classes for Offline Support ───────────────────────

class _MockUserCredential implements UserCredential {
  final String _uid;
  final String _email;

  _MockUserCredential(this._uid, this._email);

  @override
  User? get user => _MockUser(this._uid, this._email);

  @override
  AuthCredential? get credential => null;

  @override
  AdditionalUserInfo? get additionalUserInfo => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockUser implements User {
  final String _uid;
  final String _email;

  _MockUser(this._uid, this._email);

  @override
  String get uid => _uid;

  @override
  String? get email => _email;

  @override
  bool get emailVerified => true;

  @override
  bool get isAnonymous => false;

  @override
  List<UserInfo> get providerData => [];

  @override
  UserMetadata get metadata => _MockUserMetadata();

  @override
  Future<String> getIdToken([bool forceRefresh = false]) async => 'mock_token';

  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) async => _MockIdTokenResult();

  @override
  Future<void> reload() async {}

  @override
  Future<void> delete() async {}

  @override
  Future<UserCredential> reauthenticateWithCredential(AuthCredential credential) async => _MockUserCredential(_uid, _email);

  // Implement the rest of the members with default stub values
  @override
  String? get displayName => null;
  @override
  String? get phoneNumber => null;
  @override
  String? get photoURL => null;
  @override
  String? get tenantId => null;
  @override
  Future<void> updateDisplayName(String? displayName) async {}
  @override
  Future<void> updateEmail(String email) async {}
  @override
  Future<void> updatePassword(String newPassword) async {}
  @override
  Future<void> updatePhoneNumber(PhoneAuthCredential credential) async {}
  @override
  Future<void> updatePhotoURL(String? photoURL) async {}
  @override
  Future<void> verifyBeforeUpdateEmail(String newEmail, [ActionCodeSettings? actionCodeSettings]) async {}
  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {}
  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) async => _MockUserCredential(_uid, _email);
  @override
  Future<UserCredential> reauthenticateWithProvider(AuthProvider provider) async => _MockUserCredential(_uid, _email);
  @override
  Future<UserCredential> linkWithProvider(AuthProvider provider) async => _MockUserCredential(_uid, _email);
  @override
  Future<User> unlink(String providerId) async => this;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockUserMetadata implements UserMetadata {
  @override
  DateTime? get creationTime => DateTime.now();
  @override
  DateTime? get lastSignInTime => DateTime.now();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockIdTokenResult implements IdTokenResult {
  @override
  String? get token => 'mock_token';
  @override
  DateTime? get authTime => DateTime.now();
  @override
  DateTime? get expirationTime => DateTime.now().add(const Duration(hours: 1));
  @override
  DateTime? get issuedAtTime => DateTime.now();
  @override
  String? get signInProvider => 'password';
  @override
  Map<String, dynamic> get claims => {};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
