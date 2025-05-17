import 'package:chef_app/features/following/presentation/widgets/follow_button.dart'; // Import FollowButton
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:chef_app/features/video_content/domain/video_content.dart';
// TODO: Import video content providers
// TODO: Import user providers (to get seller details)

class VideoFeedScreen extends ConsumerStatefulWidget {
  const VideoFeedScreen({super.key});

  @override
  ConsumerState<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends ConsumerState<VideoFeedScreen> {
  // TODO: Fetch video feed data using Riverpod provider
  final List<VideoContent> _videos = []; // Placeholder
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // TODO: Initialize video fetching
    // Example placeholder data
    // _videos.add(VideoContent(
    //   videoId: '1', sellerId: 'seller1', videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    //   likes: 10, likedBy: [], createdAt: Timestamp.now(), caption: 'Delicious bee honey!',
    // ));
    // _videos.add(VideoContent(
    //   videoId: '2', sellerId: 'seller2', videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    //   likes: 25, likedBy: [], createdAt: Timestamp.now(), caption: 'Fluttering butterfly!',
    // ));
  }

  @override
  void dispose() {
    _pageController?.dispose();
    // TODO: Dispose video controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Handle loading and error states
    if (_videos.isEmpty) {
      // Use a more informative placeholder if no videos are fetched
      return const Scaffold(
        body: Center(child: Text('No videos available yet.')), // TODO: Localize
      );
    }

    return Scaffold(
      // backgroundColor: Colors.black, // Common for video feeds
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          return VideoPlayerItem(video: _videos[index]);
        },
        // TODO: Add preloading logic on page changed
      ),
    );
  }
}

class VideoPlayerItem extends StatefulWidget {
  final VideoContent video;

  const VideoPlayerItem({super.key, required this.video});

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
     // Ensure URL is valid before creating controller
    final uri = Uri.tryParse(widget.video.videoUrl);
    if (uri == null || !uri.hasAbsolutePath) {
      print('Invalid video URL: ${widget.video.videoUrl}');
      setState(() {
        _isInitialized = false; // Mark as not initialized
      });
      return;
    }

    _controller = VideoPlayerController.networkUrl(uri)
      ..initialize().then((_) {
        if (!mounted) return; // Check if widget is still in the tree
        setState(() {
          _isInitialized = true;
        });
        _controller.setLooping(true);
        // TODO: Implement visibility detection to play/pause videos
        // For now, let's start playing immediately for testing
        _controller.play();
        _isPlaying = true;
      }).catchError((error) {
        if (!mounted) return;
        print('Error initializing video: $error');
        setState(() {
          _isInitialized = false;
        });
      });

    _controller.addListener(() {
       if (!mounted) return;
      if (_controller.value.isPlaying != _isPlaying) {
        setState(() {
          _isPlaying = _controller.value.isPlaying;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (!_isInitialized) return; // Don't toggle if not initialized
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: <Widget>[
          Center(
            child: _isInitialized
                ? AspectRatio(
                    // Ensure aspect ratio is valid
                    aspectRatio: _controller.value.isInitialized && _controller.value.aspectRatio > 0
                                 ? _controller.value.aspectRatio
                                 : 16 / 9, // Default aspect ratio
                    child: VideoPlayer(_controller),
                  )
                : Container( // Show a placeholder or error message if not initialized
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
          ),
          // Play/Pause Button Overlay (optional)
          Center(
            child: AnimatedOpacity(
              opacity: _isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: _isInitialized ? Icon(
                Icons.play_arrow,
                size: 80.0,
                color: Colors.white.withOpacity(0.7),
              ) : Container(),
            ),
          ),
          // Video Info Overlay (Seller, Caption, Likes, Share, Follow)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TODO: Fetch and display seller name based on widget.video.sellerId
                Row(
                  children: [
                    Text(
                      'Seller: ${widget.video.sellerId}', // Placeholder
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    // Add Follow Button here
                    SizedBox(
                      height: 30, // Constrain button size
                      child: FollowButton(sellerId: widget.video.sellerId),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (widget.video.caption != null && widget.video.caption!.isNotEmpty)
                  Text(widget.video.caption!, style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Like Button
                    Row(
                      children: [
                        // TODO: Implement like functionality using provider
                        IconButton(
                          icon: const Icon(Icons.favorite_border, color: Colors.white), // TODO: Change icon based on like state
                          onPressed: () { /* TODO: Handle like */ },
                        ),
                        Text(widget.video.likes.toString(), style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                    // Share Button
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () { /* TODO: Handle share */ },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

