import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verd/data/models/course.dart';
import 'package:verd/data/models/tip.dart';
import 'package:verd/data/models/user_progress.dart';
import 'package:verd/providers/auth_provider.dart';

// ─── Courses Provider ───

final coursesProvider = AsyncNotifierProvider<CoursesNotifier, List<Course>>(
  CoursesNotifier.new,
);

class CoursesNotifier extends AsyncNotifier<List<Course>> {
  @override
  FutureOr<List<Course>> build() async {
    final localStorage = ref.read(localStorageServiceProvider);
    final firestoreService = ref.read(firestoreServiceProvider);

    debugPrint('[LearningProvider] Building CoursesNotifier...');
    final cached = localStorage.getCachedCourses();
    if (cached.isNotEmpty) {
      debugPrint('[LearningProvider] Using ${cached.length} cached courses');
      Future.microtask(() => _backgroundRefresh());
      return cached;
    }

    debugPrint('[LearningProvider] Cache empty, fetching from Firestore...');
    final courses = await firestoreService.fetchCourses();
    debugPrint('[LearningProvider] Firestore returned ${courses.length} courses');
    if (courses.isNotEmpty) {
      await localStorage.cacheCourses(courses);
    }
    return courses;
  }

  Future<void> _backgroundRefresh() async {
    try {
      debugPrint('[LearningProvider] Background refresh starting...');
      final localStorage = ref.read(localStorageServiceProvider);
      final firestoreService = ref.read(firestoreServiceProvider);
      final fresh = await firestoreService.fetchCourses();
      debugPrint('[LearningProvider] Background refresh returned ${fresh.length} courses');
      if (fresh.isNotEmpty) {
        await localStorage.cacheCourses(fresh);
        state = AsyncValue.data(fresh);
      }
    } catch (e) {
      debugPrint('[LearningProvider] Background refresh error: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final localStorage = ref.read(localStorageServiceProvider);
      final firestoreService = ref.read(firestoreServiceProvider);
      final courses = await firestoreService.fetchCourses();
      if (courses.isNotEmpty) {
        await localStorage.cacheCourses(courses);
      }
      return courses;
    });
  }
}

// ─── Tips Provider ───

final tipsProvider = AsyncNotifierProvider<TipsNotifier, List<Tip>>(
  TipsNotifier.new,
);

class TipsNotifier extends AsyncNotifier<List<Tip>> {
  @override
  FutureOr<List<Tip>> build() async {
    final localStorage = ref.read(localStorageServiceProvider);
    final firestoreService = ref.read(firestoreServiceProvider);

    final cached = localStorage.getCachedTips();
    if (cached.isNotEmpty) {
      Future.microtask(() => _backgroundRefresh());
      return cached;
    }

    final tips = await firestoreService.fetchTips();
    if (tips.isNotEmpty) {
      await localStorage.cacheTips(tips);
    }
    return tips;
  }

  Future<void> _backgroundRefresh() async {
    try {
      final localStorage = ref.read(localStorageServiceProvider);
      final firestoreService = ref.read(firestoreServiceProvider);
      final fresh = await firestoreService.fetchTips();
      if (fresh.isNotEmpty) {
        await localStorage.cacheTips(fresh);
        state = AsyncValue.data(fresh);
      }
    } catch (_) {}
  }
}

final tipOfTheDayProvider = Provider<Tip?>((ref) {
  final tipsAsync = ref.watch(tipsProvider);
  return tipsAsync.whenOrNull(data: (tips) {
    if (tips.isEmpty) return null;
    final sorted = List<Tip>.from(tips)
      ..sort((a, b) => a.index.compareTo(b.index));
    final dayIndex = DateTime.now().difference(DateTime(DateTime.now().year)).inDays.abs();
    return sorted[dayIndex % sorted.length];
  });
});

// ─── User Progress Provider ───

/// Note: In Riverpod 3 (non-codegen), AsyncNotifierProvider.family 
/// creates the Notifier by passing the argument to its constructor.
/// The Notifier should then extend [AsyncNotifier] (or AutoDispose variant).
final userProgressProvider =
    AsyncNotifierProvider.family<UserProgressNotifier, UserProgress?, String>(
  UserProgressNotifier.new,
);

class UserProgressNotifier extends AsyncNotifier<UserProgress?> {
  final String courseId;
  UserProgressNotifier(this.courseId);

  @override
  FutureOr<UserProgress?> build() async {
    final localStorage = ref.read(localStorageServiceProvider);
    final firestoreService = ref.read(firestoreServiceProvider);
    final user = ref.watch(currentUserProvider);

    if (user == null || user.displayName == 'Guest') return null;

    final cached = localStorage.getCachedProgress(user.uid, courseId);
    if (cached != null) {
      Future.microtask(() => _syncFromRemote(user.uid, courseId));
      return cached;
    }

    final remote = await firestoreService.fetchUserProgress(user.uid, courseId);
    if (remote != null) {
      await localStorage.cacheUserProgress(remote);
    }
    return remote;
  }

  Future<void> _syncFromRemote(String userId, String courseId) async {
    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final localStorage = ref.read(localStorageServiceProvider);
      final remote = await firestoreService.fetchUserProgress(userId, courseId);
      if (remote != null) {
        await localStorage.cacheUserProgress(remote);
        state = AsyncValue.data(remote);
      }
    } catch (_) {}
  }

  Future<void> toggleLesson({
    required String lessonId,
    required int totalLessons,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null || user.displayName == 'Guest') return;

    final firestoreService = ref.read(firestoreServiceProvider);
    final localStorage = ref.read(localStorageServiceProvider);

    final updated = await firestoreService.toggleLessonComplete(
      userId: user.uid,
      courseId: courseId, 
      lessonId: lessonId,
      totalLessons: totalLessons,
      existing: state.value,
    );

    await localStorage.cacheUserProgress(updated);
    state = AsyncValue.data(updated);
  }
}
