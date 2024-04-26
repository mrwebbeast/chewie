import 'package:chewie_example/app/app.dart';
import 'package:chewie_example/controller/feeds_controller.dart';
import 'package:flutter/material.dart';

import 'app/multiple_videos.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => FeedsController()),
        ],
        child: VideoFeedScreen(),
      ),
    ),
  );
}
