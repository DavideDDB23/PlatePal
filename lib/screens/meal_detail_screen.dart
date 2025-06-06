import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plate_pal/models/meal_model.dart';
import 'package:plate_pal/models/plate_model.dart';
import 'package:plate_pal/utils/app_colors.dart';
import 'package:plate_pal/widgets/plate_list_item.dart';

class HealthScorePainter extends CustomPainter {
  final int healthScore; // Actual score (0-10)
  final int maxScore;    // Typically 10

  HealthScorePainter({required this.healthScore, this.maxScore = 10});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Radius should be small enough to leave space for the 'i' icon if it's outside
    final radius = size.width / 2 * 0.9; // Adjusted for a potentially tighter fit
    const strokeWidth = 8.0; // Slightly thicker than before to match image

    // Background Arc (light pinkish/grey)
    Paint backgroundPaint = Paint()
      ..color = const Color(0xFFF0D9D9) // Light pinkish grey from image
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Foreground Arc (Progress)
    Color progressColor;
    if (healthScore <= 5) {
      progressColor = const Color(0xFFD32F2F); // Darker Red from image
    } else if (healthScore <= 8) {
      // You might need a specific color for 6-8 if it's different in your design.
      // For now, let's assume it transitions or uses a mid-tier color.
      // If the image only shows red, then we might not need this middle segment.
      // Let's use orange as a placeholder for 6-8, adjust if needed.
      progressColor = Colors.orangeAccent; // Placeholder - adjust if design has a specific color
    } else {
      // Assuming green for 9-10, adjust if different
      progressColor = AppColors.proteinColor; // Or a specific green
    }

    Paint foregroundPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Rounded ends for the progress arc

    double sweepAngle = (2 * 3.1415926535) * (healthScore / maxScore);
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
    return oldDelegate.healthScore != healthScore || oldDelegate.maxScore != maxScore;
  }
}

class MealDetailScreen extends StatefulWidget {
  final Meal initialMeal;
  final Function(Meal updatedMeal) onMealUpdated;
  final Function(String mealId) onMealDeleted;

  const MealDetailScreen({
    Key? key,
    required this.initialMeal,
    required this.onMealUpdated,
    required this.onMealDeleted,
  }) : super(key: key);

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
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
    );
  }

  void _removePlate(String plateId) {
    bool mealWasModified = false;
    final initialLength = _currentMeal.plates.length;
    _currentMeal.plates.removeWhere((plate) => plate.id == plateId);
    if (_currentMeal.plates.length < initialLength) {
      mealWasModified = true;
    }

    if (_currentMeal.isEmpty) {
      widget.onMealDeleted(_currentMeal.id);
      Navigator.of(context).pop();
    } else if (mealWasModified) {
      setState(() {});
    }
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
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: InkWell(
                onTap: () {},
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(
                    10,
                  ), // Adjust padding for icon size
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground.withOpacity(
                      0.8,
                    ), // Semi-transparent white
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/delete_icon.svg', // Ensure you have this icon
                    height: 22,
                    width: 22,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryText,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ],
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height:
                    kToolbarHeight + MediaQuery.of(context).padding.top + 10,
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
              Expanded(
                // This will contain the scrollable list of plates
                child: _buildPlatesList(),
              ),
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
        bottom: 20,
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
    // Define colors from the image for better accuracy
    const Color healthScoreTitleColor = Color(0xFF6A6A8B); // Purplish grey for title
    const Color healthTipTitleColor = Color(0xFF6A6A8B); // Same for "How to make..."
    const Color healthTipTextColor = AppColors.primaryText;
    const Color infoIconBackgroundColor = Colors.black;
    const Color infoIconColor = Colors.white;

    return Container(
      padding: EdgeInsets.only(left: 0.0),
      height: 123,
      decoration: BoxDecoration(
        color:AppColors.cardBackground,
        borderRadius: BorderRadius.circular(25), // Rounded corners of the card
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align children to the top of the Row
        children: [
          // Left: Health Score
          Expanded(
            flex: 3, // Adjust flex to give more space if needed
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                height: 9, // Space between title and progress bar
              ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/health.svg', // Your custom health icon
                      colorFilter: const ColorFilter.mode(healthScoreTitleColor, BlendMode.srcIn),
                      height: 14,
                      width: 14,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "Health Score",
                      style: TextStyle(
                        fontSize: 14,
                        color: healthScoreTitleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 75, 
                  height: 75,
                  child: Stack(
                    clipBehavior: Clip.none, // Allow "i" button to overflow if needed
                    alignment: Alignment.center,
                    children: [
                      // The circular progress bar
                      CustomPaint(
                        size: const Size(70, 70), // Match SizedBox
                        painter: HealthScorePainter(
                          healthScore: _currentMeal.healthScore, // Pass actual score
                          maxScore: 10,
                        ),
                      ),
                      // Text "3/10" inside the circle
                      Text(
                        "${_currentMeal.healthScore}/10",
                        style: const TextStyle(
                          fontSize: 18, // Larger font for score
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryText,
                        ),
                      ),
                      // "i" button positioned on the top-left of the progress bar
                      Positioned(
                        top: -5,  // Adjust for precise positioning relative to the circle
                        left: -20, // Adjust for precise positioning
                        child: Container(
                          padding: const EdgeInsets.all(3), // Small padding
                          decoration: const BoxDecoration(
                            color: infoIconBackgroundColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded, // Or Icons.info
                            color: infoIconColor,
                            size: 14, // Smaller icon size
                          ),
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
            color: AppColors.primaryText, // Lighter divider color
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),
          // Right: Tip
          Expanded(
            flex: 4, // Adjust flex
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0), // Align with "Health Score" title
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "How to make this meal healthier?",
                    style: TextStyle(
                      fontSize: 14,
                      color: healthTipTitleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentMeal.healthTip,
                    style: const TextStyle(
                      fontSize: 15, // Slightly larger tip text
                      color: healthTipTextColor,
                      fontWeight: FontWeight.w500,
                      height: 1.3 // Adjust line height for readability
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
    );
  }
}