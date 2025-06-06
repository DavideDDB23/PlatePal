import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plate_pal/models/plate_model.dart';
import 'package:plate_pal/utils/app_colors.dart';

class PlateListItem extends StatelessWidget {
  final Plate plate;
  final VoidCallback onDelete;

  const PlateListItem({Key? key, required this.plate, required this.onDelete})
    : super(key: key);

  Widget _buildMacroDetail(String iconAsset, String value, String type) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: type == 'Fats' ? 1.6 : 1.0,
          alignment: Alignment.center,
          child: SvgPicture.asset(iconAsset, height: 16, width: 16),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: AppColors.primaryText),
        ),
      ],
    );
  }

  Widget _buildImageWidget(String imageUrl, {BorderRadius? borderRadius}) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        // Occupy available space within its cell
        width: double.infinity,
        height: double.infinity,
        errorBuilder:
            (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
      ),
    );
  }

  Widget _buildImageLayout() {
    const double imageContainerWidth = 120;
    const double imageContainerHeight = 130;

    return SizedBox(
      width: imageContainerWidth,
      height: imageContainerHeight,
      child: _buildImageWidget(
        plate.imageUrl,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          bottomLeft: Radius.circular(25),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
        child: Row(
          children: [
            _buildImageLayout(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        plate.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/fire_icon.svg', // Use your fire icon
                        height: 16,
                        width: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${plate.calories} calories',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildMacroDetail(
                        'assets/icons/protein_icon.svg',
                        '${plate.proteinGrams}g',
                        'Protein',
                      ),
                      const SizedBox(width: 12),
                      _buildMacroDetail(
                        'assets/icons/carbs_icon.svg',
                        '${plate.carbsGrams}g',
                        "Carbs",
                      ),
                      const SizedBox(width: 12),
                      _buildMacroDetail(
                        'assets/icons/fats_icon.svg',
                        '${plate.fatsGrams}g',
                        "Fats",
                      ),
                    ],
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: onDelete,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(252, 9, 9, 0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/bin.svg',
                    width: 18,
                    height: 21,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
