import 'dart:math';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      await _cacheUserLocally(user);
    } catch (e) {
      throw Exception('فشل في حفظ بيانات المستخدم: $e');
    }
  }

  // جلب بيانات مستخدم بناءً على المعرف
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final user = UserModel.fromMap(doc.data()!);
        await _cacheUserLocally(user);
        return user;
      }
      return await _getLocalCachedUser(uid);
    } catch (e) {
      // Fallback to local cache when offline
      final localUser = await _getLocalCachedUser(uid);
      if (localUser != null) return localUser;
      throw Exception('فشل في جلب بيانات المستخدم: $e');
    }
  }

  // جلب بيانات المستخدم كبث مباشر (Stream)
  Stream<UserModel?> getUserStream(String uid) {
    // We fetch snapshots, and if it fails or yields error (like offline status),
    // we fallback to emitting the local cached user data.
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        final user = UserModel.fromMap(doc.data()!);
        _cacheUserLocally(user);
        return user;
      }
      return null;
    }).handleError((error) async {
      // Return cached user if firestore throws offline/permission error
      return await _getLocalCachedUser(uid);
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
      
      // Update local cache as well
      final local = await _getLocalCachedUser(uid);
      if (local != null) {
        final updatedUser = UserModel(
          id: local.id,
          name: name,
          email: local.email,
          avatarUrl: avatarUrl ?? local.avatarUrl,
          partnerId: local.partnerId,
          pairingCode: local.pairingCode,
          publicKey: local.publicKey,
          relationshipStart: local.relationshipStart,
          isOnline: local.isOnline,
          lastSeen: local.lastSeen,
        );
        await _cacheUserLocally(updatedUser);
      }
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

  // ── Local caching functions ────────────────────────────────────

  Future<void> _cacheUserLocally(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_user_model_${user.id}', jsonEncode(user.toMap()));
  }

  Future<UserModel?> _getLocalCachedUser(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('cached_user_model_$uid');
    if (jsonStr != null) {
      return UserModel.fromMap(jsonDecode(jsonStr));
    }
    return null;
  }
}
