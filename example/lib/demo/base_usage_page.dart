import 'package:dismissible_carousel_viewpager/dismissible_carousel_viewpager.dart';
import 'package:flutter/material.dart';

import 'base_page.dart';

class BaseUsagePage extends BasePage {
  @override
  String get title => "Base Usage";

  @override
  Widget get desc => RichText(
        text: const TextSpan(
          text: "A example to demo the base usage.",
          style: TextStyle(color: Colors.grey, height: 1.52),
        ),
      );

  const BaseUsagePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BaseUsagePageState();
}

class _BaseUsagePageState extends State<BaseUsagePage> {
  final List<int> _item = List.generate(1000, (index) => index);
  bool _reverse = false;
  double _viewportFraction = 0.5;
  double _besidePageScale = 0.8;
  Axis _scrollDirection = Axis.horizontal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Base Usage"),
      ),
      body: Column(
        children: [
          Expanded(child: _viewPager),
          _options,
        ],
      ),
    );
  }

  Widget get _viewPager =>
      DismissibleCarouselViewPager(
        viewportFraction: 0.5,
        besidePageScale: 0.8,
        itemBuilder: (context, index) {
          return Container(
            alignment: Alignment.center,
            color: index.isEven
                ? Colors.blueAccent.withOpacity(0.1)
                : Colors.deepPurpleAccent.withOpacity(0.1),
            child: Text("Item:$index"),
          );
        },
        itemCount: 100,
      );
/*      DismissibleCarouselViewPager(
        /// width of selected page is half of screen width
        viewportFraction: _viewportFraction,

        /// width of beside page is width of selected page * _besidePageScale
        besidePageScale: _besidePageScale,

        /// scroll direction
        scrollDirection: _scrollDirection,

        /// reverse the direction
        reverse: _reverse,

        initialPage: 3,

        onPagerCreated: (controller) {
          debugPrint("onPagerCreated, page controller is ready.");
        },
        onPageChanged: (index) {
          debugPrint("Current selected page index:$index");
        },

        itemBuilder: (context, index) => Container(
          alignment: Alignment.center,
          color: index.isEven
              ? Colors.blueAccent.withOpacity(0.1)
              : Colors.deepPurpleAccent.withOpacity(0.1),
          child: Text("Item:${_item[index]}"),
        ),
        itemCount: _item.length,
      );*/

  Widget get _options => ColoredBox(
        color: Colors.blueGrey.withOpacity(0.1),
        child: Column(
          children: [
            _reverseOption(),
            _viewportFractionOption(),
            _besidePageScaleOption(),
            _scrollDirectionOption(),
          ],
        ),
      );

  Widget _reverseOption() => Row(
    children: [
      Checkbox(
          value: _reverse,
          onChanged: (_reverse) {
            setState(() {
              _reverse = _reverse!;
            });
          }),
      InkWell(
        onTap: () {
          setState(() {
            _reverse = !_reverse;
          });
        },
        child: Text(
          "Reverse",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _reverse ? Colors.green : Colors.red),
        ),
      ),
    ],
  );

  Widget _viewportFractionOption() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _gapW(16),
            Text(
              "Viewport Fraction:$_viewportFraction",
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            )
          ],
        ),
        Slider(
          value: _viewportFraction,
          min: 0.1,
          max: 1,
          onChanged: (value) {
            setState(() {
              _viewportFraction = double.parse(value.toStringAsFixed(2));
            });
          },
          onChangeEnd: (value) {
            setState(() {
              _viewportFraction = double.parse(value.toStringAsFixed(2));
            });
          },
        )
      ],
    );
  }

  Widget _besidePageScaleOption() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _gapW(16),
            Text(
              "Beside Page Scale:$_besidePageScale",
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            )
          ],
        ),
        Slider(
          value: _besidePageScale,
          min: 0.1,
          max: 1,
          onChanged: (value) {
            setState(() {
              _besidePageScale = double.parse(value.toStringAsFixed(2));
            });
          },
          onChangeEnd: (value) {
            setState(() {
              _besidePageScale = double.parse(value.toStringAsFixed(2));
            });
          },
        )
      ],
    );
  }

  Widget _scrollDirectionOption() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _gapW(16),
            Text(
              "Scroll Direction:${_scrollDirection.name}",
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
                child: ListTile(
              title: const Text('Horizontal'),
              leading: Radio<Axis>(
                value: Axis.horizontal,
                groupValue: _scrollDirection,
                onChanged: (Axis? value) {
                  setState(() {
                    _scrollDirection = value!;
                  });
                },
              ),
              onTap: () {
                setState(() {
                  _scrollDirection = Axis.horizontal;
                });
              },
            )),
            Expanded(
                child: ListTile(
              title: const Text('Vertical'),
              leading: Radio<Axis>(
                value: Axis.vertical,
                groupValue: _scrollDirection,
                onChanged: (Axis? value) {
                  setState(() {
                    _scrollDirection = value!;
                  });
                },
              ),
              onTap: () {
                setState(() {
                  _scrollDirection = Axis.vertical;
                });
              },
            )),
          ],
        )
      ],
    );
  }

  Widget _gapW(double w) => SizedBox(
        width: w,
      );
}
