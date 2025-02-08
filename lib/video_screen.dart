import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AssetVideoPlayer(),
    );
  }
}

class AssetVideoPlayer extends StatefulWidget {
  const AssetVideoPlayer({super.key});

  @override
  State<AssetVideoPlayer> createState() => _AssetVideoPlayerState();
}

class _AssetVideoPlayerState extends State<AssetVideoPlayer> {
  Player? _player;
  VideoController? _videoController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    const videoUrl =
        'https://firebasestorage.googleapis.com/v0/b/mundotlaxcala.firebasestorage.app/o/VID-20241207-WA0109.mp4?alt=media&token=59fb9522-4cae-45b8-a736-efa46679ce6a';

    try {
      _player = Player();
      _videoController = VideoController(_player!);

      await _player!.open(Media(videoUrl), play: true);

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      print("Video initialization error: $error");
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _hasError
                ? const Text('Error loading video')
                : AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Video(
                      controller: _videoController!,
                      fit: BoxFit.contain,
                    ),
                  ),
      ),
    );
  }
}
