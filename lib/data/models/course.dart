import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'course.g.dart';

/// Hive typeId: 3
@HiveType(typeId: 3)
class Lesson extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final Map<String, String> technicalDetails;

  Lesson({
    required this.id,
    required this.content,
    required this.technicalDetails,
  });

  factory Lesson.fromMap(Map<String, dynamic> map) {
    // Safely handle technicalDetails as either a Map or a List of strings
    final rawDetails = map['technicalDetails'];
    Map<String, String> parsedDetails = {};

    if (rawDetails is Map) {
      parsedDetails = rawDetails.map((k, v) => MapEntry(k.toString(), v.toString()));
    } else if (rawDetails is List) {
      // If it's a list, treat indexes as keys (0, 1, 2...)
      for (var i = 0; i < rawDetails.length; i++) {
        parsedDetails[i.toString()] = rawDetails[i].toString();
      }
    }

    return Lesson(
      id: map['id'] as String? ?? '',
      content: map['content'] as String? ?? '',
      technicalDetails: parsedDetails,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'technicalDetails': technicalDetails,
    };
  }
}

/// Hive typeId: 2
@HiveType(typeId: 2)
class Course extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final String duration;

  @HiveField(3)
  final String image;

  @HiveField(4)
  final List<Lesson> lessons;

  @HiveField(5)
  final DateTime cachedAt;

  Course({
    required this.id,
    required this.description,
    required this.duration,
    required this.image,
    required this.lessons,
    required this.cachedAt,
  });

  factory Course.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final rawLessons = data['lessons'];

    List<Lesson> parsedLessons = [];
    if (rawLessons is List) {
      parsedLessons = rawLessons
          .map((e) => Lesson.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } else if (rawLessons is Map) {
      // Firestore sometimes stores arrays as maps with numeric keys
      final sorted = rawLessons.entries.toList()
        ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
      parsedLessons = sorted
          .map((e) => Lesson.fromMap(Map<String, dynamic>.from(e.value as Map)))
          .toList();
    }

    return Course(
      id: doc.id,
      description: data['description'] as String? ?? '',
      duration: data['duration'] as String? ?? '',
      image: data['image'] as String? ?? '',
      lessons: parsedLessons,
      cachedAt: DateTime.now(),
    );
  }
}
