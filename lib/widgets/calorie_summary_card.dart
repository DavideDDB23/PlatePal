import 'package:flutter/material.dart';
import 'package:plate_pal/utils/app_colors.dart';
import 'package:plate_pal/widgets/donut_chart_painter.dart';
import 'package:plate_pal/widgets/macro_info_widget.dart';

class CalorieSummaryCard extends StatefulWidget {
  final int totalKcal;
  final int proteinGrams;
  final int carbsGrams;
  final int fatsGrams;

  const CalorieSummaryCard({
    Key? key,
    required this.totalKcal,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatsGrams,
  }) : super(key: key);

  @override
  State<CalorieSummaryCard> createState() => _CalorieSummaryCardState();
}

class _CalorieSummaryCardState extends State<CalorieSummaryCard> {
  // Store previous percentages to animate from
  // These will be updated in didUpdateWidget
  double _prevProteinPercent = 0.0;
  double _prevCarbsPercent = 0.0;
  double _prevFatsPercent = 0.0;

  // Target percentages
  double _targetProteinPercent = 0.0;
  double _targetCarbsPercent = 0.0;
  double _targetFatsPercent = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTargetPercentages();
    // Initialize previous percentages to the initial target for the first build
    _prevProteinPercent = _targetProteinPercent;
    _prevCarbsPercent = _targetCarbsPercent;
    _prevFatsPercent = _targetFatsPercent;
  }

  @override
  void didUpdateWidget(CalorieSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When widget properties change, update previous values to current displayed ones
    // and recalculate new target percentages for animation
    if (widget.proteinGrams != oldWidget.proteinGrams ||
        widget.carbsGrams != oldWidget.carbsGrams ||
        widget.fatsGrams != oldWidget.fatsGrams) {

      // Current displayed percentages become the starting point for the new animation
      _prevProteinPercent = _targetProteinPercent;
      _prevCarbsPercent = _targetCarbsPercent;
      _prevFatsPercent = _targetFatsPercent;

      _calculateTargetPercentages();
    }
  }

  void _calculateTargetPercentages() {
    double totalGrams = (widget.proteinGrams + widget.carbsGrams + widget.fatsGrams).toDouble();

    if (widget.proteinGrams == 0 && widget.carbsGrams == 0 && widget.fatsGrams == 0) {
      _targetProteinPercent = 0;
      _targetCarbsPercent = 0;
      _targetFatsPercent = 0;
    } else if (totalGrams > 0) {
      _targetProteinPercent = widget.proteinGrams / totalGrams;
      _targetCarbsPercent = widget.carbsGrams / totalGrams;
      _targetFatsPercent = widget.fatsGrams / totalGrams;
    } else { // Default if somehow totalGrams is <= 0 but individual grams are not all 0
      _targetProteinPercent = 0.33;
      _targetCarbsPercent = 0.33;
      _targetFatsPercent = 0.34;
    }
  }


  @override
  Widget build(BuildContext context) {
    const animationDuration = Duration(milliseconds: 300); // Adjust duration as needed

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      color: Color.fromRGBO(244, 244, 244, 1),
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 20.0), // Note: leading 00.0 is just 0.0
        child: Column(
          children: [
            SizedBox(
              height: 180,
              width: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: _prevProteinPercent, end: _targetProteinPercent),
                    duration: animationDuration,
                    builder: (context, animatedProteinPercent, child) {
                      return TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: _prevCarbsPercent, end: _targetCarbsPercent),
                        duration: animationDuration,
                        builder: (context, animatedCarbsPercent, child) {
                          return TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: _prevFatsPercent, end: _targetFatsPercent),
                            duration: animationDuration,
                            builder: (context, animatedFatsPercent, child) {
                              return CustomPaint(
                                size: const Size(160, 160),
                                painter: DonutChartPainter(
                                  proteinPercentage: animatedProteinPercent,
                                  carbsPercentage: animatedCarbsPercent,
                                  fatsPercentage: animatedFatsPercent,
                                  strokeWidth: 25,
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(237, 236, 241, 1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.totalKcal.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                          fontFamily: 'SFProDisplay',
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Kcal',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'SFProDisplay',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: MacroInfoWidget(
                      iconAsset: 'assets/icons/protein_icon.svg',
                      label: 'Protein',
                      value: '${widget.proteinGrams}g',
                      iconColor: AppColors.proteinColor,
                      size: 22,
                    ),
                  ),
                  Expanded(
                    child: MacroInfoWidget(
                      iconAsset: 'assets/icons/carbs_icon.svg',
                      label: 'Carbs',
                      value: '${widget.carbsGrams}g',
                      iconColor: AppColors.carbsColor,
                      size: 22,
                    ),
                  ),
                  Expanded(
                    child: MacroInfoWidget(
                      iconAsset: 'assets/icons/avocado-2.svg', // Ensure this path is correct
                      label: 'Fats',
                      value: '${widget.fatsGrams}g',
                      iconColor: AppColors.fatsColor,
                      size: 22,
                    ),
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