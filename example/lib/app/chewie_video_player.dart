import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ChewieVideoPlayerCard extends StatefulWidget {
  const ChewieVideoPlayerCard(
      {super.key,
      this.url,
      this.borderRadius,
      this.showController,
      this.aspectRatio,
      this.type,
      this.demoId,
      this.onCompleted,
      this.callVideoCount,
      this.autoPlayVideo,
      this.showControls});

  final double? aspectRatio;
  final String? url;
  final bool? type;
  final bool? showController;
  final bool? autoPlayVideo;
  final String? demoId;
  final VoidCallback? onCompleted;
  final double? borderRadius;
  final bool? callVideoCount;
  final bool? showControls;

  @override
  State<ChewieVideoPlayerCard> createState() => _ChewieVideoPlayerCardState();
}

class _ChewieVideoPlayerCardState extends State<ChewieVideoPlayerCard> {
  ChewieController? chewieController;
  late bool autoPlayVideo = widget.autoPlayVideo ?? false;
  late bool showControls = widget.showControls ?? true;

  late String? url = widget.url;
  late double? borderRadius = widget.borderRadius;

  @override
  void initState() {
    super.initState();
    initVideo();
  }

  @override
  void dispose() {
    super.dispose();
    disposeVideo();
    chewieController = null;
  }

  Future initVideo() async {
    disposeVideo();
    VideoPlayerController? videoPlayerController;
    if (url != null) {
      debugPrint('url $url');
      videoPlayerController = VideoPlayerController.networkUrl(Uri.parse('$url'));
    }

    await videoPlayerController?.initialize();
    if (videoPlayerController != null) {
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: autoPlayVideo,
        zoomAndPan: true,
        showOptions: false,
        allowMuting: false,
        draggableProgressBar: false,
        showControls: showControls,
        autoInitialize: true,
        allowPlaybackSpeedChanging: false,
        onTap: () {},
        customControls: const CupertinoControls(
          showSkipFrames: false,
        ),
        materialProgressColors: ChewieProgressColors(
          handleColor: Colors.green,
          playedColor: Colors.green,
          bufferedColor: Colors.green.withOpacity(0.3),
          backgroundColor: Colors.grey.withOpacity(0.3),
        ),
      );
      chewieController?.videoPlayerController.addListener(() {
        videoPlayerController?.value = videoPlayerController.value;
        if (videoPlayerController!.value.position >= videoPlayerController.value.duration) {
          widget.onCompleted?.call();
        }
      });

      setState(() {});
      // playVideo();
      // videoPlayerController?.addListener(() {
      //   if (videoPlayerController!.value.position >=
      //       videoPlayerController!.value.duration) {
      //     widget.onCompleted!();
      //   }
      //   if (context.mounted) {
      //     setState(() {});
      //   }
      // });
      // playVideo();
    }
  }

  Future toggleVideo() async {
    if (chewieController?.isPlaying == true) {
      await chewieController?.pause();
    } else {
      await chewieController?.play();
    }
  }

  Future disposeVideo() async {
    if (chewieController?.videoPlayerController.value.isInitialized == true) {
      chewieController?.videoPlayerController.removeListener(() {});
      await chewieController?.videoPlayerController.dispose();
    }

    chewieController?.videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const ObjectKey('chewieVideoManager'),
      onVisibilityChanged: (visibility) {
        var visiblePercentage = visibility.visibleFraction * 100;

        if (visibility.visibleFraction >= 0.80 && mounted && autoPlayVideo == true) {
          chewieController?.play();
        } else if (visibility.visibleFraction == 0) {
          chewieController?.pause();
        }

        debugPrint(
            'Video Player visibility  ${visibility.key} is $visiblePercentage% visible & ${visibility.visibleFraction}');
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 0),
          color: Colors.black,
        ),
        child: (chewieController?.videoPlayerController.value.isInitialized == true)
            ? GestureDetector(
                onTap: () {
                  if (showControls == false) {
                    toggleVideo();
                  }
                },
                child: AspectRatio(
                  aspectRatio: widget.aspectRatio ??
                      chewieController?.videoPlayerController.value.aspectRatio ??
                      16 / 9,
                  child: Chewie(
                    controller: chewieController!,
                  ),
                ),
              )
            : const AspectRatio(
                aspectRatio: 16 / 9,
                child: CupertinoActivityIndicator(radius: 18, color: Colors.white),
              ),
      ),
    );
  }
}
