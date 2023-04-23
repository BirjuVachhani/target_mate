import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:pub_semver/pub_semver.dart';

import '../../utils/extensions.dart';
import '../../utils/font_variations.dart';

const double kSquircleRadiusFactor = 0.24;

class UpdateDialog extends StatelessWidget {
  final Version latestVersion;
  final VoidCallback onUpdate;

  const UpdateDialog({
    super.key,
    required this.latestVersion,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            width: context.mediaQuery.size.width * 0.85,
            decoration: ShapeDecoration(
              color: context.theme.brightness.isDark
                  ? context.theme.colorScheme.primaryContainer.darken(90)
                  : context.theme.colorScheme.primary.shade(1).shade(1),
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(
                    context.mediaQuery.size.width *
                        0.85 *
                        kSquircleRadiusFactor),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Update available!',
                        style: context.theme.textTheme.displaySmall!.copyWith(
                          color: context.theme.textColor,
                          fontVariations: FontVariations.w400,
                        ),
                      ),
                    ),
                    Icon(
                      CupertinoIcons.circle_bottomthird_split,
                      size: 64,
                      color: context.theme.textColor,
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'We have made improvements to the app. Please update to the latest version.',
                  style: context.theme.textTheme.titleMedium!.copyWith(
                    color: context.theme.textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: ShapeDecoration(
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    color:
                        context.theme.colorScheme.onSurface.withOpacity(0.07),
                  ),
                  child: Text(
                    'New version: $latestVersion',
                    style: context.theme.textTheme.titleMedium!.copyWith(
                      color: context.theme.textColor,
                      fontVariations: FontVariations.medium,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: context.theme.brightness.isDark
                              ? context.theme.colorScheme.primary
                              : context.theme.colorScheme.primary.darken(90),
                          foregroundColor: context.theme.colorScheme.onPrimary,
                          shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: onUpdate,
                        child: const Text('Update'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: context.theme.brightness.isDark
                                ? context.theme.colorScheme.primary
                                    .withOpacity(0.7)
                                : context.theme.textColor,
                            width: 1,
                          ),
                          shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          foregroundColor: context.theme.brightness.isDark
                              ? context.theme.colorScheme.primary
                                  .withOpacity(0.7)
                              : context.theme.textColor,
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: const Text('Later'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
