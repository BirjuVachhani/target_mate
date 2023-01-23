import 'package:flutter/material.dart';

class FieldLabel extends StatelessWidget {
  final String label;

  const FieldLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}

class SetupTitle extends StatelessWidget {
  final String title;

  const SetupTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}

final TextStyle subtitleTextStyle = TextStyle(
  fontSize: 13,
  height: 1.4,
  color: Colors.white.withOpacity(0.5),
);

class SetupSubtitle extends StatelessWidget {
  final String subtitle;

  const SetupSubtitle(this.subtitle, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        subtitle,
        style: subtitleTextStyle,
      ),
    );
  }
}
