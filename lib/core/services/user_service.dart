import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_models.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // الإشارة إلى مجموعة المستخدمين
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  // إنشاء ملف مستخدم جديد
  Future<void> createUserDocument(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toMap());
    } catch (e) {
      throw Exception('فشل في حفظ بيانات المستخدم: $e');
    }
  }

  // جلب بيانات مستخدم بناءً على المعرف
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('فشل في جلب بيانات المستخدم: $e');
    }
  }

  // جلب بيانات المستخدم كبث مباشر (Stream)
  Stream<UserModel?> getUserStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  // تحديث حالة الأونلاين وتاريخ آخر ظهور
  Future<void> updateUserPresence(String uid, bool isOnline) async {
    try {
      await _usersCollection.doc(uid).update({
        'isOnline': isOnline,
        'lastSeen': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating presence: $e');
    }
  }

  // تحديث الملف الشخصي (الاسم والصورة)
  Future<void> updateUserProfile(String uid, String name, {String? avatarUrl}) async {
    try {
      final data = <String, dynamic>{'name': name};
      if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
      await _usersCollection.doc(uid).update(data);
    } catch (e) {
      throw Exception('فشل في تحديث الملف الشخصي: $e');
    }
  }

  // ربط المستخدم مع شريكه
  Future<void> linkWithPartner(String uid, String partnerId) async {
    try {
      await _usersCollection.doc(uid).update({
        'partnerId': partnerId,
      });
      // تحديث الشريك أيضاً إذا كان مطلوباً
      await _usersCollection.doc(partnerId).update({
        'partnerId': uid,
      });
    } catch (e) {
      throw Exception('فشل في ربط الحساب بالشريك: $e');
    }
  }

  // إنشاء كود ربط عشوائي (6 أرقام وحروف) وحفظه
  Future<String> generatePairingCode(String uid) async {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String code = String.fromCharCodes(Iterable.generate(
      6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
      
    try {
      await _usersCollection.doc(uid).update({
        'pairingCode': code,
      });
      return code;
    } catch (e) {
      throw Exception('فشل في توليد كود الربط: $e');
    }
  }

  // البحث عن مستخدم عبر كود الربط الخاص به
  Future<UserModel?> getUserByPairingCode(String code) async {
    try {
      final querySnapshot = await _usersCollection
          .where('pairingCode', isEqualTo: code)
          .limit(1)
          .get();
          
      if (querySnapshot.docs.isNotEmpty) {
        return UserModel.fromMap(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('فشل في البحث عن كود الربط: $e');
    }
  }
}
