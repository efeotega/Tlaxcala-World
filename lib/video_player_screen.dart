import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _controlsVisible = true;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize video controller
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      }).catchError((error) {
        setState(() {
          _errorMessage = 'Failed to load video: $error';
        });
      });

    // Listen to playback state
    _controller.addListener(() {
      if (_controller.value.isPlaying != _isPlaying) {
        setState(() {
          _isPlaying = _controller.value.isPlaying;
        });
      }
    });

    // Animation for controls
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    // Show controls initially
    _animationController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  void _toggleControlsVisibility() {
    if (_controlsVisible) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return hours > 0
        ? '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}'
        : '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Full-screen black background
      body: _errorMessage != null
          ? Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : _controller.value.isInitialized
              ? GestureDetector(
                  onTap: _toggleControlsVisibility,
                  child: Stack(
                    children: [
                      // Full-screen video
                      Center(
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                      // Controls overlay
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          color: Colors.black.withOpacity(0.5), // Semi-transparent background
                          child: SafeArea(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Top bar (e.g., back button)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.fullscreen, color: Colors.white),
                                        onPressed: () {
                                          // Fullscreen toggle (already fullscreen, could exit)
                                          Navigator.pop(context); // For simplicity, exits
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                // Center play/pause button
                                Center(
                                  child: IconButton(
                                    icon: Icon(
                                      _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                      color: Colors.white,
                                      size: 60,
                                    ),
                                    onPressed: _togglePlayPause,
                                  ),
                                ),
                                // Bottom controls
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      // Seek bar
                                      VideoProgressIndicator(
                                        _controller,
                                        allowScrubbing: true,
                                        colors: const VideoProgressColors(
                                          playedColor: Colors.red,
                                          bufferedColor: Colors.grey,
                                          backgroundColor: Colors.white24,
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      ),
                                      // Time display
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatDuration(_controller.value.position),
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                          Text(
                                            _formatDuration(_controller.value.duration),
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}