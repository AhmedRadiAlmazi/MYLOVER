import 'package:cloud_firestore/cloud_firestore.dart';

enum WishCategory {
  travel('سفر', '✈️'),
  gifts('هدايا', '🎁'),
  restaurants('مطاعم', '🍽️'),
  learning('تعلم', '📚'),
  future('مستقبل', '🏡'),
  memories('ذكريات', '💖'),
  occasions('مناسبات', '🎉'),
  adventures('مغامرات', '🧗'),
  other('أخرى', '✨');

  final String label;
  final String emoji;
  const WishCategory(this.label, this.emoji);

  factory WishCategory.fromString(String name) {
    return WishCategory.values.firstWhere(
      (e) => e.name == name,
      orElse: () => WishCategory.other,
    );
  }
}

enum WishStatus {
  pending,
  completed
}

class WishModel {
  final String id;
  final String title;
  final String description;
  final WishCategory category;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? targetDate;
  final WishStatus status;
  final double progress; // 0.0 to 1.0

  WishModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.createdBy,
    required this.createdAt,
    this.targetDate,
    this.status = WishStatus.pending,
    this.progress = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category.name,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'targetDate': targetDate != null ? Timestamp.fromDate(targetDate!) : null,
      'status': status.name,
      'progress': progress,
    };
  }

  factory WishModel.fromMap(Map<String, dynamic> map, String id) {
    return WishModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: WishCategory.fromString(map['category'] ?? 'other'),
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      targetDate: map['targetDate'] != null ? (map['targetDate'] as Timestamp).toDate() : null,
      status: map['status'] == 'completed' ? WishStatus.completed : WishStatus.pending,
      progress: (map['progress'] ?? 0.0).toDouble(),
    );
  }

  WishModel copyWith({
    String? title,
    String? description,
    WishCategory? category,
    DateTime? targetDate,
    WishStatus? status,
    double? progress,
  }) {
    return WishModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      createdBy: createdBy,
      createdAt: createdAt,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }
}
