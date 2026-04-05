import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'tip.g.dart';

/// Hive typeId: 4
/// Maps to Firestore `tips/{tip_N}` documents.
@HiveType(typeId: 4)
class Tip extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int index;

  @HiveField(2)
  final String text;

  Tip({
    required this.id,
    required this.index,
    required this.text,
  });

  factory Tip.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Tip(
      id: doc.id,
      index: (data['index'] as num?)?.toInt() ?? 0,
      text: data['text'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'index': index,
      'text': text,
    };
  }
}
