import 'package:flutter/cupertino.dart';

import 'enums.dart';

class SwipeDeckController extends ChangeNotifier {
  SwipeState? state;

  //swipe the card by changing the status of the controller
  void swipe() {
    state = SwipeState.swipe;
    notifyListeners();
  }

  //swipe the card to the left side by changing the status of the controller
  void swipeLeft() {
    state = SwipeState.swipeLeft;
    notifyListeners();
  }

  //swipe the card to the right side by changing the status of the controller
  void swipeRight() {
    state = SwipeState.swipeRight;
    notifyListeners();
  }

  //calls unswipe the card by changing the status of the controller
  void unswipe() {
    state = SwipeState.unswipe;
    notifyListeners();
  }

  //swipe the card to the top by changing the status of the controller
  void swipeUp() {
    state = SwipeState.swipeUp;
    notifyListeners();
  }

  //swipe the card to the bottom by changing the status of the controller
  void swipeDown() {
    state = SwipeState.swipeDown;
    notifyListeners();
  }
}
