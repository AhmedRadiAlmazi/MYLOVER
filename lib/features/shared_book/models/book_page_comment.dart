import 'package:cloud_firestore/cloud_firestore.dart';

class BookPageComment {
  final String id;
  final String pageId;
  final String content;
  final String createdBy;
  final DateTime createdAt;

  BookPageComment({
    required this.id,
    required this.pageId,
    required this.content,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'pageId': pageId,
      'content': content,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory BookPageComment.fromMap(Map<String, dynamic> map, String id) {
    return BookPageComment(
      id: id,
      pageId: map['pageId'] ?? '',
      content: map['content'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
