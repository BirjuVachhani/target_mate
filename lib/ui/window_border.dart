import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowButtons extends StatefulWidget {
  const WindowButtons({super.key});

  @override
  State<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> with WindowListener {
  bool isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void onWindowMaximize() {
    isMaximized = true;
    if (mounted) setState(() {});
  }

  @override
  void onWindowUnmaximize() {
    isMaximized = false;
    if (mounted) setState(() {});
  }

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
    return SizedBox(
      height: 36,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomMinimizeWindowButton(
            colors: buttonColors,
            animate: true,
            padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
          ),
          if (!isMaximized)
            CustomMaximizeWindowButton(
              colors: buttonColors,
              animate: true,
              padding: const EdgeInsets.fromLTRB(2, 2, 0, 0),
            ),
          if (isMaximized)
            CustomRestoreWindowButton(
              colors: buttonColors,
              animate: true,
            ),
          CustomCloseWindowButton(
            colors: closeButtonColors,
            animate: true,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }
}

class CustomMinimizeWindowButton extends WindowButton {
  CustomMinimizeWindowButton({
    super.key,
    super.colors,
    VoidCallback? onPressed,
    super.padding,
    bool? animate,
  }) : super(
          animate: animate ?? false,
          iconBuilder: (buttonContext) =>
              MinimizeIcon(color: buttonContext.iconColor),
          onPressed: onPressed ?? () => appWindow.minimize(),
        );
}

class CustomMaximizeWindowButton extends WindowButton {
  CustomMaximizeWindowButton({
    super.key,
    super.colors,
    VoidCallback? onPressed,
    super.padding,
    bool? animate,
  }) : super(
          animate: animate ?? false,
          iconBuilder: (buttonContext) =>
              MaximizeIcon(color: buttonContext.iconColor),
          onPressed: onPressed ?? () => appWindow.maximizeOrRestore(),
        );
}

final _defaultCloseButtonColors = WindowButtonColors(
  mouseOver: const Color(0xFFD32F2F),
  mouseDown: const Color(0xFFB71C1C),
  iconNormal: const Color(0xFF805306),
  iconMouseOver: const Color(0xFFFFFFFF),
);

class CustomCloseWindowButton extends WindowButton {
  CustomCloseWindowButton({
    super.key,
    WindowButtonColors? colors,
    VoidCallback? onPressed,
    super.padding,
    bool? animate,
  }) : super(
          colors: colors ?? _defaultCloseButtonColors,
          animate: animate ?? false,
          iconBuilder: (buttonContext) =>
              CloseIcon(color: buttonContext.iconColor),
          onPressed: onPressed ?? () => appWindow.close(),
        );
}

class CustomRestoreWindowButton extends WindowButton {
  CustomRestoreWindowButton({
    super.key,
    super.colors,
    VoidCallback? onPressed,
    super.padding,
    bool? animate,
  }) : super(
          animate: animate ?? false,
          iconBuilder: (buttonContext) =>
              RestoreIcon(color: buttonContext.iconColor),
          onPressed: onPressed ?? () => appWindow.maximizeOrRestore(),
        );
}
