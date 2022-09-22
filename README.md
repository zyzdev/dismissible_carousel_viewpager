This is a view pager provides carousel effect and dismissal animation when page was removed.

## Features

* Dismissal animation

| Fade out & slide out                                                                                                                                             | Fade out & scale                                                                                                                                          | Fade out & circular hide                                                                                                                                           |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| <img title="dismissal_fade_slide_out" src="https://user-images.githubusercontent.com/16483162/188320390-4046c544-0edb-428b-a97e-321f6a411d14.gif" width="300" /> | <img title="dismissal_fade_scale" src="https://user-images.githubusercontent.com/16483162/188320395-d26295c2-5882-4437-a5c1-ba1172acedb2.gif" width="300"/> | <img title="dismissal_fade_circular_hide"  src="https://user-images.githubusercontent.com/16483162/188320396-d3a73621-d346-40e9-aaba-b093cd2029ca.gif" width="300"/> |

* Carousel effect

| Horizontal                                                                                                                                                    | Vertical                                                                                                                                                    |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|
| <img title="base_usage_horizontal" src="https://user-images.githubusercontent.com/16483162/188320379-bae6cd27-a817-4962-9c16-f67f28770b77.gif" width="300" /> | <img title="base_usage_vertical"  src="https://user-images.githubusercontent.com/16483162/188320384-18598ce1-8661-4960-be2d-a9be8171880c.gif" width="300"/> |

## Web Live demo
This an example app of this plugin of web version.

https://zyzdev.github.io/dismissible_carousel_viewpager

## Usage

More detail of usage see `/example` app.

### Base usage:
More detail, please run demo `Base Usage` at `/example` app.

```dart
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
```
### Dismissal animation
More detail please run demo `Dismissal Usage` at `/example` app.

`dismissible_carousel_viewpager` provides several kinds of animation(`fade out`, `slide out`, `scale` and `circular hide`) to make dismissal animation.

You can combine them to make your own style of dismissal animation.


#### *Note*
The dismissal animation base on `AnimatedSwitcher`.

Remember add `key` to the page widget that created by `DismissibleCarouselViewPager.itemBuilder`.

I recommend using the `data` that preparing to create page widget to create `Key("$data")`, `ValueKey(data)` or `ObjectKey(data)` for the page widget.

####*example:*
```dart

late final List<int> _item = List.generate(1000, (index) => index);

DismissibleCarouselViewPager(
  itemCount: _item.length,
  itemBuilder: (context, index) {
    Object data = _item[index];
    return Container(
      // must add key
      key: Key("$data"),
      //key: ValueKey(data),
      //key: ObjectKey(data),
      alignment: Alignment.center,
      color: Colors.grey.withOpacity(0.1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        Expanded(
          child: Container(
            alignment: Alignment.bottomCenter,
            child: Text("Item:$data"),
          ),
        ),
        Expanded(
          child: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
                setState(() {
                  _item.remove(data);
                });
              },
            ),
          ),
        ],
      ),
    );
  },
  dismissalConfig: DismissalConfig(
    dismissalTypes: [
      DismissalType.fadeOut(),
      DismissalType.slideOut(),
    ],
  ),
);
```
