import 'package:flutter/material.dart';

/// DentiCare brand mark, rendered from the bundled logo image
/// (`assets/images/applogo.png`).
///
/// [fit] controls how the image is scaled within the given [height]/[width].
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height = 40,
    this.width,
    this.fit = BoxFit.contain,
  });

  final double height;
  final double? width;
  final BoxFit fit;

  static const _asset = 'assets/images/applogo.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _asset,
      height: height,
      width: width,
      fit: fit,
      filterQuality: FilterQuality.high,
    );
  }
}
