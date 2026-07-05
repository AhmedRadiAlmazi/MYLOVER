import 'package:cloud_firestore/cloud_firestore.dart';

class BookPageModel {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final List<String> imageUrls;
  final List<String> videoUrls;
  final List<String> audioUrls;
  final String? location;
  final String? mood;
  final String? weather;
  final List<String> likes; // List of user IDs who liked
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? updatedBy;

  BookPageModel({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.imageUrls = const [],
    this.videoUrls = const [],
    this.audioUrls = const [],
    this.location,
    this.mood,
    this.weather,
    this.likes = const [],
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.updatedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'date': Timestamp.fromDate(date),
      'imageUrls': imageUrls,
      'videoUrls': videoUrls,
      'audioUrls': audioUrls,
      'location': location,
      'mood': mood,
      'weather': weather,
      'likes': likes,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'updatedBy': updatedBy,
    };
  }

  factory BookPageModel.fromMap(Map<String, dynamic> map, String id) {
    return BookPageModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      videoUrls: List<String>.from(map['videoUrls'] ?? []),
      audioUrls: List<String>.from(map['audioUrls'] ?? []),
      location: map['location'],
      mood: map['mood'],
      weather: map['weather'],
      likes: List<String>.from(map['likes'] ?? []),
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
      updatedBy: map['updatedBy'],
    );
  }
}
