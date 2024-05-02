import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'chewie_video_player.dart';
import 'config.dart';

class VideoFeedsPage extends StatefulWidget {
  const VideoFeedsPage({
    super.key,
    required this.index,
  });

  final int index;

  @override
  State<VideoFeedsPage> createState() => _VideoFeedsPageState();
}

class _VideoFeedsPageState extends State<VideoFeedsPage> {
  PageController pageController = PageController();

  late int index = widget.index;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      pageController == PageController(initialPage: index);
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            launchUrl(
              Uri.parse(videoUrls[index]),
              mode: LaunchMode.externalApplication,
            );
          },
          child: Column(
            children: [
              const Text(
                'Feeds',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                videoUrls[index],
                maxLines: 2,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      body: PageView.builder(
        controller: pageController,
        itemCount: videoUrls.length,
        scrollDirection: Axis.vertical,
        onPageChanged: (val) {
          index = val;
          setState(() {});
        },
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ChewieVideoPlayerCard(
              url: videoUrls[index],
              autoPlayVideo: true,
              showControls: true,
              index: index,
              borderRadius: 0,
              manageIOSMultiPlayIssue: false,
            ),
          );
        },
      ),
    );
  }
}
