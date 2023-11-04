import 'dart:math';

import 'package:swipe_deck/types.dart';
import 'package:flutter/material.dart';

import 'controllers.dart';
import 'enums.dart';

export 'enums.dart';
export 'controllers.dart';
export 'types.dart';

class SwipeDeck extends StatefulWidget {
  /// widget builder for creating cards
  final CardsBuilder cardsBuilder;

  /// widget builder for creating cards
  final Widget? emptyCardsWidget;

  ///cards count
  final int cardsCount;

  /// controller to trigger unswipe action
  final SwipeDeckController? controller;

  /// duration of every animation
  final Duration duration;

  /// padding of the swiper
  final EdgeInsetsGeometry padding;

  /// maximum angle the card reaches while swiping
  final double maxAngle;

  /// set to true if verticalSwipe should be disabled, exception: triggered from the outside
  final SwipeDirections swipeDirections;

  /// threshold from which the card is swiped away
  final int threshold;

  /// set to true if swiping should be disabled, exception: triggered from the outside
  final bool isDisabled;

  /// set to false if unswipe should be disabled
  final bool allowUnswipe;

  /// set to true if you want to loop the items
  final bool loop;

  /// set to true if the user can unswipe as many cards as possible
  final bool unlimitedUnswipe;

  /// function that gets called with the new index and detected swipe direction when the user swiped or swipe is triggered by controller
  final OnSwipe? onSwipe;

  /// function that gets called when swipe ended
  final Function? onDragEnd;

  /// function that gets called when there is no widget left to be swiped away
  final VoidCallback? onEnd;

  /// function that gets called when the card is being dragged
  final Function(SwipeDirection direction, double x, double y)? onDrag;

  /// function that gets triggered when the swiper is disabled
  final VoidCallback? onTapDisabled;

  /// function that gets called with the boolean true when the last card gets unswiped and with the boolean false when there is no card to unswipe
  final OnUnSwipe? unswipe;

  /// direction in which the card gets swiped when triggered by controller, default set to right
  final SwipeDirection direction;

  /// index to start on
  final int initialIndex;

  /// initial swipe memo
  final Map<int, SwipeDirection> initialSwipeMemo;

  /// set this to false, if you want to allow only the swipe directions that are set in swipeDirections
  /// if set to true, the card can be dragged in any direction and will be swiped in the direction that is set in swipeDirections
  final bool lockDragToSwipeDirections;

  /// widget that gets wrapped around the card that is currently swiped
  final Function(
    Widget child,
    SwipeDirection direction,
    double x,
    double y,
  )? foregroundItemWrapper;

  final Function(Widget child)? backgroundItemWrapper;

  const SwipeDeck({
    Key? key,
    required this.cardsBuilder,
    required this.cardsCount,
    this.controller,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
    this.duration = const Duration(milliseconds: 200),
    this.maxAngle = 30,
    this.threshold = 50,
    this.isDisabled = false,
    this.loop = false,
    this.swipeDirections = SwipeDirections.allDirections,
    this.allowUnswipe = true,
    this.unlimitedUnswipe = false,
    this.onDragEnd,
    this.direction = SwipeDirection.right,
    this.onDrag,
    this.onTapDisabled,
    this.onSwipe,
    this.onEnd,
    this.unswipe,
    this.foregroundItemWrapper,
    this.backgroundItemWrapper,
    this.emptyCardsWidget,
    this.initialIndex = 0,
    this.initialSwipeMemo = const {},
    this.lockDragToSwipeDirections = false,
  })  : assert(maxAngle >= 0 && maxAngle <= 360),
        assert(threshold >= 1 && threshold <= 100),
        assert(direction != SwipeDirection.none),
        super(key: key);

  @override
  State createState() => _SwipeDeckState();
}

class _SwipeDeckState extends State<SwipeDeck>
    with SingleTickerProviderStateMixin {
  double _left = 0;
  double _top = 0;
  double _total = 0;
  double _angle = 0;
  double _maxAngle = 0;
  double _scale = 0.9;
  double _difference = 40;
  late int currentIndex;

  // keeps track of the swiped items to unswipe from the same direction
  late Map<int, SwipeDirection> _swiperMemo;

  int _swipeType = 0; // 1 = swipe, 2 = unswipe, 3 = goBack
  bool _tapOnTop = false; //position of starting drag point on card

  late AnimationController _animationController;
  late Animation<double> _leftAnimation;
  late Animation<double> _topAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _differenceAnimation;
  late Animation<double> _unSwipeLeftAnimation;
  late Animation<double> _unSwipeTopAnimation;

  bool _unSwiped =
      false; // set this to true when user swipe the card and false when they unswipe to make sure they unswipe only once

  bool _horizontal = false;
  bool _isUnswiping = false;
  int _swipedDirectionVertical = 0; //-1 left, 1 right
  int _swipedDirectionHorizontal = 0; //-1 bottom, 1 top

  SwipeDirection detectedDirection = SwipeDirection.none;

  int get _cardsCount => widget.cardsCount;

  @override
  void didUpdateWidget(SwipeDeck oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.cardsCount != oldWidget.cardsCount) {
      currentIndex = widget.initialIndex;
    }
  }

  _swipeListener() {
    if (widget.isDisabled) return;

    //swipe widget from the outside
    if (widget.controller!.state == SwipeState.swipe) {
      if (currentIndex < _cardsCount) {
        switch (widget.direction) {
          case SwipeDirection.right:
            _swipeHorizontal(context);
            break;
          case SwipeDirection.left:
            _swipeHorizontal(context);
            break;
          case SwipeDirection.top:
            _swipeVertical(context);
            break;
          case SwipeDirection.bottom:
            _swipeVertical(context);
            break;
          case SwipeDirection.none:
            break;
        }
        _animationController.forward();
      }
    } else if (widget.controller!.state == SwipeState.swipeLeft) {
      //swipe widget left from the outside
      if (currentIndex < _cardsCount) {
        _left = -1;
        _swipeHorizontal(context);
        _animationController.forward();
      }
    } else if (widget.controller!.state == SwipeState.swipeRight) {
      //swipe widget right from the outside
      if (currentIndex < _cardsCount) {
        _left = widget.threshold + 1;
        _swipeHorizontal(context);
        _animationController.forward();
      }
    } else if (widget.controller!.state == SwipeState.swipeUp) {
      //swipe widget up from the outside
      if (currentIndex < _cardsCount) {
        _top = -1;
        _swipeVertical(context);
        _animationController.forward();
      }
    } else if (widget.controller!.state == SwipeState.swipeDown) {
      //swipe widget down from the outside
      if (currentIndex < _cardsCount) {
        _top = widget.threshold + 1;
        _swipeVertical(context);
        _animationController.forward();
      }
    } else if (!widget.unlimitedUnswipe && _unSwiped) {
      return;
    } else if (widget.controller!.state == SwipeState.unswipe) {
      //unswipe widget from the outside
      if (widget.allowUnswipe) {
        if (!_isUnswiping) {
          if (currentIndex > 0) {
            _unswipe();
            widget.unswipe?.call(true);
            _animationController.forward();
          } else {
            widget.unswipe?.call(false);
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();

    currentIndex = widget.initialIndex;

    _swiperMemo = Map.from(widget.initialSwipeMemo);

    if (widget.controller != null) {
      widget.controller!.addListener(_swipeListener);
    }

    if (widget.maxAngle > 0) {
      _maxAngle = widget.maxAngle * (pi / 180);
    }

    _animationController =
        AnimationController(duration: widget.duration, vsync: this);
    _animationController.addListener(() {
      //when value of controller changes
      if (_animationController.status == AnimationStatus.forward) {
        setState(() {
          if (_swipeType != 2) {
            _left = _leftAnimation.value;
            _top = _topAnimation.value;
          }
          if (_swipeType == 2) {
            _left = _unSwipeLeftAnimation.value;
            _top = _unSwipeTopAnimation.value;
          }
          _scale = _scaleAnimation.value;
          _difference = _differenceAnimation.value;
        });
      }
    });

    _animationController.addStatusListener((status) {
      //when status of controller changes
      if (status == AnimationStatus.completed) {
        setState(() {
          if (_swipeType == 1) {
            _swiperMemo[currentIndex] = _horizontal
                ? (_swipedDirectionHorizontal == 1
                    ? SwipeDirection.right
                    : SwipeDirection.left)
                : (_swipedDirectionVertical == 1
                    ? SwipeDirection.top
                    : SwipeDirection.bottom);
            _swipedDirectionHorizontal = 0;
            _swipedDirectionVertical = 0;
            _horizontal = false;
            if (widget.loop) {
              if (currentIndex < _cardsCount - 1) {
                currentIndex++;
              } else {
                currentIndex = 0;
              }
            } else {
              currentIndex++;
            }
            widget.onSwipe?.call(currentIndex, detectedDirection);
            if (currentIndex == _cardsCount) {
              widget.onEnd?.call();
            }
          } else if (_swipeType == 2) {
            _isUnswiping = false;
          }
          _animationController.reset();
          _left = 0;
          _top = 0;
          _total = 0;
          _angle = 0;
          _scale = 0.9;
          _difference = 40;
          _swipeType = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();

    if (widget.controller != null) {
      widget.controller!.removeListener(_swipeListener);
    }
  }

  Widget _buildItem(BuildContext context, int index) {
    if (widget.emptyCardsWidget != null && index >= _cardsCount) {
      return widget.emptyCardsWidget!;
    }

    return widget.cardsBuilder(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              if (widget.loop || currentIndex < _cardsCount - 1)
                _backgroundItem(constraints),
              if (currentIndex < _cardsCount)
                _foregroundItem(constraints)
              else if (widget.emptyCardsWidget != null)
                widget.emptyCardsWidget!
            ],
          );
        },
      ),
    );
  }

  Widget _backgroundItem(BoxConstraints constraints) {
    final nextIndex = (currentIndex + 1) % _cardsCount;

    final item = Positioned(
      top: _difference,
      left: 0,
      child: Container(
        color: Colors.transparent,
        child: Transform.scale(
          scale: _scale,
          child: Container(
            constraints: constraints,
            child: _buildItem(context, nextIndex),
          ),
        ),
      ),
    );

    return widget.backgroundItemWrapper != null
        ? widget.backgroundItemWrapper!(item)
        : item;
  }

  Widget _foregroundItem(BoxConstraints constraints) {
    final item = Positioned(
      left: _left,
      top: _top,
      child: GestureDetector(
        child: Transform.rotate(
          angle: _angle,
          child: Container(
            constraints: constraints,
            child: _buildItem(context, currentIndex),
          ),
        ),
        onTap: () {
          if (widget.isDisabled) {
            widget.onTapDisabled?.call();
          }
        },
        onPanStart: (tapInfo) {
          if (!widget.isDisabled) {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            Offset position = renderBox.globalToLocal(tapInfo.globalPosition);

            if (position.dy < renderBox.size.height / 2) _tapOnTop = true;
          }
        },
        onPanUpdate: (tapInfo) {
          if (!widget.isDisabled) {
            setState(() {
              final swipeOption = widget.swipeDirections;
              switch (swipeOption) {
                case SwipeDirections.allDirections:
                  _left += tapInfo.delta.dx;
                  _top += tapInfo.delta.dy;
                  break;
                case SwipeDirections.horizontal:
                  _left += tapInfo.delta.dx;

                  if (!widget.lockDragToSwipeDirections) {
                    _top += tapInfo.delta.dy;
                  }
                  break;
                case SwipeDirections.vertical:
                  _top += tapInfo.delta.dy;

                  if (!widget.lockDragToSwipeDirections) {
                    _left += tapInfo.delta.dx;
                  }
                  break;
              }
              _total = _left + _top;

              widget.onDrag?.call(_swipedDirection(_left, _top), _left, _top);
              _calculateAngle();
              _calculateScale();
              _calculateDifference();
            });
          }
        },
        onPanEnd: (tapInfo) {
          if (!widget.isDisabled) {
            _tapOnTop = false;
            _onEndAnimation();
            _animationController.forward();
          }
        },
      ),
    );

    return widget.foregroundItemWrapper != null
        ? widget.foregroundItemWrapper!(
            item, _swipedDirection(_left, _top), _left, _top)
        : item;
  }

  void _calculateAngle() {
    if (_angle <= _maxAngle && _angle >= -_maxAngle) {
      (_tapOnTop == true)
          ? _angle = (_maxAngle / 100) * (_left / 10)
          : _angle = (_maxAngle / 100) * (_left / 10) * -1;
    }
  }

  void _calculateScale() {
    if (_scale <= 1.0 && _scale >= 0.9) {
      _scale =
          (_total > 0) ? 0.9 + (_total / 5000) : 0.9 + -1 * (_total / 5000);
    }
  }

  void _calculateDifference() {
    if (_difference >= 0 && _difference <= _difference) {
      _difference = (_total > 0) ? 40 - (_total / 10) : 40 + (_total / 10);
    }
  }

  void _onEndAnimation() {
    widget.onDragEnd?.call();

    if (_left < -widget.threshold || _left > widget.threshold) {
      _swipeHorizontal(context);
    } else if (_top < -widget.threshold || _top > widget.threshold) {
      _swipeVertical(context);
    } else {
      _goBack(context);
    }
  }

  //moves the card away to the left or right
  void _swipeHorizontal(BuildContext context) {
    _unSwiped = false;
    setState(() {
      _swipeType = 1;
      _leftAnimation = Tween<double>(
        begin: _left,
        end: (_left == 0)
            ? (widget.direction == SwipeDirection.right)
                ? MediaQuery.of(context).size.width
                : -MediaQuery.of(context).size.width
            : (_left > widget.threshold)
                ? MediaQuery.of(context).size.width
                : -MediaQuery.of(context).size.width,
      ).animate(_animationController);
      _topAnimation = Tween<double>(
        begin: _top,
        end: _top + _top,
      ).animate(_animationController);
      _scaleAnimation = Tween<double>(
        begin: _scale,
        end: 1.0,
      ).animate(_animationController);
      _differenceAnimation = Tween<double>(
        begin: _difference,
        end: 0,
      ).animate(_animationController);
    });
    if (_left > widget.threshold ||
        _left == 0 && widget.direction == SwipeDirection.right) {
      _swipedDirectionHorizontal = 1;
      detectedDirection = SwipeDirection.right;
    } else {
      _swipedDirectionHorizontal = -1;
      detectedDirection = SwipeDirection.left;
    }
    (_top <= 0) ? _swipedDirectionVertical = 1 : _swipedDirectionVertical = -1;
    _horizontal = true;
  }

  SwipeDirection _swipedDirection(double left, double top) {
    if (left == 0 && top == 0) return SwipeDirection.none;

    if (left > 0 || left == 0 && widget.direction == SwipeDirection.right) {
      return SwipeDirection.right;
    } else if (left < -0 ||
        left == 0 && widget.direction == SwipeDirection.left) {
      return SwipeDirection.left;
    } else if (top > 0 ||
        top == 0 && widget.direction == SwipeDirection.bottom) {
      return SwipeDirection.bottom;
    } else if (top < -0 || top == 0 && widget.direction == SwipeDirection.top) {
      return SwipeDirection.top;
    }

    return SwipeDirection.none;
  }

  //moves the card away to the top or bottom
  void _swipeVertical(BuildContext context) {
    _unSwiped = false;
    setState(() {
      _swipeType = 1;
      _leftAnimation = Tween<double>(
        begin: _left,
        end: _left + _left,
      ).animate(_animationController);
      _topAnimation = Tween<double>(
        begin: _top,
        end: (_top == 0)
            ? (widget.direction == SwipeDirection.bottom)
                ? MediaQuery.of(context).size.height
                : -MediaQuery.of(context).size.height
            : (_top > widget.threshold)
                ? MediaQuery.of(context).size.height
                : -MediaQuery.of(context).size.height,
      ).animate(_animationController);
      _scaleAnimation = Tween<double>(
        begin: _scale,
        end: 1.0,
      ).animate(_animationController);
      _differenceAnimation = Tween<double>(
        begin: _difference,
        end: 0,
      ).animate(_animationController);
    });
    if (_top > widget.threshold ||
        _top == 0 && widget.direction == SwipeDirection.bottom) {
      _swipedDirectionVertical = -1;
      detectedDirection = SwipeDirection.bottom;
    } else {
      _swipedDirectionVertical = 1;
      detectedDirection = SwipeDirection.top;
    }
    (_left >= 0)
        ? _swipedDirectionHorizontal = 1
        : _swipedDirectionHorizontal = -1;
  }

  //moves the card back to starting position
  void _goBack(BuildContext context) {
    setState(() {
      _swipeType = 3;
      _leftAnimation = Tween<double>(
        begin: _left,
        end: 0,
      ).animate(_animationController);
      _topAnimation = Tween<double>(
        begin: _top,
        end: 0,
      ).animate(_animationController);
      _scaleAnimation = Tween<double>(
        begin: _scale,
        end: 0.9,
      ).animate(_animationController);
      _differenceAnimation = Tween<double>(
        begin: _difference,
        end: 40,
      ).animate(_animationController);
    });
  }

  //unswipe the card: brings back the last card that was swiped away
  void _unswipe() {
    _unSwiped = true;
    _isUnswiping = true;
    if (widget.loop) {
      if (currentIndex == 0) {
        currentIndex = _cardsCount - 1;
      } else {
        currentIndex--;
      }
    } else {
      if (currentIndex > 0) {
        currentIndex--;
      }
    }
    _swipeType = 2;

    double? unSwipeLeftAnimationBeing;
    double? unSwipeLeftAnimationEnd;
    double? unSwipeTopAnimationBeing;
    double? unSwipeTopAnimationEnd;
    double scaleAnimationBeing = 1.0;
    double scaleAnimationEnd = _scale;
    double differenceAnimationBeing = 0;
    double differenceAnimationEnd = _difference;

    final SwipeDirection direction =
        _swiperMemo[currentIndex] ?? SwipeDirection.top;
    final swipedRight = direction == SwipeDirection.right;
    final swipedTop = direction == SwipeDirection.top;

    switch (direction) {
      case SwipeDirection.right:
      case SwipeDirection.left:
        unSwipeLeftAnimationBeing = (swipedRight)
            ? MediaQuery.of(context).size.width
            : -MediaQuery.of(context).size.width;
        unSwipeLeftAnimationEnd = 0;

        unSwipeTopAnimationBeing = MediaQuery.of(context).size.height / 4;
        unSwipeTopAnimationEnd = 0;
        break;

      case SwipeDirection.top:
      case SwipeDirection.bottom:
      default:
        unSwipeLeftAnimationBeing = -MediaQuery.of(context).size.width / 4;
        unSwipeLeftAnimationEnd = 0;

        unSwipeTopAnimationBeing = (swipedTop)
            ? -MediaQuery.of(context).size.height
            : MediaQuery.of(context).size.height;
        unSwipeTopAnimationEnd = 0;
        break;
    }

    _unSwipeLeftAnimation = Tween<double>(
      begin: unSwipeLeftAnimationBeing,
      end: unSwipeLeftAnimationEnd,
    ).animate(_animationController);
    _unSwipeTopAnimation = Tween<double>(
      begin: unSwipeTopAnimationBeing,
      end: unSwipeTopAnimationEnd,
    ).animate(_animationController);
    _scaleAnimation = Tween<double>(
      begin: scaleAnimationBeing,
      end: scaleAnimationEnd,
    ).animate(_animationController);
    _differenceAnimation = Tween<double>(
      begin: differenceAnimationBeing,
      end: differenceAnimationEnd,
    ).animate(_animationController);

    setState(() {});
  }
}
