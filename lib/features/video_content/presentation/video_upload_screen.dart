import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
// TODO: Import necessary providers (e.g., user provider, video content repository)
// TODO: Import VideoContent model

class VideoUploadScreen extends ConsumerStatefulWidget {
  const VideoUploadScreen({super.key});

  @override
  ConsumerState<VideoUploadScreen> createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends ConsumerState<VideoUploadScreen> {
  final _captionController = TextEditingController();
  XFile? _videoFile;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickVideo() async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
      setState(() {
        _videoFile = pickedFile;
      });
    } catch (e) {
      // Handle exceptions
      print('Error picking video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking video: $e')),
      );
    }
  }

  Future<void> _uploadVideo() async {
    if (_videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video first')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // TODO: Get current seller ID from auth provider
      final sellerId = 'placeholder_seller_id'; // Replace with actual seller ID
      final caption = _captionController.text;
      final file = File(_videoFile!.path);

      // TODO: Implement upload logic using Firebase Storage
      // 1. Upload video file to Firebase Storage (e.g., /videos/{sellerId}/{timestamp}.mp4)
      // String videoUrl = await uploadFileToStorage(file, sellerId);
      String videoUrl = 'placeholder_video_url'; // Replace with actual URL

      // TODO: Optionally generate and upload thumbnail
      // String? thumbnailUrl = await generateAndUploadThumbnail(file, sellerId);
      String? thumbnailUrl = null;

      // TODO: Create VideoContent object
      // final newVideo = VideoContent(
      //   videoId: '', // Firestore will generate ID
      //   sellerId: sellerId,
      //   videoUrl: videoUrl,
      //   thumbnailUrl: thumbnailUrl,
      //   caption: caption.isNotEmpty ? caption : null,
      //   likes: 0,
      //   likedBy: [],
      //   createdAt: Timestamp.now(),
      // );

      // TODO: Save VideoContent object to Firestore using repository
      // await ref.read(videoContentRepositoryProvider).addVideo(newVideo);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video uploaded successfully!')),
      );
      // Optionally navigate back or clear the form
      Navigator.of(context).pop();

    } catch (e) {
      print('Error uploading video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading video: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Video'), // TODO: Localize
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.video_library),
              label: const Text('Pick Video from Gallery'), // TODO: Localize
              onPressed: _pickVideo,
            ),
            const SizedBox(height: 16),
            if (_videoFile != null)
              Text('Selected: ${_videoFile!.name}'), // Show selected file name
            // TODO: Add video preview if possible/needed
            const SizedBox(height: 16),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                labelText: 'Caption (Optional)', // TODO: Localize
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            _isUploading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Video'), // TODO: Localize
                    onPressed: _uploadVideo,
                  ),
          ],
        ),
      ),
    );
  }
}

