import 'package:dismissible_carousel_viewpager/dismissible_carousel_viewpager.dart';
import 'package:flutter/material.dart';

import 'base_page.dart';

/// DismissibleCarouselViewPager includes a good feature,
/// remove item page with dismissal animation while item page removed.
/// To config your dismissal style by [DismissalConfig]
class DismissalUsagePage extends BasePage {
  const DismissalUsagePage({Key? key}) : super(key: key);

  @override
  String get title => "Dismissal Usage";

  @override
  Widget get desc => RichText(
        text: const TextSpan(
            text:
                "A example to config the dismissal setting. \nDesign your dismissal style by ",
            style: TextStyle(color: Colors.grey, height: 1.52),
            children: [
              TextSpan(
                text: "[DismissalConfig]",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    height: 1.52,
                    color: Colors.grey),
              ),
              TextSpan(
                text: ".",
              ),
            ]),
      );

  @override
  State<StatefulWidget> createState() => _DismissalUsagePageState();
}

class _DismissalUsagePageState extends State<DismissalUsagePage> {
  final List<int> _item = List.generate(1000, (index) => index);

  bool _enable = true;

  /// you can customize the curve for dismissal animation
  final Curve _dismissalAnimationCurve = Curves.linear;

  /// you can customize the scale level for dismissal type 'Scale', see [DismissalType.scale]
  final double _scaleForDismissalTypeScale = 2;

  /// you can customize the center for dismissal type 'Circular Hide', see [DismissalType.circularHide]
  final Offset? _centerForDismissalTypeCircularHide = null;

  /// the duration of dismissal, default is 0.5s,  see [DismissalType.fadeOut], [DismissalType.slideOut], [DismissalType.scale] and [DismissalType.circularHide]
  Duration _dismissalDuration = const Duration(milliseconds: 500);

  /// you can add a delay between ending of dismissal animation and starting of fill gap animation, default is 0.1s, see [DismissalConfig.delayStartFillGap]
  Duration _delayStartFillGap = const Duration(milliseconds: 100);

  /// the duration of fill gap step, default os 0.4s, see [DismissalConfig.fillGapDuration]
  Duration _fillGapDuration = const Duration(milliseconds: 400);

  int _resetCnt = 0;

  static const String _nameDismissalTypeFadeOut = "Fade Out";
  static const String _nameDismissalTypeSlideOutUp = "Slide Out, up";
  static const String _nameDismissalTypeSlideOutLeft = "Slide Out, left";
  static const String _nameDismissalTypeSlideOutRight = "Slide Out, right";
  static const String _nameDismissalTypeSlideOutDown = "Slide Out, down";
  static const String _nameDismissalTypeScale = "Scale";
  static const String _nameDismissalTypeCircularHide = "Circular Hide";

  final Map<String, bool> _dismissalTypeOptionsStatus = {
    _nameDismissalTypeFadeOut: true,
    _nameDismissalTypeSlideOutUp: true,
    _nameDismissalTypeSlideOutLeft: false,
    _nameDismissalTypeSlideOutRight: false,
    _nameDismissalTypeSlideOutDown: false,
    _nameDismissalTypeScale: false,
    _nameDismissalTypeCircularHide: false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dismissal Usage"),
      ),
      body: Column(
        children: [
          Expanded(child: _viewPager),
          _options,
        ],
      ),
    );
  }

  Widget get _viewPager => DismissibleCarouselViewPager(
        key: ValueKey(_resetCnt),
        dismissalConfig: _dismissalConfig,
        viewportFraction: 0.5,
        besidePageScale: 0.8,
        itemBuilder: (context, index) => _tile(_item[index], () {
          setState(() {
            _item.removeAt(index);
          });
        }),
        itemCount: _item.length,
      );

  Widget get _options => ColoredBox(
        color: Colors.blueGrey.withOpacity(0.1),
        child: Column(
          children: [
            _enableOption(),
            _dismissalTypeOptions(),
            _dismissalDurationOption(),
            _fllGapDurationOption(),
            _delayStartFillGapDurationOption(),
          ],
        ),
      );

  /// dismissal configuration
  DismissalConfig get _dismissalConfig => DismissalConfig(
      enable: _enable,
      dismissalTypes: _createDismissalTypes(),
      delayStartFillGap: _delayStartFillGap,
      fillGapDuration: _fillGapDuration);

  List<DismissalType> _createDismissalTypes() =>
      _dismissalTypeOptionsStatus.keys.fold<List<DismissalType>>(
        <DismissalType>[],
        (previousValue, type) {
          DismissalType? dismissalType;
          bool enable = _dismissalTypeOptionsStatus[type]!;
          if (enable) {
            switch (type) {
              case _nameDismissalTypeFadeOut:
                {
                  dismissalType = DismissalType.fadeOut(
                    dismissalDuration: _dismissalDuration,
                    curve: _dismissalAnimationCurve,
                  );
                  break;
                }
              case _nameDismissalTypeSlideOutUp:
                {
                  dismissalType = DismissalType.slideOut(
                    slideOutDirection: SlideDirection.up,
                    dismissalDuration: _dismissalDuration,
                    curve: _dismissalAnimationCurve,
                  );
                  break;
                }
              case _nameDismissalTypeSlideOutLeft:
                {
                  dismissalType = DismissalType.slideOut(
                    slideOutDirection: SlideDirection.left,
                    dismissalDuration: _dismissalDuration,
                    curve: _dismissalAnimationCurve,
                  );
                  break;
                }
              case _nameDismissalTypeSlideOutRight:
                {
                  dismissalType = DismissalType.slideOut(
                    slideOutDirection: SlideDirection.right,
                    dismissalDuration: _dismissalDuration,
                    curve: _dismissalAnimationCurve,
                  );
                  break;
                }
              case _nameDismissalTypeSlideOutDown:
                {
                  dismissalType = DismissalType.slideOut(
                    slideOutDirection: SlideDirection.down,
                    dismissalDuration: _dismissalDuration,
                    curve: _dismissalAnimationCurve,
                  );
                  break;
                }
              case _nameDismissalTypeScale:
                {
                  dismissalType = DismissalType.scale(
                    scale: _scaleForDismissalTypeScale,
                    dismissalDuration: _dismissalDuration,
                    curve: _dismissalAnimationCurve,
                  );
                  break;
                }
              case _nameDismissalTypeCircularHide:
                {
                  dismissalType = DismissalType.circularHide(
                    center: _centerForDismissalTypeCircularHide,
                    dismissalDuration: _dismissalDuration,
                    curve: _dismissalAnimationCurve,
                  );
                  break;
                }
              default:
                throw ("Unknown Dismissal Type:$type");
            }
          }
          if (dismissalType != null) previousValue.add(dismissalType);
          return previousValue;
        },
      );

  /// remember add key when [DismissalConfig.enable] is true
  Widget _tile(Object data, VoidCallback onRemove) => Container(
        // add key to trigger dismissal animation
        // Recommend using Key(), ValueKey() or ObjectKey() with the data
        key: Key("$data"),
        //key: ValueKey(data),
        //key: ObjectKey(data),
        margin: const EdgeInsets.symmetric(horizontal: 21, vertical: 64),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.withOpacity(0.3)),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
                child: Container(
              alignment: Alignment.bottomCenter,
              child: Text("Item:$data"),
            )),
            Expanded(
                child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onRemove,
            )),
          ],
        ),
      );

  Widget _enableOption() => Row(
        children: [
          Checkbox(
              value: _enable,
              onChanged: (enable) {
                setState(() {
                  _enable = enable!;
                });
              }),
          InkWell(
            onTap: () {
              setState(() {
                _enable = !_enable;
              });
            },
            child: Text(
              "Enable Dismissal",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _enable ? Colors.green : Colors.red),
            ),
          ),
        ],
      );

  Widget _dismissalTypeOptions() {
    Widget _option(String key, bool enable) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
                value: enable,
                onChanged: (enable) {
                  setState(() {
                    _dismissalTypeOptionsStatus[key] = enable!;
                  });
                }),
            InkWell(
              onTap: () {
                setState(() {
                  _dismissalTypeOptionsStatus[key] =
                      !_dismissalTypeOptionsStatus[key]!;
                });
              },
              child: Text(
                key,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: enable ? Colors.green : Colors.red),
              ),
            ),
          ],
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _gapW(16),
            Text(
              "Dismissal Type",
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            )
          ],
        ),
        Wrap(
          children: [
            ..._dismissalTypeOptionsStatus.keys
                .map((key) => _option(key, _dismissalTypeOptionsStatus[key]!))
                .toList(),
            _gapW(16),
          ],
        )
      ],
    );
  }

  Widget _dismissalDurationOption() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _gapW(16),
            Text(
              "Dismissal animation:${_dismissalDuration.inMilliseconds / 1000} s",
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            )
          ],
        ),
        Slider(
          value: _dismissalDuration.inMilliseconds / 1000,
          max: 5,
          onChanged: (value) {
            setState(() {
              _dismissalDuration =
                  Duration(milliseconds: (value * 1000).toInt());
            });
          },
          onChangeEnd: (value) {
            setState(() {
              _resetCnt++;
            });
          },
        )
      ],
    );
  }

  Widget _fllGapDurationOption() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _gapW(16),
            Text(
              "Fill gap animation:${_fillGapDuration.inMilliseconds / 1000} s",
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            )
          ],
        ),
        Slider(
          value: _fillGapDuration.inMilliseconds / 1000,
          max: 5,
          onChanged: (value) {
            setState(() {
              _fillGapDuration = Duration(milliseconds: (value * 1000).toInt());
            });
          },
          onChangeEnd: (value) {
            setState(() {
              _resetCnt++;
            });
          },
        )
      ],
    );
  }

  Widget _delayStartFillGapDurationOption() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _gapW(16),
            Text(
              "Delay to start fill gap:${_delayStartFillGap.inMilliseconds / 1000} s",
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            )
          ],
        ),
        Slider(
          value: _delayStartFillGap.inMilliseconds / 1000,
          max: 5,
          onChanged: (value) {
            setState(() {
              _delayStartFillGap =
                  Duration(milliseconds: (value * 1000).toInt());
            });
          },
          onChangeEnd: (value) {
            setState(() {
              _resetCnt++;
            });
          },
        )
      ],
    );
  }

  Widget _gapW(double w) => SizedBox(
        width: w,
      );
}
