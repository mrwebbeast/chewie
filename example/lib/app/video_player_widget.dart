import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  ChewieController? _chewieController;
  final _activePlayerController = ValueNotifier<ChewieController?>(null);

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    final videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    await videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true, // Don't autoplay initially
      looping: true,
      errorBuilder: (context, error) => Center(child: Text('Error: $error')),
    );
    playVideo();

    setState(() {});
  }

  void playVideo() {
    // Pause any currently playing video
    _activePlayerController.value?.pause();
    _activePlayerController.value = _chewieController;
    _chewieController?.play();
  }

  @override
  void dispose() {
    _activePlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: playVideo,
      child: _chewieController != null
          ? AspectRatio(
              aspectRatio: _chewieController!.videoPlayerController.value.aspectRatio,
              child: Chewie(
                controller: _chewieController!,
              ),
            )
          : const CircularProgressIndicator(),
    );
  }
}
