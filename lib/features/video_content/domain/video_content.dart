import 'package:cloud_firestore/cloud_firestore.dart';

class VideoContent {
  final String videoId;
  final String sellerId;
  final String videoUrl;
  final String? thumbnailUrl; // Optional: for faster loading
  final String? caption;
  final int likes;
  final List<String> likedBy; // List of user UIDs who liked the video
  final Timestamp createdAt;

  VideoContent({
    required this.videoId,
    required this.sellerId,
    required this.videoUrl,
    this.thumbnailUrl,
    this.caption,
    required this.likes,
    required this.likedBy,
    required this.createdAt,
  });

  factory VideoContent.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return VideoContent(
      videoId: snapshot.id,
      sellerId: data?['sellerId'] ?? '',
      videoUrl: data?['videoUrl'] ?? '',
      thumbnailUrl: data?['thumbnailUrl'],
      caption: data?['caption'],
      likes: data?['likes'] ?? 0,
      likedBy: List<String>.from(data?['likedBy'] ?? []),
      createdAt: data?['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sellerId': sellerId,
      'videoUrl': videoUrl,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      if (caption != null) 'caption': caption,
      'likes': likes,
      'likedBy': likedBy,
      'createdAt': createdAt,
    };
  }
}

