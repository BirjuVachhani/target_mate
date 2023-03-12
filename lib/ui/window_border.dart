import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final buttonColors = WindowButtonColors(
      iconNormal: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
      mouseOver: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withOpacity(0.2)
          : Colors.black.withOpacity(0.2),
      mouseDown: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withOpacity(0.4)
          : Colors.black.withOpacity(0.4),
      iconMouseOver: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
      iconMouseDown: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
      normal: Colors.transparent,
    );

    final closeButtonColors = WindowButtonColors(
      mouseOver: const Color(0xFFD32F2F),
      mouseDown: const Color(0xFFB71C1C),
      iconNormal: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
      iconMouseOver: Colors.white,
      normal: Colors.transparent,
    );
    return Row(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          ),
          child: MinimizeWindowButton(colors: buttonColors, animate: true),
        ),
        MaximizeWindowButton(colors: buttonColors, animate: true),
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          child: CloseWindowButton(colors: closeButtonColors, animate: true),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
