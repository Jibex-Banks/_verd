import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verd/data/models/user.dart';
import 'package:verd/data/repositories/auth_repository.dart';
import 'package:verd/data/services/firebase_auth_service.dart';
import 'package:verd/data/services/firestore_service.dart';
import 'package:verd/data/services/local_storage.dart';
import 'package:verd/data/services/storage_service.dart';
import 'package:verd/providers/notification_provider.dart';

// ─── Service-level providers ───

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  // This is correctly overridden in main.dart inside ProviderScope
  throw UnimplementedError('localStorageServiceProvider must be overridden');
});

// ─── Repository provider ───

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    authService: ref.watch(firebaseAuthServiceProvider),
    firestoreService: ref.watch(firestoreServiceProvider),
    localStorage: ref.watch(localStorageServiceProvider),
  );
});

// ─── Auth State (reactive stream from Firebase) ───

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthServiceProvider).authStateChanges;
});

// ─── Cached current user profile ───

final currentUserProvider = Provider<AppUser?>((ref) {
  // Watch the authNotifierProvider to get the current state of the AppUser profile.
  // This ensures that when the async build() in AuthNotifier completes,
  // the UI (and any screen watching currentUserProvider) will reactivey update.
  return ref.watch(authNotifierProvider).value;
});

// ─── Auth Notifier (login / register / logout actions) ───

class AuthNotifier extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    // 1. Watch auth state changes (StreamProvider)
    final authState = ref.watch(authStateProvider).value;

    // If we're definitely not authenticated, return null
    if (authState == null) return null;

    // 2. Check local Hive cache first (best for speed/offline)
    final repository = ref.read(authRepositoryProvider);
    final cached = repository.getCachedUser();

    // If cache belongs to the same user, use it
    if (cached != null && cached.uid == authState.uid) {
      return cached;
    }

    // 3. Fallback: authenticated but no cache
    if (authState.isAnonymous) {
      // Synthesize a guest user profile
      final guest = AppUser(
        uid: authState.uid,
        email: '',
        displayName: 'Guest',
        createdAt: DateTime.now(),
      );
      // Optional: cache it for future consistency
      await ref.read(localStorageServiceProvider).cacheUser(guest);
      return guest;
    } else {
      // PROACTIVE FETCH: Missing profile for logged-in user
      debugPrint(
        '[AuthNotifier] Cache empty for ${authState.uid}, fetching from Firestore...',
      );
      return await repository.refreshProfile();
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref
          .read(authRepositoryProvider)
          .login(email, password);
      await _handleFcmSetup(user.uid);
      return user;
    });
  }

  Future<void> _handleFcmSetup(String uid) async {
    try {
      final fcm = ref.read(fcmServiceProvider);
      final token = await fcm.init();
      if (token != null) {
        await ref.read(firestoreServiceProvider).saveFcmToken(uid, token);
      }
      // Re-sync topic subscriptions
      await ref.read(notificationSettingsProvider.notifier).syncSubscriptions();
    } catch (e) {
      debugPrint('[FCM] Setup failed: $e');
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref
          .read(authRepositoryProvider)
          .register(name: name, email: email, password: password);
      await _handleFcmSetup(user.uid);
      return user;
    });
  }

  Future<void> resetPassword(String email) async {
    await ref.read(authRepositoryProvider).resetPassword(email);
  }

  Future<void> continueAsGuest() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInAnonymously(),
    );
  }

  /// Update the user's profile (name, phone, location, photo).
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? location,
    File? photoFile,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updated = await ref
          .read(authRepositoryProvider)
          .updateProfile(
            name: name,
            phone: phone,
            location: location,
            photoFile: photoFile,
          );
      // Invalidate both providers so the profile screen re-reads the updated user
      // authNotifierProvider builds from cache, so we need to clear it to force rebuild
      ref.invalidate(authNotifierProvider);
      ref.invalidate(currentUserProvider);
      return updated;
    });
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }

  Future<void> deleteAccount() async {
    await ref.read(authRepositoryProvider).deleteAccount();
    state = const AsyncData(null);
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AppUser?>(
  AuthNotifier.new,
);
