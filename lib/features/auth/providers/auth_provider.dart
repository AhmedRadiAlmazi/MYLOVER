import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/app_models.dart';
import '../../../features/auth/services/auth_service.dart';
import '../../../core/services/user_service.dart';

// Services Providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final userServiceProvider = Provider<UserService>((ref) => UserService());

// Auth State Provider (Streams from Firebase)
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current User Model Provider (Fetches from Firestore based on Firebase Auth User)
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final user = authState.value;
  
  if (user == null) {
    return Stream.value(null);
  }
  
  final userService = ref.watch(userServiceProvider);
  return userService.getUserStream(user.uid);
});

// Partner Provider
final currentPartnerProvider = StreamProvider<UserModel?>((ref) {
  final currentUser = ref.watch(currentUserProvider).value;
  
  if (currentUser == null || currentUser.partnerId == null) {
    return Stream.value(null);
  }
  
  final userService = ref.watch(userServiceProvider);
  return userService.getUserStream(currentUser.partnerId!);
});

// Legacy Providers (Refactored to map to new architecture to prevent breaks in other screens)
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authStateChangesProvider).value != null;
});

final isPairedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider).value;
  return user != null && user.partnerId != null && user.partnerId!.isNotEmpty;
});

