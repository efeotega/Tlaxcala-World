
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AssetVideoPlayer extends StatefulWidget {
  const AssetVideoPlayer({Key? key}) : super(key: key);

  @override
  State<AssetVideoPlayer> createState() => _AssetVideoPlayerState();
}

class _AssetVideoPlayerState extends State<AssetVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final videoUrl =
          'https://firebasestorage.googleapis.com/v0/b/mundotlaxcala.firebasestorage.app/o/vid.mp4?alt=media&token=01955181-1ebe-4afa-8018-00179c34ac86';

      // Use the cache manager to download and cache the file
      final file = await DefaultCacheManager().getSingleFile(videoUrl);

      // Initialize the video controller with the cached file
      _controller = VideoPlayerController.file(file)
        ..initialize().then((_) {
          setState(() {
            _isLoading = false;
            _controller.play();
            _controller.setLooping(true);
          });
        });
        if(kIsWeb){
          _controller = VideoPlayerController.network(videoUrl)
        ..initialize().then((_) {
          setState(() {
            _isLoading = false;
            _controller.play();
            _controller.setLooping(true);
          });
        });
        }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("Video caching or initialization error: $error");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const Text('Error loading video'),
      ),
    );
  }
}
