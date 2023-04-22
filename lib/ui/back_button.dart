import 'package:flutter/material.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';

import '../utils/extensions.dart';
import 'gesture_detector_with_cursor.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onBack;
  final bool disabled;
  final bool usePrimaryColor;

  const CustomBackButton({
    super.key,
    this.onBack,
    this.disabled = false,
    this.usePrimaryColor = true,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Hoverable(
        builder: (_, hovering, child) => GestureDetectorWithCursor(
          onTap: disabled
              ? null
              : () {
                  if (onBack != null) {
                    onBack?.call();
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotatedBox(
                quarterTurns: 2,
                child: Icon(
                  Icons.arrow_right_alt_rounded,
                  color: hovering
                      ? usePrimaryColor
                          ? context.theme.colorScheme.primary
                          : context.theme.textColor
                      : context.theme.textColor.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Back',
                style: TextStyle(
                  color: hovering && !disabled
                      ? usePrimaryColor
                          ? context.theme.colorScheme.primary
                          : context.theme.textColor
                      : context.theme.textColor.withOpacity(0.5),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
