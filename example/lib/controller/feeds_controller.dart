import 'package:flutter/cupertino.dart';

class FeedsController extends ChangeNotifier{
  int? activeFeedVideoIndex = 0;

  setActiveFeedVideoIndex(int? index) {
    activeFeedVideoIndex = index;
    notifyListeners();
  }
}