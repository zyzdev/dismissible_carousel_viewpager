import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

part 'config/dismissible_config.dart';

part 'transition/page_dismissible_transition.dart';

typedef ViewPagerCreatedCallback = void Function(PageController controller);

/// FlutterCarouselViewPager is a view pager that scrolling like a carousel
/// Another two features of FlutterCarouselViewPager are item dismissal animation and item fill vacancies animation while item was removed
/// [dismissDirection] and [dismissalDuration] control the direction and the duration of item dismissal animation
class DismissibleCarouselViewPager extends StatefulWidget {
  /// Controls whether the widget's pages will respond to
  /// [RenderObject.showOnScreen], which will allow for implicit accessibility
  /// scrolling.
  ///
  /// With this flag set to false, when accessibility focus reaches the end of
  /// the current page and the user attempts to move it to the next element, the
  /// focus will traverse to the next widget outside of the page view.
  ///
  /// With this flag set to true, when accessibility focus reaches the end of
  /// the current page and user attempts to move it to the next element, focus
  /// will traverse to the next page in the page view.
  final bool allowImplicitScrolling;

  /// {@macro flutter.widgets.scrollable.restorationId}
  final String? restorationId;

  /// The axis along which the page view scrolls.
  ///
  /// Defaults to [Axis.horizontal].
  final Axis scrollDirection;

  /// Whether the page view scrolls in the reading direction.
  ///
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the page view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  ///
  /// Similarly, if [scrollDirection] is [Axis.vertical], then the page view
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  final bool reverse;

  /// How the page view should respond to user input.
  ///
  /// For example, determines how the page view continues to animate after the
  /// user stops dragging the page view.
  ///
  /// The physics are modified to snap to page boundaries using
  /// [PageScrollPhysics] prior to being used.
  ///
  /// If an explicit [ScrollBehavior] is provided to [scrollBehavior], the
  /// [ScrollPhysics] provided by that behavior will take precedence after
  /// [physics].
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics? physics;

  /// Set to false to disable page snapping, useful for custom scroll behavior.
  ///
  /// If the [padEnds] is false and [PageController.viewportFraction] < 1.0,
  /// the page will snap to the beginning of the viewport; otherwise, the page
  /// will snap to the center of the viewport.
  final bool pageSnapping;

  /// feedback the [PageController]
  final ViewPagerCreatedCallback? onPagerCreated;

  /// Called whenever the page in the center of the viewport changes.
  final ValueChanged<int>? onPageChanged;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  /// {@macro flutter.widgets.shadow.scrollBehavior}
  ///
  /// [ScrollBehavior]s also provide [ScrollPhysics]. If an explicit
  /// [ScrollPhysics] is provided in [physics], it will take precedence,
  /// followed by [scrollBehavior], and then the inherited ancestor
  /// [ScrollBehavior].
  ///
  /// The [ScrollBehavior] of the inherited [ScrollConfiguration] will be
  /// modified by default to not apply a [Scrollbar].
  final ScrollBehavior? scrollBehavior;

  /// Whether to add padding to both ends of the list.
  ///
  /// If this is set to true and [PageController.viewportFraction] < 1.0, padding will be added
  /// such that the first and last child slivers will be in the center of
  /// the viewport when scrolled all the way to the start or end, respectively.
  ///
  /// If [PageController.viewportFraction] >= 1.0, this property has no effect.
  ///
  /// This property defaults to true and must not be null.
  final bool padEnds;

  /// same as [PageController.initialPage].
  final int initialPage;

  /// same as [PageController.keepPage].
  final bool keepPage;

  /// viewport fraction of each page, default to 0.5
  /// range, 0 < viewportFraction <= 1.0
  final double viewportFraction;

  /// scale of beside pages based on selected page, default to 0.8
  /// range, 0 < [besidePageScale] <= 1.0
  /// ex: 1.0 means same size of selected page, 0.5 means 50% size of selected page
  final double besidePageScale;

  /// item count
  final int? itemCount;

  /// item builder
  final IndexedWidgetBuilder itemBuilder;

  /// page dismissal config, for page dismissal animation
  /// it worked when page removed
  final DismissalConfig? dismissalConfig;

  DismissibleCarouselViewPager({
    Key? key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    this.itemCount,
    required this.itemBuilder,
    this.dragStartBehavior = DragStartBehavior.start,
    this.allowImplicitScrolling = false,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.scrollBehavior,
    this.padEnds = true,
    this.initialPage = 0,
    this.keepPage = true,
    this.viewportFraction = 0.5,
    this.besidePageScale = 0.8,
    this.dismissalConfig,
    this.onPagerCreated,
  })
      : assert(viewportFraction > 0 && viewportFraction <= 1),
        super(key: key);

  @override
  State<DismissibleCarouselViewPager> createState() =>
      _DismissibleCarouselViewPagerState();
}

class _DismissibleCarouselViewPagerState
    extends State<DismissibleCarouselViewPager>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  PageController? _controller;
  PageController get controller => _controller!;

  int? _itemCount;

  int? get _realItemCount => widget.itemCount;

  bool _shouldFindDeletedIndex = false;
  bool _lastItemDeleted = false;

  /// for special case, last item was deleted
  bool _skipAnimation = false;

  /// for special case, last item was deleted
  late AnimationController _skipAC;

  int? _deletedIndex;

  final Map<int, Key?> _preItemKeys = {};
  final Map<int, Size> _itemSize = {};

  Size? _pageSize;

  DismissalConfig get _dismissalConfig => widget.dismissalConfig!;

  @override
  void initState() {
    _skipAC =
        AnimationController(
            duration: const Duration(milliseconds: 1), vsync: this);
    _itemCount = _realItemCount;
    _currentIndex = widget.initialPage;
    _setUpController();
    super.initState();
  }

  void _setUpController() {
    _controller = PageController(
      initialPage: widget.initialPage,
      keepPage: widget.keepPage,
      viewportFraction: widget.viewportFraction,
    );
    SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
      widget.onPagerCreated?.call(_controller!);
    });
  }

  @override
  void dispose() {
    _skipAC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      PageView.builder(
          scrollDirection: widget.scrollDirection,
          reverse: widget.reverse,
          physics: widget.physics,
          pageSnapping: widget.pageSnapping,
          dragStartBehavior: widget.dragStartBehavior,
          allowImplicitScrolling: widget.allowImplicitScrolling,
          restorationId: widget.restorationId,
          clipBehavior: widget.clipBehavior,
          scrollBehavior: widget.scrollBehavior,
          padEnds: widget.padEnds,
          controller: _controller,
          itemCount: _itemCount,
          onPageChanged: (index) {
            widget.onPageChanged?.call(index);
            _currentIndex = index;
          },
          itemBuilder: (context, index) => _itemBuilder(index));

  @override
  void didUpdateWidget(DismissibleCarouselViewPager oldWidget) {
    if (widget.itemCount != null) {
      if (oldWidget.itemCount != widget.itemCount) {
        // last item was deleted
        if (_currentIndex == widget.itemCount) {
          _itemCount = oldWidget.itemCount;
          _deletedIndex = _currentIndex;
          _lastItemDeleted = true;
          _shouldFindDeletedIndex = false;
          _currentIndex = min(_currentIndex, widget.itemCount! - 1);
        } else {
          _itemCount = widget.itemCount;
          _deletedIndex = null;
          _lastItemDeleted = false;
          _shouldFindDeletedIndex = true;
        }
      }
    }
    if (widget.initialPage != oldWidget.initialPage ||
        widget.keepPage != oldWidget.keepPage ||
        widget.viewportFraction != oldWidget.viewportFraction) {
      _setUpController();
    }
    super.didUpdateWidget(oldWidget);
  }

  Widget _itemBuilder(int index) {
    bool dismissalEnable = widget.dismissalConfig?.enable ?? false;

    double scaleDiff = 1 - widget.besidePageScale;
    Widget content;
    if (widget.itemCount != null) {
      if (!_lastItemDeleted) {
        content = widget.itemBuilder(context, index);
      } else {
        int fakeIndex = index - 1;
        if (fakeIndex < 0) {
          content = const SizedBox(
            key: Key("fake"),
          );
        } else {
          content = widget.itemBuilder(context, fakeIndex);
        }
      }
    } else {
      content = widget.itemBuilder(context, index);
    }

    Key? preKey = _preItemKeys[index];
    Key? contentKey = content.key != null ? ValueKey(content.key) : null;

    if (dismissalEnable) {
      assert(content.key !=
          null, "Dismissal effect not work! To enable dismissible, remember feed special [key] to your widget that created by [DismissibleCarouselViewPager.itemBuilder]!");
      if (_shouldFindDeletedIndex) {
        if (preKey != null && content.key != null) {
          if (preKey != contentKey) {
            _deletedIndex = index;
            _shouldFindDeletedIndex = false;
          }
        }
      }
      _preItemKeys[index] = contentKey;

      // get content size
      content = _SizeProviderWidget(
        child: content,
        onChildSize: (size) {
          _itemSize[index] = size;
        },
      );
    }
    Widget child = AnimatedBuilder(
      key: dismissalEnable ? contentKey : null,
      animation: controller,
      builder: (context, child) {
        double value;
        if (controller.position.haveDimensions) {
          if (!_skipAnimation) {
            value = controller.page! - index;
            value = (1 - (value.abs() * scaleDiff)).clamp(0.0, 1.0);
          } else {
            value = index == _currentIndex ? 1 : widget.besidePageScale;
          }
        } else {
          // for init
          value = index == _currentIndex ? 1 : widget.besidePageScale;
        }
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Center(
        child: content,
      ),
    );

    if (dismissalEnable) {
      Duration animationDuration =
          _dismissalConfig.longestDismissalDuration +
              _dismissalConfig.delayStartFillGap +
              _dismissalConfig.fillGapDuration;
      child = AnimatedSwitcher(
        duration: animationDuration,
        layoutBuilder: _skipAnimation
            ? (currentChild, previousChildren) {
          return currentChild ?? const SizedBox();
        }
            : AnimatedSwitcher.defaultLayoutBuilder,
        transitionBuilder: (Widget child, Animation<double> animation) {
          Widget child1() {
            if (_pageSize == null) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  _pageSize = Size(constraints.maxWidth, constraints.maxHeight);
                  return _PageDismissalTransition(
                    index: index,
                    currentIndex: _currentIndex,
                    deletedIndex: _deletedIndex,
                    lastItemDeleted: _lastItemDeleted,
                    skipAnimation: _skipAnimation,
                    animation: animation,
                    besideWidgetScale: widget.besidePageScale,
                    reverse: widget.reverse,
                    scrollDirection: widget.scrollDirection,
                    dismissalConfig: _dismissalConfig,
                    child: child,
                    contentSize: _itemSize[index],
                    pageSize: _pageSize!,
                  );
                },
              );
            }
            return _PageDismissalTransition(
              index: index,
              currentIndex: _currentIndex,
              deletedIndex: _deletedIndex,
              lastItemDeleted: _lastItemDeleted,
              skipAnimation: _skipAnimation,
              animation: _skipAnimation ? _skipAC : animation,
              besideWidgetScale: widget.besidePageScale,
              reverse: widget.reverse,
              scrollDirection: widget.scrollDirection,
              dismissalConfig: _dismissalConfig,
              child: child,
              contentSize: _itemSize[index],
              pageSize: _pageSize!,
              onEnd:
              _lastItemDeleted || (_skipAnimation && index == _currentIndex)
                  ? () {
                if (_lastItemDeleted) {
                  _lastItemDeleted = false;
                  SchedulerBinding.instance
                      ?.addPostFrameCallback((timeStamp) {
                    setState(() {
                      _itemCount = widget.itemCount;
                      _skipAnimation = true;
                      _skipAC.forward(from: 0);
                    });
                  });
                } else if (_skipAnimation && index == _currentIndex) {
                  _skipAnimation = false;
                }
              }
                  : null,
            );
          }

          return child1();
        },
        child: child,
      );
    }
    return child;
  }
}

class _SizeProviderWidget extends StatefulWidget {
  final Widget child;
  final Function(Size) onChildSize;

  const _SizeProviderWidget(
      {Key? key, required this.onChildSize, required this.child})
      : super(key: key);

  @override
  _SizeProviderWidgetState createState() => _SizeProviderWidgetState();
}

class _SizeProviderWidgetState extends State<_SizeProviderWidget> {
  @override
  void initState() {
    ///add size listener for first build
    _onResize();
    super.initState();
  }

  void _onResize() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (mounted) {
        if (context.size is Size) {
          widget.onChildSize(context.size!);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ///add size listener for every build uncomment the fallowing
    ///_onResize();
    return widget.child;
  }
}
