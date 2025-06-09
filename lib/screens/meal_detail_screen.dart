import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plate_pal/models/meal_model.dart';
import 'package:plate_pal/models/plate_model.dart';
import 'package:plate_pal/utils/app_colors.dart';
import 'package:plate_pal/widgets/plate_list_item.dart';
import 'package:plate_pal/screens/scanner_screen.dart';
import 'package:plate_pal/slide_from_bottom_route.dart';
import 'package:plate_pal/data/meal_combo_data.dart';
import 'package:collection/collection.dart';
import 'package:plate_pal/data/mock_data.dart';

class HealthScorePainter extends CustomPainter {
  final double animatedScore;
  final int targetScore; 
  final int maxScore; 

  HealthScorePainter({
    required this.animatedScore,
    required this.targetScore,
    this.maxScore = 10,
  });  

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        size.width / 2 * 0.9; 
    const strokeWidth = 8.0;

    // Background Arc (light pinkish/grey)
    Paint backgroundPaint =
        Paint()
          ..color = Color.fromRGBO(180, 29, 29, 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Foreground Arc (Progress)
    Color progressColor;
    if (targetScore <= 5) {
      progressColor = Color.fromRGBO(180, 29, 29, 1);
    } else if (targetScore <= 8) {
      progressColor = Color.fromRGBO(255, 104, 30, 1);
    } else {
      progressColor = AppColors.fatsColor;
    }

    Paint foregroundPaint =
        Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    double sweepAngle = (2 * 3.1415926535) * (animatedScore / maxScore);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926535 / 2, // Start at the top
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant HealthScorePainter oldDelegate) {
    return oldDelegate.animatedScore != animatedScore ||
        oldDelegate.maxScore != maxScore;
  }
}

class MealDetailScreen extends StatefulWidget {
  final Meal initialMeal;
  final Function(Meal updatedMeal) onMealUpdated;
  final Function(String mealId) onMealDeleted;
  final String selectedDay;

  const MealDetailScreen({
    Key? key,
    required this.initialMeal,
    required this.onMealUpdated,
    required this.onMealDeleted,
    required this.selectedDay,
  }) : super(key: key);

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> with TickerProviderStateMixin {
  late Meal _currentMeal;

  @override
  void initState() {
    super.initState();
    _currentMeal = Meal(
      id: widget.initialMeal.id,
      name: widget.initialMeal.name,
      time: widget.initialMeal.time,
      accuracyPercentage: widget.initialMeal.accuracyPercentage,
      healthScore: widget.initialMeal.healthScore,
      healthTip: widget.initialMeal.healthTip,
      plates: List<Plate>.from(widget.initialMeal.plates),
      explainationHealth: widget.initialMeal.explainationHealth,
    );
  }

  // --- REFACTORED Add/Remove Functions ---
  void _addPlateToCurrentMeal(Plate newPlate) {
    // Create the new list of plates
    final newPlatesList = List<Plate>.from(_currentMeal.plates)..add(newPlate);
    // Call the central update function
    _updateMealWithNewPlates(newPlatesList);
  }

void _updateMealWithNewPlates(List<Plate> newPlatesList) {
    if (newPlatesList.isEmpty) {
      widget.onMealDeleted(_currentMeal.id);
      Navigator.of(context).pop();
      return;
    }

    final bestCombo = findBestComboForPlates(newPlatesList);

    int newHealthScore = _currentMeal.healthScore;
    int healthScoreAdjustment = newPlatesList.fold(0, (sum, plate) => sum + plate.healthScoreAdd);
    newHealthScore = (newHealthScore + healthScoreAdjustment).clamp(0, 10);

    final updatedMeal = _currentMeal.copyWith(
      plates: newPlatesList,
      healthScore: newHealthScore,
      name: bestCombo?.mealName ?? "Custom Meal",
      healthTip: bestCombo?.healthTip ?? "Review your plates for a balanced meal.",
      explainationHealth: bestCombo?.explanation ?? "The balance of your meal has changed.",
    );

    setState(() {
      _currentMeal = updatedMeal;
    });
  }


void _removePlate(String plateId) {
    // Create the new list of plates
    final newPlatesList = List<Plate>.from(_currentMeal.plates)
      ..removeWhere((plate) => plate.id == plateId);

    _updateMealWithNewPlates(newPlatesList);
  }

  void _showHealthScoreInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext bContext) {
        return Padding(
          padding: const EdgeInsets.only(
            top: 10,
            left: 20,
            right: 20,
            bottom: 20,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 25),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/health.svg",
                        width: 33,
                        height: 33,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Why Health Score is ${_currentMeal.healthScore}/10 ?",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColors.caloriesColorNutrients,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25), // Increased spacing
                  Text(
                    "The Health Score rates how balanced your plate is (calories & macros), from 1 (poor) to 10 (ideal).",
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.primaryText,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 30), // Adjusted spacing
                  Text(
                    "This meal scores ${_currentMeal.healthScore}/10 ${_currentMeal.explainationHealth}",
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.primaryText,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),

              // Positioned X button
              Positioned(
                top: -5,
                right: -15,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      Navigator.pop(bContext);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: SvgPicture.asset(
                        'assets/icons/close.svg',
                        width: 35,
                        height: 35,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color gradientStart = AppColors.backgroundGradientStart;
    const Color gradientEnd = AppColors.backgroundGradientEnd;

    return WillPopScope(
      onWillPop: () async {
        widget.onMealUpdated(_currentMeal);
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar:
            true, // Allows body gradient to go behind AppBar
        appBar: AppBar(
          backgroundColor: Colors.transparent, // Transparent to show gradient
          elevation: 0,
          scrolledUnderElevation: 0,
          leadingWidth: 70, // To give space for the circular button
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: InkWell(
              // Use InkWell for tap effect
              onTap: () {
                widget.onMealUpdated(_currentMeal);
                Navigator.of(context).pop();
              },
              customBorder: const CircleBorder(),
              child: Container(
                height: 50, // Explicit height
                width: 50, // Explicit width
                decoration: BoxDecoration(
                  color: AppColors.backButton.withOpacity(
                    0.3,
                  ), // Semi-transparent white
                  shape: BoxShape.circle,
                ),
                child: Transform.scale(
                  scale: 0.6,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/icons/back.svg',
                    height: 16,
                    width: 16,
                  ),
                ),
              ),
            ),
          ),
          title: Text(
            _currentMeal.name,
            style: const TextStyle(
              color: AppColors.primaryText,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor:
                Colors.transparent, // Make status bar transparent for gradient
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [gradientStart, gradientEnd],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height:
                        kToolbarHeight +
                        MediaQuery.of(context).padding.top +
                        10,
                  ), // Space for AppBar and status bar + some margin
                  _buildMainInfoCard(), // The large white container
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Meal's Plates",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: _buildPlatesList()),
                ],
              ),
              _buildBottomFadeGradient(gradientEnd), // Gradient for the bottom
              widget.selectedDay == "Today"
                  ? _buildFloatingActionButton()
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.cardNutrients,
        borderRadius: BorderRadius.circular(
          25,
        ), // Rounded corners for the container
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Important to make column wrap content
        children: [
          _buildTimeAndAccuracy(),
          const SizedBox(height: 20),
          _buildCaloriesSummary(),
          const SizedBox(height: 16),
          _buildMacrosRow(),
          const SizedBox(height: 20),
          _buildHealthScoreSection(),
        ],
      ),
    );
  }

  Widget _buildPlatesList() {
    if (_currentMeal.plates.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "No plates in this meal.",
            style: TextStyle(color: AppColors.secondaryText),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(
        bottom: 60,
        top: 0,
      ), // Padding for the list
      itemCount: _currentMeal.plates.length,
      itemBuilder: (context, index) {
        final plate = _currentMeal.plates[index];
        return PlateListItem(
          plate: plate,
          onDelete: () => _removePlate(plate.id),
        );
      },
    );
  }

  Widget _buildTimeAndAccuracy() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4.0,
      ), // Slight horizontal padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _currentMeal.time,
            style: const TextStyle(color: AppColors.primaryText, fontSize: 12),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/accuracy.svg',
                  height: 15,
                  width: 15,
                  colorFilter: ColorFilter.mode(
                    AppColors.primaryText,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  "Accuracy : ${_currentMeal.accuracyPercentage}%",
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesSummary() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 35.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/fire_icon.svg',
            height: 30,
            width: 23,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ), // Black fire icon
          const SizedBox(width: 40),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 8),
              Text(
                "Calories",
                style: TextStyle(
                  color: AppColors.caloriesColorNutrients,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
              Text(
                _currentMeal.totalCalories.toString(),
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard(
    String label,
    String value,
    String iconAsset,
    Color iconColor,
  ) {
    return Expanded(
      child: Container(
        // Changed from Card to Container
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  iconAsset,
                  height: 17,
                  width: 17,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.caloriesColorNutrients,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 0),
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Text(
                value,
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacrosRow() {
    return Row(
      children: [
        _buildMacroCard(
          "Protein",
          "${_currentMeal.totalProteinGrams}g",
          'assets/icons/protein_icon.svg',
          AppColors.proteinColor,
        ),
        const SizedBox(width: 10),
        _buildMacroCard(
          "Carbs",
          "${_currentMeal.totalCarbsGrams}g",
          'assets/icons/carbs_icon.svg',
          AppColors.carbsColor,
        ),
        const SizedBox(width: 10),
        _buildMacroCard(
          "Fats",
          "${_currentMeal.totalFatsGrams}g",
          'assets/icons/fats_icon.svg',
          AppColors.fatsColor,
        ),
      ],
    );
  }

  Widget _buildHealthScoreSection() {
    return Container(
      height: 123,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          // Main content row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 4, left: 7),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/health.svg',
                          colorFilter: const ColorFilter.mode(
                            AppColors.caloriesColorNutrients,
                            BlendMode.srcIn,
                          ),
                          height: 14,
                          width: 14,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "Health Score",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.caloriesColorNutrients,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 75,
                      height: 75,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0, // Initial start, will be ignored on subsequent builds
                              end: _currentMeal.healthScore.toDouble(), // The target value
                            ),
                            duration: const Duration(milliseconds: 700), // Animation duration
                            curve: Curves.easeInOutCubic, // Animation curve
                            builder: (context, animatedValue, child) {
                              return CustomPaint(
                                size: const Size(70, 70),
                                painter: HealthScorePainter(
                                  animatedScore: animatedValue,
                                  targetScore: _currentMeal.healthScore,
                                  maxScore: 10,
                                ),
                                child: child, // Pass the child to the painter
                              );
                            },
                            // The child is passed to the builder so it doesn't rebuild on every frame
                            child: Center(
                              child: Text(
                                "${_currentMeal.healthScore}/10",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryText,
                                ),
                              ),
                            ),
                          ),
                          // Score text inside the circle
                          Text(
                            "${_currentMeal.healthScore.round()}/10",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Vertical Divider
              Container(
                width: 1,
                color: AppColors.primaryText,
                margin: const EdgeInsets.symmetric(horizontal: 10),
              ),
              // Right: Tip
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0, right: 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "How to make this meal healthier?",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.caloriesColorNutrients,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentMeal.healthTip,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 4,
            left: -18,
            child: GestureDetector(
              onTap: () {
                _showHealthScoreInfoSheet(context);
              },
              child: Container(
                width: 70,
                height: 70,
                padding: const EdgeInsets.all(25), // Centers the icon
                child: SvgPicture.asset(
                  'assets/icons/info.svg',
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    // Determine if the "add" button should be shown and what plate to suggest
    Plate? plateToSuggest;
    bool canAdd = false;

    // Check if current meal contains pancake and doesn't contain fruit
    if (_currentMeal.plates.any((p) => p.id == pancakePlate.id) &&
        !_currentMeal.plates.any((p) => p.id == fruitPlate.id)) {
      plateToSuggest = fruitPlate;
      canAdd = true;
    }
    // Check if current meal contains pasta and doesn't contain salad
    else if (_currentMeal.plates.any((p) => p.id == pastaPlate.id) &&
        !_currentMeal.plates.any((p) => p.id == saladPlate.id)) {
      plateToSuggest = saladPlate;
      canAdd = true;
    }

  /*  if (!canAdd) {
      return const SizedBox.shrink(); // Don't show button if nothing can be added
    }*/

    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          width: 80,
          height: 80,
          child: FloatingActionButton(
            onPressed: () async {
              // Navigate to ScannerScreen in addPlate mode
              final capturedPlate = await Navigator.push(
                context,
                SlideFromBottomRoute(
                  page: ScannerScreen(
                    mode: ScannerMode.addPlate,
                    suggestedPlateForCapture: plateToSuggest,
                    // Pass current state values from the parent widget
                    isTodayMealsEmpty: false, // Not relevant for adding to existing meal
                    isPancakeMealDone: false, // Not relevant for adding to existing meal
                    isPastaMealDone: false, // Not relevant for adding to existing meal
                    hasAddedSaladToPasta: false, // Not relevant for adding to existing meal
                    hasAddedFruitToPancake: false, // Not relevant for adding to existing meal
                    onFlowCompleted: (Meal createdMeal, {required bool isPancakeMealDone, required bool isPastaMealDone, required bool hasAddedSaladToPasta, required bool hasAddedFruitToPancake}) {
                      // This callback is not expected to be fully utilized in addPlate mode,
                      // as we only care about the single plate returned.
                      // However, to satisfy the non-nullable type, we provide an empty function.
                    },
                  ),
                ),
              );

              if (capturedPlate != null && capturedPlate is Plate) {
                _addPlateToCurrentMeal(capturedPlate);
              }
            },
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 3.0,
            shape: const CircleBorder(),
            child: SvgPicture.asset(
              "assets/icons/plus.svg",
              width: 40,
              height: 40,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildBottomFadeGradient(Color pageBottomColor) {
  return Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: IgnorePointer(
      child: Container(
        height: 60.0, // Adjust height of the fade effect
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              pageBottomColor.withOpacity(0),
              pageBottomColor.withOpacity(1),
              pageBottomColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    ),
  );
}
