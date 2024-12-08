import 'package:flutter/material.dart';
import 'package:tlaxcala_world/feedback/feedback_methods.dart';
import 'package:video_player/video_player.dart';

class AssetVideoPlayer extends StatefulWidget {
  const AssetVideoPlayer({Key? key}) : super(key: key);

  @override
  State<AssetVideoPlayer> createState() => _AssetVideoPlayerState();
}

class _AssetVideoPlayerState extends State<AssetVideoPlayer> {
  late VideoPlayerController _controller;

  @override
void initState() {
  super.initState();

  final videoUrl = 'https://firebasestorage.googleapis.com/v0/b/mundotlaxcala.firebasestorage.app/o/vid.mp4?alt=media&token=01955181-1ebe-4afa-8018-00179c34ac86';

  _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
    ..initialize().then((_) {
      setState(() {
        _controller.play();
        _controller.setLooping(true);
      });
    }).catchError((error) {
      // Handle error gracefully
      showSnackbar(context, "Video initialization error: $error");
      print("Video initialization error: $error");
    });
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
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
