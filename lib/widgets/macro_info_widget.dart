import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plate_pal/utils/app_colors.dart';

class MacroInfoWidget extends StatelessWidget {
  final String iconAsset; // SVG asset path
  final String label;
  final String value;
  final Color iconColor;
  final double size;

  const MacroInfoWidget({
    Key? key,
    required this.iconAsset,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: label == 'Fats' ? 1.6 : 1.0,
          alignment: Alignment.center,
          child: SvgPicture.asset(
            iconAsset,
            height: size,
            width: size,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: iconColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
      ],
    );
  }
}
