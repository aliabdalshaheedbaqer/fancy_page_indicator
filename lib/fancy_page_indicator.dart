// Fancy Page Indicator
//
// A capsule-style page indicator with optional loupe overlay (long-press to show
// progress line). Optimized for performance with minimal rebuilds.

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Callback invoked when user scrubs to a page via the loupe overlay.
///
/// [pageIndex] is the 0-based index of the page the user scrubbed to.
typedef FancyPageScrubCallback = void Function(int pageIndex);

/// A capsule-style page indicator with optional loupe progress overlay.
///
/// Long-press to show a full-width progress line for scrubbing between pages.
class FancyPageIndicator extends StatefulWidget {
  const FancyPageIndicator({
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

  /// Whether to show the loupe overlay on long-press (progress line for scrubbing).
  final bool enableLoupe;

  /// Scale factor for loupe content. Unused when loupe shows only progress line.
  final double loupeScale;

  /// How fast horizontal drag translates to page change in loupe scrub mode.
  final double loupeSpeedMultiplier;

  /// Height of the loupe overlay in logical pixels.
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
  State<FancyPageIndicator> createState() => _FancyPageIndicatorState();
}

class _FancyPageIndicatorState extends State<FancyPageIndicator> {
  final GlobalKey _indicatorKey = GlobalKey();
  _LoupeOverlayController? _loupeController;
  double _initialPageOnLongPress = 0.0;
  bool _isLoupeActive = false;

  @override
  void dispose() {
    _loupeController?.dispose();
    super.dispose();
  }

  double get _viewportWidth {
    try {
      return widget.controller.position.viewportDimension;
    } catch (_) {
      return 1.0;
    }
  }

  double _computeTargetPageFromDx(double dxFromCenter, double indicatorWidth) {
    final w = indicatorWidth == 0 ? 1.0 : indicatorWidth;
    final pageDelta =
        (dxFromCenter / w) * widget.loupeSpeedMultiplier * widget.count;
    final target = widget.reverse
        ? _initialPageOnLongPress - pageDelta
        : _initialPageOnLongPress + pageDelta;
    return target.clamp(0.0, (widget.count - 1).toDouble());
  }

  Future<void> _snapToNearestAndHide() async {
    final page = widget.controller.hasClients
        ? (widget.controller.page ?? widget.controller.initialPage.toDouble())
        : widget.controller.initialPage.toDouble();
    final target = page.round();
    try {
      await widget.controller.animateToPage(
        target,
        duration: widget.transitionDuration,
        curve: widget.transitionCurve,
      );
    } catch (_) {
      try {
        widget.controller.jumpToPage(target);
      } catch (_) {}
    }
    _loupeController?.hide();
    _isLoupeActive = false;
  }

  void _onLongPressStart(LongPressStartDetails details) {
    if (!widget.enableLoupe || widget.count <= 0) return;

    _initialPageOnLongPress = widget.controller.hasClients
        ? (widget.controller.page ?? widget.controller.initialPage.toDouble())
        : widget.controller.initialPage.toDouble();

    final box = _indicatorKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    _loupeController = _LoupeOverlayController(
      overlay: Overlay.of(context),
      indicatorTopLeft: box.localToGlobal(Offset.zero),
      indicatorSize: box.size,
      loupeHeight: widget.loupeHeight,
      verticalOffset: widget.loupeVerticalOffset,
      reverse: widget.reverse,
      contentBuilder: () => _LoupeProgressContent(
        controller: widget.controller,
        count: widget.count,
        reverse: widget.reverse,
        progressColor: widget.loupeProgressColor ??
            widget.dotColor ??
            const Color(0x339966CC),
        handleColor: widget.loupeHandleColor ??
            widget.activeDotColor ??
            const Color(0xFF9966CC),
      ),
    );

    _loupeController!.show();
    _loupeController!.updateTouch(details.globalPosition);
    _isLoupeActive = true;
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (_loupeController == null || !_isLoupeActive) return;
    final box = _indicatorKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    _loupeController!.updateTouch(details.globalPosition);

    final dx =
        details.globalPosition.dx - _loupeController!.indicatorGlobalCenter.dx;
    final targetPage = _computeTargetPageFromDx(dx, box.size.width);

    if (widget.controller.hasClients) {
      try {
        widget.controller.position.jumpTo(targetPage * _viewportWidth);
      } catch (_) {
        final page =
            targetPage.clamp(0.0, (widget.count - 1).toDouble()).round();
        try {
          widget.controller.animateToPage(
            page,
            duration: const Duration(milliseconds: 120),
            curve: Curves.linear,
          );
        } catch (_) {}
      }
    }

    widget.onLoupeScrub?.call(targetPage.round().clamp(0, widget.count - 1));
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (!_isLoupeActive) return;
    _snapToNearestAndHide();
  }

  void _onLongPressCancel() {
    if (!_isLoupeActive) return;
    _snapToNearestAndHide();
  }

  @override
  Widget build(BuildContext context) {
    final inactiveColor = widget.dotColor ?? const Color(0x339966CC);
    final activeColor = widget.activeDotColor ?? const Color(0xFF9966CC);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: widget.enableLoupe ? _onLongPressStart : null,
      onLongPressMoveUpdate: widget.enableLoupe ? _onLongPressMoveUpdate : null,
      onLongPressEnd: widget.enableLoupe ? _onLongPressEnd : null,
      onLongPressCancel: widget.enableLoupe ? _onLongPressCancel : null,
      child: RepaintBoundary(
        child: SizedBox(
          key: _indicatorKey,
          height: widget.dotHeight * 2 + 4,
          child: CustomPaint(
            size: Size(double.infinity, widget.dotHeight * 2 + 4),
            painter: _CapsulePainter(
              controller: widget.controller,
              count: widget.count,
              maxVisibleDots: widget.maxVisibleDots,
              dotHeight: widget.dotHeight,
              inactiveDotWidth: widget.inactiveDotWidth,
              activeDotWidth: widget.activeDotWidth,
              spacing: widget.spacing,
              inactiveColor: inactiveColor,
              activeColor: activeColor,
              enableProgressiveFill: widget.enableProgressiveFill,
              reverse: widget.reverse,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Capsule Painter
// ---------------------------------------------------------------------------

class _CapsulePainter extends CustomPainter {
  _CapsulePainter({
    required this.controller,
    required this.count,
    required this.maxVisibleDots,
    required this.dotHeight,
    required this.inactiveDotWidth,
    required this.activeDotWidth,
    required this.spacing,
    required this.inactiveColor,
    required this.activeColor,
    required this.enableProgressiveFill,
    required this.reverse,
  }) : super(repaint: controller);

  final PageController controller;
  final int count;
  final int maxVisibleDots;
  final double dotHeight;
  final double inactiveDotWidth;
  final double activeDotWidth;
  final double spacing;
  final Color inactiveColor;
  final Color activeColor;
  final bool enableProgressiveFill;
  final bool reverse;

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  double _getVisibleOffset(double page) {
    final n = math.min(count, maxVisibleDots);
    if (count <= n) return 0.0;
    return (page - (n - 1) / 2.0).clamp(0.0, (count - n).toDouble());
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (count <= 0) return;

    var page = controller.hasClients
        ? (controller.page ?? controller.initialPage.toDouble())
        : 0.0;
    if (reverse && count > 1) page = (count - 1) - page;

    final n = math.min(count, maxVisibleDots);
    final visibleOffset = _getVisibleOffset(page);
    final firstIdx = visibleOffset.floor().clamp(0, math.max(0, count - n));
    final frac = (visibleOffset - firstIdx).clamp(0.0, 1.0);

    final widths = <double>[];
    final colors = <Color>[];
    final fills = <double>[];

    for (var i = firstIdx; i < firstIdx + n; i++) {
      final d = (page - i).abs();
      final t = (1.0 - d).clamp(0.0, 1.0);
      widths.add(_lerp(inactiveDotWidth, activeDotWidth, t));
      colors.add(Color.lerp(inactiveColor, activeColor, t)!);
      fills.add((1.0 - d).clamp(0.0, 1.0));
    }

    final totalW = widths.fold(0.0, (a, b) => a + b) + (n - 1) * spacing;
    final startX =
        (size.width - totalW) / 2 - frac * (inactiveDotWidth + spacing);

    final bgColor = inactiveColor.withValues(alpha: inactiveColor.a * 0.36);
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;

    final fillPaint = Paint()..style = PaintingStyle.fill;

    var x = startX;
    for (var j = 0; j < widths.length; j++) {
      final w = widths[j];
      final h = dotHeight;
      final c = colors[j];
      final dy = (size.height - h) / 2;

      final rect = Rect.fromLTWH(x, dy, w, h);
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(h / 2));

      canvas.drawRRect(rrect, bgPaint);

      final fillW = enableProgressiveFill ? (w * fills[j]).clamp(0.0, w) : w;
      if (fillW > 0) {
        final fillX = reverse ? x + (w - fillW) : x;
        fillPaint.color = c;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(fillX, dy, fillW, h),
            Radius.circular(h / 2),
          ),
          fillPaint,
        );
      }

      x += w + spacing;
    }
  }

  @override
  bool shouldRepaint(covariant _CapsulePainter old) =>
      old.controller != controller ||
      old.count != count ||
      old.dotHeight != dotHeight ||
      old.inactiveDotWidth != inactiveDotWidth ||
      old.activeDotWidth != activeDotWidth ||
      old.spacing != spacing ||
      old.inactiveColor != inactiveColor ||
      old.activeColor != activeColor ||
      old.enableProgressiveFill != enableProgressiveFill ||
      old.reverse != reverse;
}

// ---------------------------------------------------------------------------
// Loupe Progress Content
// ---------------------------------------------------------------------------

class _LoupeProgressContent extends StatelessWidget {
  const _LoupeProgressContent({
    required this.controller,
    required this.count,
    required this.reverse,
    required this.progressColor,
    required this.handleColor,
  });

  final PageController controller;
  final int count;
  final bool reverse;
  final Color progressColor;
  final Color handleColor;

  static const _hPadding = 40.0;
  static const _trackH = 4.0;
  static const _handleSize = 12.0;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width - (_hPadding * 2);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        var page = controller.hasClients
            ? (controller.page ?? controller.initialPage.toDouble())
            : 0.0;
        if (reverse && count > 1) page = (count - 1) - page;
        final progress = count > 1 ? (page / (count - 1)).clamp(0.0, 1.0) : 0.0;

        return CustomPaint(
          size: Size(w, _trackH + _handleSize),
          painter: _ProgressPainter(
            progress: progress,
            progressColor: progressColor,
            handleColor: handleColor,
            trackHeight: _trackH,
            handleSize: _handleSize,
          ),
        );
      },
    );
  }
}

class _ProgressPainter extends CustomPainter {
  _ProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.handleColor,
    required this.trackHeight,
    required this.handleSize,
  });

  final double progress;
  final Color progressColor;
  final Color handleColor;
  final double trackHeight;
  final double handleSize;

  @override
  void paint(Canvas canvas, Size size) {
    final dy = (size.height - trackHeight) / 2;
    final track = Rect.fromLTWH(0, dy, size.width, trackHeight);
    final r = Radius.circular(trackHeight / 2);

    canvas.drawRRect(
      RRect.fromRectAndRadius(track, r),
      Paint()
        ..color = progressColor.withValues(alpha: progressColor.a * 0.4)
        ..style = PaintingStyle.fill,
    );

    final fillW = size.width * progress;
    if (fillW > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, dy, fillW, trackHeight), r),
        Paint()..color = progressColor,
      );
    }

    final hx = (size.width * progress - handleSize / 2).clamp(
      0.0,
      size.width - handleSize,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          hx,
          (size.height - handleSize) / 2,
          handleSize,
          handleSize,
        ),
        Radius.circular(handleSize / 2),
      ),
      Paint()..color = handleColor,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter old) =>
      old.progress != progress ||
      old.progressColor != progressColor ||
      old.handleColor != handleColor;
}

// ---------------------------------------------------------------------------
// Loupe Overlay
// ---------------------------------------------------------------------------

class _LoupeOverlayController {
  _LoupeOverlayController({
    required this.overlay,
    required this.indicatorTopLeft,
    required this.indicatorSize,
    required this.loupeHeight,
    required this.verticalOffset,
    required this.reverse,
    required this.contentBuilder,
  }) {
    _pos = ValueNotifier(Offset.zero);
    _visible = ValueNotifier(false);
    _entry = OverlayEntry(
      builder: (_) => _LoupeOverlayVisual(
        positionNotifier: _pos,
        visibleNotifier: _visible,
        indicatorTopLeft: indicatorTopLeft,
        indicatorSize: indicatorSize,
        loupeHeight: loupeHeight,
        verticalOffset: verticalOffset,
        reverse: reverse,
        contentBuilder: contentBuilder,
      ),
    );
  }

  final OverlayState overlay;
  final Offset indicatorTopLeft;
  final Size indicatorSize;
  final double loupeHeight;
  final double verticalOffset;
  final bool reverse;
  final Widget Function() contentBuilder;

  late final ValueNotifier<Offset> _pos;
  late final ValueNotifier<bool> _visible;
  late final OverlayEntry _entry;

  Offset get indicatorGlobalCenter =>
      indicatorTopLeft +
      Offset(indicatorSize.width / 2, indicatorSize.height / 2);

  void show() {
    overlay.insert(_entry);
    _visible.value = true;
  }

  void updateTouch(Offset p) => _pos.value = p;

  void hide() {
    _visible.value = false;
    Future.delayed(const Duration(milliseconds: 260), () {
      try {
        _entry.remove();
      } catch (_) {}
    });
  }

  void dispose() {
    try {
      _entry.remove();
    } catch (_) {}
    _pos.dispose();
    _visible.dispose();
  }
}

class _LoupeOverlayVisual extends StatefulWidget {
  const _LoupeOverlayVisual({
    required this.positionNotifier,
    required this.visibleNotifier,
    required this.indicatorTopLeft,
    required this.indicatorSize,
    required this.loupeHeight,
    required this.verticalOffset,
    required this.reverse,
    required this.contentBuilder,
  });

  final ValueNotifier<Offset> positionNotifier;
  final ValueNotifier<bool> visibleNotifier;
  final Offset indicatorTopLeft;
  final Size indicatorSize;
  final double loupeHeight;
  final double verticalOffset;
  final bool reverse;
  final Widget Function() contentBuilder;

  @override
  State<_LoupeOverlayVisual> createState() => _LoupeOverlayVisualState();
}

class _LoupeOverlayVisualState extends State<_LoupeOverlayVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  static const _hPadding = 40.0;
  static const _loupeH = 28.0;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    if (widget.visibleNotifier.value) _anim.value = 1.0;
    widget.positionNotifier.addListener(_onPos);
    widget.visibleNotifier.addListener(_onVis);
  }

  @override
  void dispose() {
    widget.positionNotifier.removeListener(_onPos);
    widget.visibleNotifier.removeListener(_onVis);
    _anim.dispose();
    super.dispose();
  }

  void _onPos() => setState(() {});
  void _onVis() {
    if (widget.visibleNotifier.value) {
      _anim.forward();
    } else {
      _anim.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final loupeW = screenW - (_hPadding * 2);
    final top = (widget.indicatorTopLeft.dy - _loupeH - widget.verticalOffset)
        .clamp(8.0, MediaQuery.of(context).size.height - _loupeH - 8.0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: _hPadding.toDouble(),
          top: top,
          width: loupeW,
          height: _loupeH,
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _anim,
              builder: (context, child) => Opacity(
                opacity: Curves.easeIn.transform(_anim.value),
                child: child,
              ),
              child: widget.contentBuilder(),
            ),
          ),
        ),
      ],
    );
  }
}
