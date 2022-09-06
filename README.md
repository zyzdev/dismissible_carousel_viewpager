This is a view pager provides carousel effect and dismissal animation when page was removed.

## Features

* Carousel effect

[](https://user-images.githubusercontent.com/16483162/188594209-abc1b013-3bfc-426c-82f1-af1399042f52.webm) 

[](https://user-images.githubusercontent.com/16483162/188594162-0f078535-3bdd-439c-889b-ade695d4be93.webm)
  
* Dismissal animation

[](https://user-images.githubusercontent.com/16483162/188597772-72d4c06f-24b1-44f2-819e-d61a7c01e41f.webm)

[](https://user-images.githubusercontent.com/16483162/188597902-4f68ded5-f7f3-4269-9749-e3c38e9b10e0.webm)

[](https://user-images.githubusercontent.com/16483162/188597974-54353bad-a813-4b17-8140-e328843bfa73.webm)
  
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

`dismissible_carousel_viewpager` provides several kind of animation(`fade out`, `slide out`, `scale` and `circular hide`) to make dismissal animation.

You can combine then to make your own style of dismissal animation.


#### *Note*
The dismissal animation base on `AnimatedSwitcher`.

Remember add `key` to the page widget that created by `DismissibleCarouselViewPager.itemBuilder`.

I recommend using the `data` that preparing to create page widget to create `Key("$data")`, `ValueKey(data)` or `ObjectKey(data)` for the page widget.

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
