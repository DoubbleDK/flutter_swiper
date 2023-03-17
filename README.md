`swipe_deck` is a Flutter package for a Tinder Card Swiper. ✨

It allows swiping in all directions with any widget as a card.

Very smooth animations supporting Android, iOS & WebApp.

## Features

### Trigger swipe up and swipe down through controller

You can now trigger swipe up and swipe down with our `SwipeDeckController` regardless of the chosen `SwipeDirection` (which is still used when `swipe` is called through the controller). Just like the swipeLeft and swipeRight call, you can call `swipeUp` or `swipeDown` through the controller anywhere you want.

### Restrict horizontal or vertical swipe

You can now restrict the swipe in either horizontal directions or vertical directions using `swipeOptions` property.

### Set looping for card swipe

Now you can set the `loop` property to `true` and make the list infinitely scrollable.

### Update the cards while swiping

In this version we have replaced the list of cards with `cardsBuilder`. Now the widget only renders two cards at a time which makes it lightweight and scalable. So you can perform operations on your card anytime.

## Show Cases

<img src="https://github.com/appinioGmbH/flutter_packages/blob/main/assets/swiper/swiping.gif?raw=true" height="250" /> <img src="https://github.com/appinioGmbH/flutter_packages/blob/main/assets/swiper/swipe_button.gif?raw=true" height="250" />

Trigger swipe right and swipe left however you want...

<img src="https://github.com/appinioGmbH/flutter_packages/blob/main/assets/swiper/swipe_left_right.gif?raw=true" height="250" />

Unswipe the cards however you want...

<img src="https://github.com/appinioGmbH/flutter_packages/blob/main/assets/swiper/unswipe.gif?raw=true" height="250" />

Customize the angle...

<img src="https://github.com/appinioGmbH/flutter_packages/blob/main/assets/swiper/angle.gif?raw=true" height="250" />

Customize the threshold of the swiper, when the card should slide away...

<img src="https://github.com/appinioGmbH/flutter_packages/blob/main/assets/swiper/treshold.gif?raw=true" height="250" />

## Installation

Create a new project with the command

```yaml
flutter create MyApp
```

Add

```yaml
swipe_deck: ...
```

to your `pubspec.yaml` of your flutter project.
**OR**
run

```yaml
flutter pub add swipe_deck
```

in your project's root directory.

In your library add the following import:

```dart
import 'package:swipe_deck/swipe_deck.dart';
```

For help getting started with Flutter, view the online [documentation](https://flutter.io/).

## Usage

You can place your `SwipeDeck` inside of a `Scaffold` or `CupertinoPageScaffold` like we did here. Optional parameters can be defined to enable different features. See the following example..

```dart
import 'package:swipe_deck/swipe_deck.dart';
import 'package:flutter/cupertino.dart';

class Example extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: SwipeDeck(
          cardsCount: 10,
          cardsBuilder: (BuildContext context,int index){
            return Container(
              alignment: Alignment.center,
              child: const Text(index.toString()),
              color: CupertinoColors.activeBlue,
            );
          },
        ),
      ),
    );
  }
}
```

## Constructor

#### Basic

| Parameter             | Default                                            | Description                                                                                                                 | Required |
| --------------------- | :------------------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------- | :------: |
| cardsCount            | -                                                  | Number of cards you want to render                                                                                          |   true   |
| cardsBuilder          | -                                                  | Callback of the type CardsBuilder                                                                                           |   true   |
| swipeOptions          | -                                                  | value of type SwipeDirectionOptions to restrict swipes                                                                      |  false   |
| controller            | -                                                  | Trigger unswipe                                                                                                             |  false   |
| padding               | EdgeInsets.symmetric(horizontal: 20, vertical: 25) | Control swiper padding                                                                                                      |  false   |
| duration              | 200 milliseconds                                   | The duration that every animation should last                                                                               |  false   |
| maxAngle              | 30                                                 | Maximum angle the card reaches while swiping                                                                                |  false   |
| threshold             | 50                                                 | Threshold from which the card is swiped away                                                                                |  false   |
| isDisabled            | false                                              | Set to `true` if swiping should be disabled, has no impact when triggered from the outside                                  |  false   |
| onTapDisabled         | -                                                  | Function that get triggered when the swiper is disabled                                                                     |  false   |
| onSwipe               | -                                                  | Called with the new index and detected swipe direction when the user swiped                                                 |  false   |
| onEnd                 | -                                                  | Called when there is no Widget left to be swiped away                                                                       |  false   |
| direction             | right                                              | Direction in which the card is swiped away when triggered from the outside                                                  |  false   |
| allowUnswipe          | true                                               | Set to `false` if unswipe should be disabled away                                                                           |  false   |
| unlimitedUnswipe      | false                                              | Set to `true` if the user can unswipe as many cards as possible                                                             |  false   |
| unswipe               | -                                                  | Called with the boolean `true` when the last card gets unswiped and with the boolean `false` if there is no card to unswipe |  false   |
| onDrag                | null                                               | A callback when dragging: (double x, double y)                                                                              |  false   |
| onDragEnd             | null                                               | A callback when dragging ends                                                                                               |  false   |
| foregroundItemWrapper | null                                               | Wrap your foreground item: (child, direction, x, y), should return a Widget                                                 |  false   |
| backgroundItemWrapper | null                                               | Wrap your background item: (child), should return a Widget                                                                  |  false   |

#### Controller

The `Controller` is used to control the `swipe`, `swipeLeft`, `swipeRight`, `swipeUp`, `swipeDown` or `unswipe` function of the swiper from outside of the widget. You can create a controller called `SwipeDeckController` and save the instance for further usage. Please have a closer look to our Example for the usage.

| Method     | Description                                                                                        |
| ---------- | :------------------------------------------------------------------------------------------------- |
| swipe      | Changes the state of the controller to swipe and swipes the card in your selected direction.       |
| swipeLeft  | Changes the state of the controller to swipe left and swipes the card to the left side.            |
| swipeRight | Changes the state of the controller to swipe right and swipes the card to the right side.          |
| swipeUp    | Changes the state of the controller to swipe up and swipes the card to the up side.                |
| swipeDown  | Changes the state of the controller to swipe down and swipes the card to the down side.            |
| unswipe    | Changes the state of the controller to unswipe and brings back the last card that was swiped away. |

#### Credits

- Mattias Fjellvang (package maintainer)
- Appinio GmbH (original project creator)
