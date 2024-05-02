import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../controller/feeds_controller.dart';

class ChewieVideoPlayerCard extends StatefulWidget {
  const ChewieVideoPlayerCard(
      {super.key,
      this.url,
      this.borderRadius,
      this.manageAspectRatio,
      this.type,
      this.demoId,
      this.onCompleted,
      this.callVideoCount,
      this.autoPlayVideo,
      this.showControls,
      this.index,
      this.manageIOSMultiPlayIssue = true});

  final int? index;
  final bool? manageAspectRatio;
  final String? url;
  final bool? type;

  final bool? autoPlayVideo;
  final String? demoId;
  final VoidCallback? onCompleted;
  final double? borderRadius;
  final bool? callVideoCount;
  final bool? showControls;
  final bool? manageIOSMultiPlayIssue;

  @override
  State<ChewieVideoPlayerCard> createState() => _ChewieVideoPlayerCardState();
}

class _ChewieVideoPlayerCardState extends State<ChewieVideoPlayerCard> with AutomaticKeepAliveClientMixin {
  late int? index = widget.index;
  ChewieController? chewieController;
  late bool autoPlayVideo = widget.autoPlayVideo ?? false;
  late bool showControls = widget.showControls ?? true;
  late bool manageIOSMultiPlayIssue = widget.manageIOSMultiPlayIssue ?? true;

  late String? url = widget.url;
  late double? borderRadius = widget.borderRadius;

  @override
  void initState() {
    initVideo(context: context);
    super.initState();
  }

  @override
  void dispose() {
    disposeVideo();
    super.dispose();
  }

  VideoPlayerController? videoPlayerController;

  Future initVideo({required BuildContext context}) async {
    disposeVideo();
    if (url != null) {
      debugPrint('Video Url :- $url');
      videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse('$url'),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false, allowBackgroundPlayback: false),
      );

      await videoPlayerController?.initialize();
      if (videoPlayerController != null) {
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController!,
          autoPlay: autoPlayVideo,
          zoomAndPan: true,
          showOptions: false,
          allowMuting: false,
          draggableProgressBar: false,
          showControls: showControls,
          autoInitialize: true,
          onTap: () {
            // debugPrint('Video Player onTap Index $index');
            FeedsController feedsController = Provider.of<FeedsController>(context, listen: false);
            feedsController.setActiveFeedVideoIndex(index);
          },
          allowPlaybackSpeedChanging: false,
          customControls: const CupertinoControls(showSkipFrames: false),
        );
      }
      setState(() {});
      chewieController?.videoPlayerController.addListener(() {
        // debugPrint('Video Player Listener Index $index');
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          FeedsController feedsController = Provider.of<FeedsController>(context, listen: false);

          if (chewieController?.isPlaying == true) {
            if (isVisible && feedsController.activeFeedVideoIndex == index) {
              feedsController.setActiveFeedVideoIndex(index);
            }

            if (manageIOSMultiPlayIssue ? (feedsController.activeFeedVideoIndex != index) : false) {
              chewieController?.pause();
            }
          }
        });

        videoPlayerController = chewieController?.videoPlayerController;
        Duration initialDuration = const Duration(milliseconds: 0);
        if (videoPlayerController!.value.position != initialDuration &&
            videoPlayerController!.value.position >=
                (videoPlayerController?.value.duration ?? initialDuration)) {
          widget.onCompleted?.call();
        }
      });

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

  bool isVisible = false;

  Future toggleVideo() async {
    FeedsController feedsController = Provider.of<FeedsController>(context, listen: false);
    if (chewieController?.isPlaying == true) {
      await chewieController?.pause();
    } else {
      feedsController.setActiveFeedVideoIndex(index);
      chewieController?.play();
    }
  }

  Future disposeVideo() async {
    videoPlayerController?.removeListener(() {});
    chewieController?.removeListener(() {});
    videoPlayerController?.dispose();
    chewieController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<FeedsController>(
      builder: (context, controller, child) {
        return VisibilityDetector(
          key: Key('chewieVideoManager_${index ?? 0}'),
          onVisibilityChanged: (visibility) {
            var visiblePercentage = visibility.visibleFraction * 100;
            if (context.mounted) {
              if (visibility.visibleFraction >= 0.80 && mounted) {
                isVisible = true;
                if (autoPlayVideo == true) {
                  chewieController?.play();
                }
              } else {
                isVisible = false;
                chewieController?.pause();
              }
              setState(() {});
            }

            debugPrint('Video Player Index $index visibility $isVisible => $visiblePercentage% ');
          },
          child: IgnorePointer(
            ignoring: isVisible ? false : true,
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
                        aspectRatio: getAspectRatio(),
                        child: Chewie(
                          key: Key('chewieVideoPlayer_${index ?? 0}'),
                          controller: chewieController!,
                        ),
                      ),
                    )
                  : const AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CupertinoActivityIndicator(radius: 18, color: Colors.white),
                    ),
            ),
          ),
        );
      },
    );
  }

  double getAspectRatio() {
    double? aspectRatio;

    double? videoAspectRatio = chewieController?.videoPlayerController.value.aspectRatio;
    double defaultAspectRatio = 16 / 9;
    debugPrint('videoAspectRatio $videoAspectRatio');

    if (widget.manageAspectRatio == true) {
      if ((videoAspectRatio ?? 0) <= 0.60) {
        aspectRatio = videoAspectRatio;
      } else {
        aspectRatio = defaultAspectRatio;
      }
    } else {
      aspectRatio = videoAspectRatio;
    }
    return aspectRatio ?? defaultAspectRatio;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
