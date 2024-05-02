import 'package:chewie_example/app/video_feeds_pages.dart';
import 'package:flutter/material.dart';

import 'chewie_video_player.dart';
import 'config.dart';
import 'video_player_widget.dart'; // Assuming your VideoPlayerWidget is in a separate file

class VideoFeedsList extends StatelessWidget {
  const VideoFeedsList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Feed List'),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: videoUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (builder) => VideoFeedsPage(index: index)));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ChewieVideoPlayerCard(
                      url: videoUrls[index],
                      autoPlayVideo: true,
                      showControls: true,
                      index: index,
                      borderRadius: 0,
                      manageIOSMultiPlayIssue: false,
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.green,
                    ),
                    child: const Row(
                      children: [
                        Text("View Details"),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
