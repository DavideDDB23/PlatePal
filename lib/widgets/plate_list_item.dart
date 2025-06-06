import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plate_pal/models/plate_model.dart';
import 'package:plate_pal/utils/app_colors.dart';

class PlateListItem extends StatelessWidget {
  final Plate plate;
  final VoidCallback onDelete;

  const PlateListItem({
    Key? key,
    required this.plate,
    required this.onDelete,
  }) : super(key: key);

  Widget _buildMacroDetail(String iconAsset, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(iconAsset, height: 14, width: 14, colorFilter: ColorFilter.mode(color, BlendMode.srcIn)),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: AppColors.cardBackground,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                plate.imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                    width: 70, height: 70, color: Colors.grey[300],
                    child: const Icon(Icons.restaurant, color: Colors.grey)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plate.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SvgPicture.asset('assets/icons/fire_icon.svg', height: 14, width: 14, colorFilter: const ColorFilter.mode(Colors.orange, BlendMode.srcIn)),
                      const SizedBox(width: 4),
                      Text('${plate.calories} calories', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildMacroDetail('assets/icons/protein_icon.svg', '${plate.proteinGrams}g', AppColors.proteinColor),
                      const SizedBox(width: 10),
                      _buildMacroDetail('assets/icons/carbs_icon.svg', '${plate.carbsGrams}g', AppColors.carbsColor),
                      const SizedBox(width: 10),
                      _buildMacroDetail('assets/icons/fats_icon.svg', '${plate.fatsGrams}g', AppColors.fatsColor),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}