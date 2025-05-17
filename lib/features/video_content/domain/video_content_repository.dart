import 'package:chef_app/features/video_content/domain/video_content.dart';

abstract class VideoContentRepository {
  Future<void> addVideo(VideoContent video);
  Stream<List<VideoContent>> getVideoFeed(); // Potentially ordered by likes/time
  Stream<List<VideoContent>> getVideosBySeller(String sellerId);
  Future<void> likeVideo(String videoId, String userId);
  Future<void> unlikeVideo(String videoId, String userId);
  // Add other methods as needed, e.g., delete video
}

