import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';

import 'gesture_detector_with_cursor.dart';

/// A button that allows to change the theme on the fly.
class DebugFloatingThemeButton extends StatefulWidget {
  final Widget child;

  const DebugFloatingThemeButton({
    super.key,
    required this.child,
  });

  @override
  State<DebugFloatingThemeButton> createState() =>
      _DebugFloatingThemeButtonState();
}

class _DebugFloatingThemeButtonState extends State<DebugFloatingThemeButton> {
  Offset position = Offset.zero;
  Offset initialLocalPosition = Offset.zero;
  Offset initialPosition = Offset.zero;

  bool animate = false;
  bool hidden = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (hidden) {
      final left = mediaQuery.size.width - 28;
      position = Offset(left, position.dy == 0 ? 56 : position.dy);
    }
  }

  void onTap() {
    animate = true;
    final left =
        !hidden ? mediaQuery.size.width - 28 : mediaQuery.size.width - 180;
    hidden = !hidden;

    setState(() {
      position = Offset(left, position.dy);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return widget.child;

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        AnimatedPositioned(
          duration: Duration(milliseconds: animate ? 200 : 0),
          left: position.dx,
          top: position.dy,
          onEnd: () {
            animate = false;
          },
          child: Builder(
            builder: (context) {
              final manager = AdaptiveTheme.of(context);
              return Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                height: 56,
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: context.theme.colorScheme.onSurface.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          context.theme.colorScheme.onSurface.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetectorWithCursor(
                      onPanUpdate: (details) {
                        final delta =
                            details.localPosition - initialLocalPosition;
                        setState(() {
                          hidden = false;
                          position = Offset(
                            (initialPosition.dx + delta.dx)
                                .clamp(0, mediaQuery.size.width - 28),
                            (initialPosition.dy + delta.dy)
                                .clamp(0, mediaQuery.size.height - 56),
                          );
                        });
                      },
                      onPanStart: (details) {
                        initialLocalPosition = details.localPosition;
                        initialPosition = position;
                      },
                      onPanEnd: (details) {
                        initialLocalPosition = Offset.zero;
                        initialPosition = Offset.zero;
                      },
                      onTap: onTap,
                      child: SizedBox(
                        width: 28,
                        height: double.infinity,
                        child: Icon(
                          Icons.drag_indicator_rounded,
                          size: 20,
                          color: context.theme.colorScheme.onSurface
                              .withOpacity(0.6),
                        ),
                      ),
                    ),
                    ToggleButtons(
                      borderRadius: BorderRadius.circular(6),
                      constraints:
                          const BoxConstraints(minWidth: 48, minHeight: 40),
                      onPressed: (index) {
                        final mode = AdaptiveThemeMode.values[index];
                        manager.setThemeMode(mode);
                      },
                      isSelected: [
                        manager.mode == AdaptiveThemeMode.light,
                        manager.mode == AdaptiveThemeMode.dark,
                        manager.mode == AdaptiveThemeMode.system,
                      ],
                      children: const [
                        Center(child: Icon(Icons.sunny, size: 18)),
                        Center(child: Icon(Icons.nightlight, size: 18)),
                        Center(
                            child:
                                Icon(Icons.brightness_auto_outlined, size: 18))
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
