import 'dart:io';
import 'package:chef_app/features/video_content/domain/video_content.dart';
import 'package:chef_app/features/video_content/domain/video_content_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseVideoContentRepository implements VideoContentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference<VideoContent> get _videosRef =>
      _firestore.collection('videos').withConverter<VideoContent>(
            fromFirestore: VideoContent.fromFirestore,
            toFirestore: (VideoContent video, _) => video.toFirestore(),
          );

  @override
  Future<void> addVideo(VideoContent video) async {
    // Upload video file
    // Note: The actual file upload happens before calling this method.
    // This method assumes video.videoUrl and video.thumbnailUrl are already populated
    // after uploading to Firebase Storage.
    await _videosRef.add(video);
  }

  // Helper method to upload file (could be moved to a separate storage service)
  Future<String> uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file to $path: $e');
      rethrow; // Rethrow to be handled by the caller
    }
  }

  @override
  Stream<List<VideoContent>> getVideoFeed() {
    // Order by creation time descending (newest first)
    // TODO: Implement ordering by likes/shares later if needed
    return _videosRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Stream<List<VideoContent>> getVideosBySeller(String sellerId) {
    return _videosRef
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Future<void> likeVideo(String videoId, String userId) async {
    final videoRef = _videosRef.doc(videoId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(videoRef);
      if (!snapshot.exists) {
        throw Exception("Video does not exist!");
      }
      final currentLikes = snapshot.data()?.likes ?? 0;
      final likedBy = List<String>.from(snapshot.data()?.likedBy ?? []);

      if (!likedBy.contains(userId)) {
        transaction.update(videoRef, {
          'likes': currentLikes + 1,
          'likedBy': FieldValue.arrayUnion([userId])
        });
      }
    });
  }

  @override
  Future<void> unlikeVideo(String videoId, String userId) async {
    final videoRef = _videosRef.doc(videoId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(videoRef);
      if (!snapshot.exists) {
        throw Exception("Video does not exist!");
      }
      final currentLikes = snapshot.data()?.likes ?? 0;
      final likedBy = List<String>.from(snapshot.data()?.likedBy ?? []);

      if (likedBy.contains(userId)) {
        transaction.update(videoRef, {
          'likes': currentLikes > 0 ? currentLikes - 1 : 0,
          'likedBy': FieldValue.arrayRemove([userId])
        });
      }
    });
  }

  // TODO: Implement deleteVideo if needed
}

