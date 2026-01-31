# Fancy Page Indicator

A **capsule-style page indicator** for Flutter with an optional loupe overlay (long-press to show a scrubbing progress line).  
Optimized for performance with minimal rebuilds.

![Preview](example/images/screen.jpg)

---

## Features

- Capsule-style page indicator.
- Fully customizable **colors**, **sizes**, and **spacing**.
- **Active / inactive dot widths**.
- Optional **loupe overlay** for scrubbing between pages.
- Supports **progressive fill**.
- Supports **reverse order** of pages.
- Minimal rebuilds for better performance.

---

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  fancy_page_indicator:
    git:
      url: git@github.com:aliabdalshaheedbaqer/fancy_page_indicator.git
      ref: main
```

Then run:

```bash
flutter pub get
```

---

## Usage

```dart
import 'package:fancy_page_indicator/fancy_page_indicator.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              children: List.generate(
                5,
                (index) => Center(child: Text('Page $index')),
              ),
            ),
          ),
          FancyPageIndicator(
            controller: _controller,
            count: 5,
            activeDotColor: Colors.purple,
            dotColor: Colors.purple.withOpacity(0.3),
            enableLoupe: true,
            onLoupeScrub: (pageIndex) {
              print('Scrubbed to page: $pageIndex');
            },
            enableProgressiveFill: true,
            reverse: false,
          ),
        ],
      ),
    );
  }
}
```

---

## Properties

| Property                | Type                      | Description                               |
| ----------------------- | ------------------------- | ----------------------------------------- |
| `controller`            | `PageController`          | The controller of the PageView.           |
| `count`                 | `int`                     | Total number of pages/dots.               |
| `onDotClicked`          | `Function(int)?`          | Callback when user taps a dot.            |
| `enableLoupe`           | `bool`                    | Show loupe overlay on long press.         |
| `loupeScale`            | `double`                  | Loupe content scale factor.               |
| `loupeSpeedMultiplier`  | `double`                  | Loupe horizontal drag speed multiplier.   |
| `loupeHeight`           | `double`                  | Height of loupe overlay.                  |
| `loupeVerticalOffset`   | `double`                  | Vertical offset of loupe above indicator. |
| `loupeHandleColor`      | `Color?`                  | Color of the progress handle in loupe.    |
| `loupeProgressColor`    | `Color?`                  | Color of the progress line in loupe.      |
| `onLoupeScrub`          | `FancyPageScrubCallback?` | Callback when scrubbing via loupe.        |
| `dotHeight`             | `double`                  | Height of capsules.                       |
| `inactiveDotWidth`      | `double`                  | Width of inactive capsules.               |
| `activeDotWidth`        | `double`                  | Width of active capsule.                  |
| `spacing`               | `double`                  | Horizontal spacing between capsules.      |
| `maxVisibleDots`        | `int`                     | Max number of visible dots.               |
| `dotColor`              | `Color?`                  | Color of inactive capsules.               |
| `activeDotColor`        | `Color?`                  | Color of active capsule.                  |
| `enableProgressiveFill` | `bool`                    | Fill capsules based on scroll progress.   |
| `reverse`               | `bool`                    | Reverse page order.                       |
| `transitionDuration`    | `Duration`                | Animated page transition duration.        |
| `transitionCurve`       | `Curve`                   | Animated page transition curve.           |

---

## Example

Run the example app:

```bash
cd example
flutter pub get
flutter run
```

You can see all features including:

- Loupe overlay for scrubbing pages.
- Progressive fill of capsules.
- Reversed page order.

---

## Screenshots

**Normal indicator**

![Normal indicator](example/screenshot.png)

**Loupe overlay active**

![Loupe overlay](example/screenshot.png)

**Progressive fill**

![Progressive fill](example/screenshot.png)

_(Add your own screenshots to the `example/` folder and update the paths above.)_

---

## License

MIT License © aliabdalshaheedbaqer
