import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SvgIcon extends StatelessWidget {
  final String? path;
  final double? size;
  final Color? color;
  final String? url;

  const SvgIcon({
    super.key,
    this.path,
    this.url,
    this.size,
    this.color,
  }) : assert(path != null || url != null, 'path or url must be not null');

  const SvgIcon.asset(
    this.path, {
    super.key,
    this.size,
    this.color,
  }) : url = null;

  const SvgIcon.network(
    this.url, {
    super.key,
    this.size,
    this.color,
  }) : path = null;

  @override
  Widget build(BuildContext context) {
    final Color? color = this.color ?? IconTheme.of(context).color;
    final double? size = this.size ?? IconTheme.of(context).size;
    return SvgPicture(
      path != null ? SvgAssetLoader(path!) : SvgNetworkLoader(url!),
      width: size,
      height: size,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      fit: BoxFit.contain,
    );
  }
}
