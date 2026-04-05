import 'package:hive_flutter/hive_flutter.dart';
import 'package:verd/data/models/user.dart';
import 'package:verd/data/models/scan_result.dart';
import 'package:verd/data/models/course.dart';
import 'package:verd/data/models/tip.dart';
import 'package:verd/data/models/user_progress.dart';

/// Central service wrapping all Hive local-storage operations.
///
/// Manages boxes:
/// - `userBox` — cached user profile
/// - `scanBox` — cached scan results (including unsynced ones)
/// - `settingsBox` — app preferences (theme, language, onboarding, etc.)
/// - `courseBox` — cached learning courses from Firestore
/// - `tipBox` — cached daily tips from Firestore
/// - `progressBox` — cached user progress per course
class LocalStorageService {
  static const String _userBoxName = 'users';
  static const String _scanBoxName = 'scans';
  static const String _settingsBoxName = 'settings';
  static const String _courseBoxName = 'courses';
  static const String _tipBoxName = 'tips';
  static const String _progressBoxName = 'userProgress';

  late Box<AppUser> _userBox;
  late Box<ScanResult> _scanBox;
  late Box _settingsBox;
  late Box<Course> _courseBox;
  late Box<Tip> _tipBox;
  late Box<UserProgress> _progressBox;

  /// Must be called once during app init (after Hive.initFlutter()).
  Future<void> init() async {
    // Register adapters (safe to call multiple times due to internal guard)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AppUserAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ScanResultAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CourseAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(LessonAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(TipAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(UserProgressAdapter());
    }

    _userBox = await Hive.openBox<AppUser>(_userBoxName);
    _scanBox = await Hive.openBox<ScanResult>(_scanBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
    _courseBox = await Hive.openBox<Course>(_courseBoxName);
    _tipBox = await Hive.openBox<Tip>(_tipBoxName);
    _progressBox = await Hive.openBox<UserProgress>(_progressBoxName);
  }

  // ─── User Cache ───

  Future<void> cacheUser(AppUser user) async {
    // We only support one active user profile cached at a time.
    await _userBox.put('currentUser', user);
  }

  AppUser? getCachedUser() {
    if (_userBox.isEmpty) return null;
    return _userBox.get('currentUser');
  }

  Future<void> clearUserCache() async {
    await _userBox.clear();
  }

  // ─── Scan Results Cache ───

  Future<void> cacheScanResult(ScanResult result) async {
    await _scanBox.put(result.id, result);
  }

  List<ScanResult> getCachedScans() {
    return _scanBox.values.toList()
      ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
  }

  /// Returns scans that haven't been synced to Firestore yet.
  List<ScanResult> getPendingSyncs() {
    return _scanBox.values.where((s) => !s.synced).toList();
  }

  /// Marks a local scan as synced after successful upload.
  Future<void> markSynced(String scanId, {String? remoteImageUrl}) async {
    final scan = _scanBox.get(scanId);
    if (scan != null) {
      final updated = scan.copyWith(synced: true, imageUrl: remoteImageUrl);
      await _scanBox.put(scanId, updated);
    }
  }

  Future<void> deleteScan(String scanId) async {
    await _scanBox.delete(scanId);
  }

  Future<void> clearScanCache() async {
    await _scanBox.clear();
  }

  // ─── Settings (generic key-value) ───

  Future<void> setSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  Future<void> clearSettings() async {
    await _settingsBox.clear();
  }

  // ─── Courses Cache ───

  Future<void> cacheCourses(List<Course> courses) async {
    await _courseBox.clear();
    for (final course in courses) {
      await _courseBox.put(course.id, course);
    }
  }

  List<Course> getCachedCourses() {
    return _courseBox.values.toList();
  }

  // ─── Tips Cache ───

  Future<void> cacheTips(List<Tip> tips) async {
    await _tipBox.clear();
    for (final tip in tips) {
      await _tipBox.put(tip.id, tip);
    }
  }

  List<Tip> getCachedTips() {
    final list = _tipBox.values.toList();
    list.sort((a, b) => a.index.compareTo(b.index));
    return list;
  }

  /// Returns a deterministic tip for today based on Julian day number
  Tip? getTipOfTheDay() {
    final tips = getCachedTips();
    if (tips.isEmpty) return null;
    final dayIndex = DateTime.now().difference(DateTime(2025)).inDays;
    return tips[dayIndex % tips.length];
  }

  // ─── User Progress Cache ───

  Future<void> cacheUserProgress(UserProgress progress) async {
    await _progressBox.put(progress.docId, progress);
  }

  UserProgress? getCachedProgress(String userId, String courseId) {
    return _progressBox.get('${userId}_$courseId');
  }

  List<UserProgress> getAllCachedProgress(String userId) {
    return _progressBox.values
        .where((p) => p.userId == userId)
        .toList();
  }

  Future<void> clearProgressCache() async {
    await _progressBox.clear();
  }

  // ─── Full Wipe ───

  Future<void> clearAll() async {
    await _userBox.clear();
    await _scanBox.clear();
    await _settingsBox.clear();
    await _courseBox.clear();
    await _tipBox.clear();
    await _progressBox.clear();
  }
}
