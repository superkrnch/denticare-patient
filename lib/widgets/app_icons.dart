import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import '../core/theme.dart';

/// Minimal outlined icons used across the patient app.
abstract final class AppIcons {
  static const calendar = Icons.calendar_today_outlined;
  static const queue = Icons.format_list_numbered_outlined;
  static const bills = Icons.receipt_long_outlined;
  static const clinic = Icons.business_outlined;
  static const tooth = Icons.medical_services_outlined;
  static const location = Icons.location_on_outlined;
  static const phone = Icons.phone_outlined;
  static const email = Icons.mail_outlined;
  static const hours = Icons.schedule_outlined;
  static const afterCare = Icons.healing_outlined;
}

/// Brand mark — the DentiCare tooth, using the exact SVG path from the web app
/// (`dcnew/src/components/common/AppLogo.vue`) so both apps share one logo.
class ToothLogo extends StatelessWidget {
  const ToothLogo({super.key, this.size = 24, this.color = Colors.white});

  final double size;
  final Color color;

  /// Filled tooth silhouette drawn in a 0–100 viewBox (matches the web SVG).
  static const String _svgPath =
      'M82.123,23.756c-0.002-0.045,0.01-0.088,0-0.133c-0.02-0.096-0.05-0.187-0.07-0.281'
      'c-0.041-0.223-0.071-0.446-0.115-0.669c-0.023-0.12-0.072-0.227-0.135-0.324'
      'c-2.007-6.9-8.411-11.784-15.706-11.784c-0.283,0-0.564,0.018-0.847,0.032'
      'c-2.609-3.469-6.748-5.541-11.085-5.541c-4.324,0-8.446,2.059-11.058,5.506'
      'c0,0-0.001,0.001-0.002,0.001c-0.436,0.463-1.024,0.718-1.66,0.734'
      'c-0.714-0.381-1.459-0.708-2.237-0.963c-0.083-0.027-0.167-0.026-0.251-0.03'
      'c-1.521-0.458-3.103-0.698-4.71-0.698c-7.719,0-14.443,5.468-16.013,13.008'
      'c-0.005,0.021-0.02,0.036-0.024,0.058c-1.054,5.339-1.028,10.773,0.076,16.152'
      'c0.94,4.568,2.621,8.889,5.006,12.858c0.137,0.219,0.863,1.349,1.849,2.48'
      'c-0.288,2.368-0.44,4.779-0.44,7.18c0,11.317,3.22,22.312,9.311,31.795'
      'c0.041,0.062,0.089,0.117,0.14,0.167c0.747,1.033,1.827,1.748,3.083,2.002'
      'c0.525,0.107,1.031,0.16,1.511,0.16c1.04,0,1.954-0.248,2.655-0.731'
      'c0.835-0.576,1.376-1.483,1.563-2.623l0.013-0.077l0-4.052'
      'c0.06-5.508,0.926-10.992,2.574-16.301c0.826-2.663,1.85-5.276,3.031-7.744'
      'l0.255-0.495c0.283-0.357,0.716-0.569,1.171-0.569c0.568,0,1.079,0.315,1.333,0.822'
      'c0.025,0.05,0.066,0.083,0.099,0.127c1.211,2.52,2.251,5.161,3.089,7.859'
      'c1.647,5.31,2.514,10.793,2.573,16.29l0.003,4.058c0.094,1.227,0.544,2.153,1.341,2.755'
      'c0.646,0.488,1.481,0.731,2.528,0.731c0.562,0,1.184-0.07,1.87-0.21'
      'c1.26-0.254,2.341-0.972,3.087-2.008c0.05-0.048,0.097-0.101,0.136-0.161'
      'c6.092-9.48,9.312-20.475,9.312-31.795c0-2.234-0.127-4.486-0.377-6.694'
      'c-0.015-0.128-0.055-0.247-0.112-0.354c1.048-1.176,1.827-2.392,1.976-2.628'
      'c2.376-3.952,4.057-8.273,4.995-12.843C82.892,33.815,82.971,28.751,82.123,23.756z';

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _ToothLogoPainter(color),
    );
  }
}

class _ToothLogoPainter extends CustomPainter {
  _ToothLogoPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // The path is authored in a 0–100 coordinate space; scale to fit.
    canvas.save();
    canvas.scale(size.width / 100.0, size.height / 100.0);
    canvas.drawPath(parseSvgPathData(ToothLogo._svgPath), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ToothLogoPainter oldDelegate) => oldDelegate.color != color;
}

/// Outlined icon in a soft teal circle — for quick actions and empty states.
class AppIconBadge extends StatelessWidget {
  const AppIconBadge({
    super.key,
    required this.icon,
    this.size = 22,
    this.compact = false,
  });

  final IconData icon;
  final double size;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final box = compact ? 36.0 : 44.0;
    return Container(
      width: box,
      height: box,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size, color: AppColors.primary),
    );
  }
}

class ClinicInfoRow extends StatelessWidget {
  const ClinicInfoRow({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }
}
