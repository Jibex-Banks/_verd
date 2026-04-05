import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'user_progress.g.dart';

/// Hive typeId: 5
/// Maps to Firestore `userProgress/{userId}_{courseId}` documents.
@HiveType(typeId: 5)
class UserProgress extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String courseId;

  @HiveField(2)
  List<String> completedLessons;

  @HiveField(3)
  String status; // "not_started" | "started" | "completed"

  @HiveField(4)
  DateTime updatedAt;

  UserProgress({
    required this.userId,
    required this.courseId,
    required this.completedLessons,
    required this.status,
    required this.updatedAt,
  });

  String get docId => '${userId}_$courseId';

  bool isLessonCompleted(String lessonId) =>
      completedLessons.contains(lessonId);

  double progressFraction(int totalLessons) =>
      totalLessons == 0 ? 0.0 : completedLessons.length / totalLessons;

  factory UserProgress.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserProgress(
      userId: data['userId'] as String? ?? '',
      courseId: data['courseId'] as String? ?? '',
      completedLessons:
          List<String>.from(data['completedLessons'] as List? ?? []),
      status: data['status'] as String? ?? 'not_started',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'courseId': courseId,
      'completedLessons': completedLessons,
      'status': status,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserProgress copyWith({
    String? userId,
    String? courseId,
    List<String>? completedLessons,
    String? status,
    DateTime? updatedAt,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      completedLessons: completedLessons ?? this.completedLessons,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
