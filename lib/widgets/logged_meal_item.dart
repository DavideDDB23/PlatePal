import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plate_pal/models/meal_model.dart';
import 'package:plate_pal/utils/app_colors.dart';

class LoggedMealItem extends StatelessWidget {
  final Meal meal;

  const LoggedMealItem({Key? key, required this.meal}) : super(key: key);

  Widget _buildMacroDetail(String iconAsset, String value, String type) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: type == 'Fats' ? 1.6 : 1.0,
          alignment: Alignment.center,
          child: SvgPicture.asset(
            iconAsset,
            height: 16,
            width: 16,
          ),
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
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildImageLayout() {
    const double imageContainerWidth = 120;
    const double imageContainerHeight = 130; // Total height for the image area
    final imageCount = meal.imageUrls.length;

    // Fallback for 0 images or more than 4 (or handle as error)
    if (imageCount == 0) {
      return Container(
        width: imageContainerWidth,
        height: imageContainerHeight,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
        ),
        child: const Icon(Icons.no_food, color: Colors.grey),
      );
    }
     if (imageCount > 4) { // Or some other handling for too many images
      return _buildImageWidget(
        meal.imageUrls.first,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          bottomLeft: Radius.circular(25),
        ),
      );
    }


    switch (imageCount) {
      case 1:
        return SizedBox(
          width: imageContainerWidth,
          height: imageContainerHeight,
          child: _buildImageWidget(
            meal.imageUrls[0],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              bottomLeft: Radius.circular(25),
            ),
          ),
        );
      case 2: // One above, one below
        return SizedBox(
          width: imageContainerWidth,
          height: imageContainerHeight,
          child: Column(
            children: [
              Expanded(
                child: _buildImageWidget(
                  meal.imageUrls[0],
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(25)),
                ),
              ),
              // Optional: Divider(height: 1, color: Colors.white), // Separator
              Expanded(
                child: _buildImageWidget(
                  meal.imageUrls[1],
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(25)),
                ),
              ),
            ],
          ),
        );
      case 3: // Two above, one below
        return SizedBox(
          width: imageContainerWidth,
          height: imageContainerHeight,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildImageWidget(
                        meal.imageUrls[0],
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(25)),
                      ),
                    ),
                    // Optional: VerticalDivider(width: 1, color: Colors.white),
                    Expanded(
                      child: _buildImageWidget(meal.imageUrls[1]), // No border radius for middle top
                    ),
                  ],
                ),
              ),
              // Optional: Divider(height: 1, color: Colors.white),
              Expanded(
                child: _buildImageWidget(
                  meal.imageUrls[2],
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(25)),
                ),
              ),
            ],
          ),
        );
      case 4: // 2x2 grid
        return SizedBox(
          width: imageContainerWidth,
          height: imageContainerHeight,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildImageWidget(
                        meal.imageUrls[0],
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(25)),
                      ),
                    ),
                    // Optional: VerticalDivider(width: 1, color: Colors.white),
                    Expanded(child: _buildImageWidget(meal.imageUrls[1])),
                  ],
                ),
              ),
              // Optional: Divider(height: 1, color: Colors.white),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildImageWidget(
                        meal.imageUrls[2],
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(25)),
                      ),
                    ),
                    // Optional: VerticalDivider(width: 1, color: Colors.white),
                    Expanded(child: _buildImageWidget(meal.imageUrls[3])),
                  ],
                ),
              ),
            ],
          ),
        );
      default: // Fallback for more than 4 images, show the first one
        return SizedBox(
          width: imageContainerWidth,
          height: imageContainerHeight,
          child: _buildImageWidget(
            meal.imageUrls.first,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              bottomLeft: Radius.circular(25),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25),
        ),
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
                        meal.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(241, 241, 241, 1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          meal.time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryText,
                          ),
                        ),
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
                        '${meal.calories} calories',
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
                        '${meal.proteinGrams}g',
                        'Protein',
                      ),
                      const SizedBox(width: 12),
                      _buildMacroDetail(
                        'assets/icons/carbs_icon.svg',
                        '${meal.carbsGrams}g',
                        "Carbs",
                      ),
                      const SizedBox(width: 12),
                      _buildMacroDetail(
                        'assets/icons/fats_icon.svg',
                        '${meal.fatsGrams}g',
                        "Fats",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
