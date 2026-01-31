import 'package:flutter/material.dart';
import '../fancy_page_indicator.dart';

/// A dashed capsule page indicator with:
/// - Windowed view for large page counts
/// - "Indicator Loupe" long-press magnifier
/// - RTL / LTR support
/// - Smooth animated transitions
class DashedPageIndicator extends StatelessWidget {
  const DashedPageIndicator({
    super.key,
    required this.controller,
    required this.count,
    this.onDotClicked,
    this.enableLoupe = false,
    this.loupeScale = 1.8,
    this.loupeSpeedMultiplier = 3.2,
    this.loupeHeight = 88.0,
    this.loupeVerticalOffset = 12.0,
    this.loupeHandleColor,
    this.loupeProgressColor,
    this.onLoupeScrub,
    this.dotHeight = 6.0,
    this.inactiveDotWidth = 24.0,
    this.activeDotWidth = 40.0,
    this.spacing = 10.0,
    this.maxVisibleDots = 5,
    this.dotColor,
    this.activeDotColor,
    this.enableProgressiveFill = false,
    this.reverse = false,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionCurve = Curves.easeInOut,
  });

  /// [PageController] driving the [PageView]. Must be the same as the PageView's controller.
  final PageController controller;

  /// Total number of pages/dots.
  final int count;

  /// Called when user taps a dot (when tap-to-page is implemented).
  final void Function(int index)? onDotClicked;

  /// Enable long press magnifier loupe
  final bool enableLoupe;

  /// Magnification scale when loupe is active
  final double loupeScale;

  /// Scrubbing speed multiplier
  final double loupeSpeedMultiplier;

  /// Height of loupe overlay
  final double loupeHeight;

  /// Vertical offset of loupe above the indicator.
  final double loupeVerticalOffset;

  /// Color of the progress line handle in the loupe. Defaults to [activeDotColor].
  final Color? loupeHandleColor;

  /// Color of the progress line track in the loupe. Defaults to [dotColor].
  final Color? loupeProgressColor;

  /// Called when user scrubs to a page via the loupe overlay.
  final FancyPageScrubCallback? onLoupeScrub;

  /// Height of each capsule in logical pixels.
  final double dotHeight;

  /// Width of inactive (non-current) capsules.
  final double inactiveDotWidth;

  /// Width of the active (current) capsule.
  final double activeDotWidth;

  /// Horizontal spacing between capsules.
  final double spacing;

  /// Maximum number of dots visible at once. Extra dots scroll into view.
  final int maxVisibleDots;

  /// Color of inactive capsules. Defaults to a semi-transparent purple.
  final Color? dotColor;

  /// Color of the active capsule. Defaults to purple.
  final Color? activeDotColor;

  /// Whether to progressively fill capsules based on scroll position.
  final bool enableProgressiveFill;

  /// When true, reverses page order (first dot = last page).
  final bool reverse;

  /// Duration for animated page transitions.
  final Duration transitionDuration;

  /// Curve for animated page transitions.
  final Curve transitionCurve;

  @override
  Widget build(BuildContext context) {
    return FancyPageIndicator(
      key: key,
      controller: controller,
      count: count,
      onDotClicked: onDotClicked,
      enableLoupe: enableLoupe,
      loupeScale: loupeScale,
      loupeSpeedMultiplier: loupeSpeedMultiplier,
      loupeHeight: loupeHeight,
      loupeVerticalOffset: loupeVerticalOffset,
      loupeHandleColor: loupeHandleColor,
      loupeProgressColor: loupeProgressColor,
      onLoupeScrub: onLoupeScrub,
      dotHeight: dotHeight,
      inactiveDotWidth: inactiveDotWidth,
      activeDotWidth: activeDotWidth,
      spacing: spacing,
      maxVisibleDots: maxVisibleDots,
      dotColor: dotColor,
      activeDotColor: activeDotColor,
      enableProgressiveFill: enableProgressiveFill,
      reverse: reverse,
      transitionDuration: transitionDuration,
      transitionCurve: transitionCurve,
    );
  }
}
