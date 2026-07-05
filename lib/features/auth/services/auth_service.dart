import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // الحصول على حالة التوثيق الحالية (Stream)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // الحصول على المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  // تسجيل الدخول
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.');
    }
  }

  // إنشاء حساب جديد
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع أثناء إنشاء الحساب.');
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
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
