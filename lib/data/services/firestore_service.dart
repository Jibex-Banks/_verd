import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:verd/data/models/user.dart';
import 'package:verd/data/models/scan_result.dart';
import 'package:verd/data/models/course.dart';
import 'package:verd/data/models/tip.dart';
import 'package:verd/data/models/user_progress.dart';

/// Wraps [FirebaseFirestore] with typed methods for Verd's collections.
///
/// Collections:
/// - `users/{uid}` — user profiles
/// - `users/{uid}/scans/{scanId}` — per-user scan results
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static bool _settingsInitialized = false;

  FirestoreService() {
    // Enable offline persistence (Firestore caches data locally by default
    // on mobile, but this ensures it's explicitly active).
    if (!_settingsInitialized) {
      _firestore.settings = const Settings(persistenceEnabled: true);
      _settingsInitialized = true;
    }
  }

  // ─── Users ───

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection('users');

  /// Create or overwrite a user profile document.
  Future<void> createUserProfile(AppUser user) async {
    await _usersCol.doc(user.uid).set(user.toFirestore());
  }

  /// Get a user profile by UID.
  Future<AppUser?> getUserProfile(String uid) async {
    final doc = await _usersCol.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  /// Update specific fields on the user profile.
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _usersCol.doc(uid).update(data);
  }

  /// Store the FCM token on the user document.
  Future<void> saveFcmToken(String uid, String token) async {
    await _usersCol.doc(uid).update({'fcmToken': token});
  }

  // ─── Scans (sub-collection under user) ───

  CollectionReference<Map<String, dynamic>> _scansCol(String uid) =>
      _usersCol.doc(uid).collection('scans');

  /// Save a scan result to Firestore.
  Future<void> saveScanResult(String uid, ScanResult scan) async {
    await _scansCol(uid).doc(scan.id).set(scan.toFirestore());
  }

  /// Directly updates a scan document with raw data.
  Future<void> updateScanRaw(String uid, String scanId, Map<String, dynamic> data) async {
    await _scansCol(uid).doc(scanId).update(data);
  }

  /// Sets (creates or overwrites) a scan document with raw data.
  Future<void> saveScanRaw(String uid, String scanId, Map<String, dynamic> data) async {
    await _scansCol(uid).doc(scanId).set(data);
  }

  /// Get all scans for a user, ordered by most recent.
  Future<List<ScanResult>> getUserScans(String uid, {int? limit}) async {
    var query = _scansCol(uid).orderBy('scannedAt', descending: true);
    if (limit != null) {
      query = query.limit(limit);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => ScanResult.fromFirestore(doc)).toList();
  }

  /// Listens to a scan document and waits for the Gemini Extension to populate
  /// the response field (configured as 'analysis' in the extension).
  Future<Map<String, dynamic>?> waitForScanAnalysis({
    required String userId,
    required String scanId,
    required Duration timeout,
  }) async {
    try {
      final docRef = _scansCol(userId).doc(scanId);

      // Listen to the document stream
      return await docRef.snapshots().map((snapshot) {
        if (!snapshot.exists) return null;
        final data = snapshot.data();
        if (data == null) return null;

        debugPrint('[FirestoreService] Snapshot keys: ${data.keys.toList()}');

        // 1. Check for 'status' field FIRST — extension writes errors here
        final status = data['status'];
        if (status is Map && status.containsKey('error')) {
          debugPrint('[FirestoreService] Extension status error: ${status['error']}');
          return {
            '_extensionError': true,
            'errorMessage': status['error'].toString(),
          };
        }

        // 2. Check for explicit error fields
        if (data.containsKey('error') || data.containsKey('errorMessage')) {
          debugPrint('[FirestoreService] Document error field: ${data['error'] ?? data['errorMessage']}');
          return {
            '_extensionError': true,
            'errorMessage': data['error']?.toString() ?? data['errorMessage']?.toString() ?? 'Unknown error',
          };
        }

        // 3. Check for the extension's Response Field: 'analysis'
        if (data.containsKey('analysis')) {
          final analysis = data['analysis'];
          debugPrint('[FirestoreService] Got analysis field (type: ${analysis.runtimeType}): $analysis');

          // If the analysis itself is an error placeholder (cropType == 'Error'),
          // still return it — ai_routing_service will handle parsing.
          return {
            '_extensionError': false,
            'analysis': analysis,
            'imageUrl': data['imageUrl'],
          };
        }

        // 4. Also check 'output' for backwards compatibility
        if (data.containsKey('output')) {
          final output = data['output'];
          debugPrint('[FirestoreService] Got output field (type: ${output.runtimeType})');
          return {
            '_extensionError': false,
            'analysis': output,
            'imageUrl': data['imageUrl'],
          };
        }

        return null; // Keep waiting
      }).firstWhere(
        (data) => data != null,
      ).timeout(timeout);
    } catch (e) {
      debugPrint('[FirestoreService] Timeout or Error waiting for analysis: $e');
      return null;
    }
  }

  /// Get scans for a user by crop type.
  Future<List<ScanResult>> getCropScans(String uid, String cropType) async {
    final snapshot = await _scansCol(uid)
        .where('plantName', isEqualTo: cropType)
        .orderBy('scannedAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => ScanResult.fromFirestore(doc)).toList();
  }

  /// Update user's crop stats.
  Future<void> updateCropStats({
    required String userId,
    required String cropType,
    required String healthStatus,
  }) async {
    // Basic implementation for stats tracking
    final statsRef = _usersCol.doc(userId).collection('stats').doc(cropType);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(statsRef);
      if (!doc.exists) {
        transaction.set(statsRef, {
          'cropType': cropType,
          'totalScans': 1,
          'healthyScans': healthStatus == 'healthy' ? 1 : 0,
        });
      } else {
        final currentTotal = doc.data()?['totalScans'] ?? 0;
        final currentHealthy = doc.data()?['healthyScans'] ?? 0;
        transaction.update(statsRef, {
          'totalScans': currentTotal + 1,
          'healthyScans': healthStatus == 'healthy' ? currentHealthy + 1 : currentHealthy,
        });
      }
    });
  }

  /// Delete a single scan.
  Future<void> deleteScan(String uid, String scanId) async {
    await _scansCol(uid).doc(scanId).delete();
  }

  /// Delete all user data — called when user deletes their account.
  Future<void> deleteAllUserData(String uid) async {
    // Delete scans sub-collection
    final scans = await _scansCol(uid).get();
    for (final doc in scans.docs) {
      await doc.reference.delete();
    }
    // Delete user document
    await _usersCol.doc(uid).delete();
  }

  // ─── Courses ───

  CollectionReference<Map<String, dynamic>> get _coursesCol =>
      _firestore.collection('courses');

  /// Fetch all courses from Firestore.
  Future<List<Course>> fetchCourses() async {
    try {
      final snapshot = await _coursesCol.get();
      return snapshot.docs
          .map((doc) => Course.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e, stack) {
      debugPrint('[FirestoreService] fetchCourses error: $e');
      debugPrint('[FirestoreService] Stack trace: $stack');
      return [];
    }
  }

  // ─── Tips ───

  CollectionReference<Map<String, dynamic>> get _tipsCol =>
      _firestore.collection('tips');

  /// Fetch all tips from Firestore.
  Future<List<Tip>> fetchTips() async {
    try {
      final snapshot = await _tipsCol.get();
      return snapshot.docs
          .map((doc) => Tip.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e, stack) {
      debugPrint('[FirestoreService] fetchTips error: $e');
      debugPrint('[FirestoreService] Stack trace: $stack');
      return [];
    }
  }

  // ─── User Progress ───

  CollectionReference<Map<String, dynamic>> get _progressCol =>
      _firestore.collection('userProgress');

  /// Fetch progress for a specific user + course.
  Future<UserProgress?> fetchUserProgress(
      String userId, String courseId) async {
    try {
      final docId = '${userId}_$courseId';
      final doc = await _progressCol.doc(docId).get();
      if (!doc.exists) return null;
      return UserProgress.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>);
    } catch (e) {
      debugPrint('[FirestoreService] fetchUserProgress error: $e');
      return null;
    }
  }

  /// Save or update user progress for a course.
  Future<void> saveUserProgress(UserProgress progress) async {
    try {
      await _progressCol
          .doc(progress.docId)
          .set(progress.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('[FirestoreService] saveUserProgress error: $e');
    }
  }

  /// Mark a single lesson as complete for a user.
  Future<UserProgress> toggleLessonComplete({
    required String userId,
    required String courseId,
    required String lessonId,
    required int totalLessons,
    UserProgress? existing,
  }) async {
    final current = existing ??
        UserProgress(
          userId: userId,
          courseId: courseId,
          completedLessons: [],
          status: 'not_started',
          updatedAt: DateTime.now(),
        );

    final completedLessons = List<String>.from(current.completedLessons);
    if (completedLessons.contains(lessonId)) {
      completedLessons.remove(lessonId);
    } else {
      completedLessons.add(lessonId);
    }

    final status = completedLessons.isEmpty
        ? 'not_started'
        : completedLessons.length >= totalLessons
            ? 'completed'
            : 'started';

    final updated = current.copyWith(
      completedLessons: completedLessons,
      status: status,
      updatedAt: DateTime.now(),
    );

    await saveUserProgress(updated);
    return updated;
  }
}
