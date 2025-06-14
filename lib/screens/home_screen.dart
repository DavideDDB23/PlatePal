import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Make sure this is imported
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plate_pal/models/meal_model.dart';
import 'package:plate_pal/utils/app_colors.dart';
import 'package:plate_pal/widgets/calorie_summary_card.dart';
import 'package:plate_pal/widgets/logged_meal_item.dart';
import 'package:plate_pal/screens/meal_detail_screen.dart';
import 'package:plate_pal/screens/scanner_screen.dart';
import 'package:plate_pal/slide_from_bottom_route.dart';
import 'package:plate_pal/data/mock_data.dart';
import 'package:plate_pal/models/plate_model.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedDay = 'Today';
  late ScrollController _scrollController;

  final List<Meal> _todayMeals = [];

  final List<Meal> _yesterdayMeals = yesterdayMealsMock;

  List<Meal> get _currentLoggedMeals =>
      _selectedDay == 'Today' ? _todayMeals : _yesterdayMeals;

  int _totalKcal = 0;
  int _proteinGrams = 0;
  int _carbsGrams = 0;
  int _fatsGrams = 0;

  bool _isPancakeMealDone = false;
  bool _hasAddedFruitToPancake = false;
  bool _isPastaMealDone = false;
  bool _hasAddedSaladToPasta = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _updateSummary();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateSummary() {
    final meals = _currentLoggedMeals;
    // Use the new getters from the Meal model
    _totalKcal = meals.fold(0, (sum, item) => sum + item.totalCalories);
    _proteinGrams = meals.fold(0, (sum, item) => sum + item.totalProteinGrams);
    _carbsGrams = meals.fold(0, (sum, item) => sum + item.totalCarbsGrams);
    _fatsGrams = meals.fold(0, (sum, item) => sum + item.totalFatsGrams);
  }

  @override
  Widget build(BuildContext context) {
    const Color gradientStart = AppColors.backgroundGradientStart;
    const Color gradientEnd = AppColors.backgroundGradientEnd;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleSpacing: 16.0,
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/mela.svg',
              height: 31,
              width: 31,
              colorFilter: const ColorFilter.mode(
                AppColors.primaryText,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'PlatePal',
              style: TextStyle(
                color: AppColors.primaryText,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ],
        ),
        toolbarHeight: 50,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: gradientStart,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      body: Container(
        // Wrap body with Container for the main background gradient
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
                _buildDaySelector(),
                CalorieSummaryCard(
                  totalKcal: _totalKcal,
                  proteinGrams: _proteinGrams,
                  carbsGrams: _carbsGrams,
                  fatsGrams: _fatsGrams,
                ),
                _buildLoggedMealsTitle(),
                Expanded(
                  child: Stack(
                    // Stack for list and bottom fade gradient
                    children: [
                      _buildMealListView(),
                      _selectedDay == "Today"
                          ? _buildBottomFadeGradientToday(gradientEnd)
                          : _buildBottomFadeGradientYesterday(gradientEnd),
                    ],
                  ),
                ),
              ],
            ),

            _selectedDay == "Today"
                ? _buildFloatingActionButton()
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomFadeGradientToday(Color pageBottomColor) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        // Makes the gradient non-interactive
        child: Container(
          height: 130.0, // Adjust height of the fade effect
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                pageBottomColor.withOpacity(0.1),
                pageBottomColor.withOpacity(0.9),
                pageBottomColor.withOpacity(1),
                pageBottomColor,
              ],
              stops: [0, 0.25, 0.35, 1],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomFadeGradientYesterday(Color pageBottomColor) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        // Makes the gradient non-interactive
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

  Widget _buildDaySelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
      child: Row(
        children: [
          _dayTogglePill('Today'),
          const SizedBox(width: 10),
          _dayTogglePill('Yesterday'),
        ],
      ),
    );
  }

  Widget _dayTogglePill(String day) {
    bool isActive = _selectedDay == day;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = day;
          _updateSummary();

          if (_scrollController.hasClients) {
            _scrollController.jumpTo(0.0); // Jump to the top
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              day,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.activeTab,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              height: 4,
              width: 4,
              decoration: BoxDecoration(
                color: isActive ? AppColors.activeTab : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedMealsTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 5.0),
      child: Text(
        'Logged Meals',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryText,
        ),
      ),
    );
  }

  void _handleMealUpdated(Meal updatedMeal) {
    setState(() {
      // Find the index of the meal to update in the correct list
      int todayIndex = _todayMeals.indexWhere((m) => m.id == updatedMeal.id);
      if (todayIndex != -1) {
        _todayMeals[todayIndex] = updatedMeal;
      } else {
        int yesterdayIndex = _yesterdayMeals.indexWhere(
          (m) => m.id == updatedMeal.id,
        );
        if (yesterdayIndex != -1) {
          _yesterdayMeals[yesterdayIndex] = updatedMeal;
        }
      }
      _updateSummary(); // Recalculate totals
    });
  }

  void _handleMealDeletedFromDetailScreen(String mealId) {
    setState(() {
      _todayMeals.removeWhere((meal) => meal.id == mealId);
      _yesterdayMeals.removeWhere((meal) => meal.id == mealId);
      _updateSummary(); // Recalculate totals
    });
  }

  void _addMealToToday(Meal newMeal) {
    setState(() {
      _todayMeals.add(newMeal);
      _updateSummary();
    });
  }

  Widget _buildMealListView() {
    if (_currentLoggedMeals.isEmpty) {
      return Align(
        // Use Align instead of Center
        alignment: const Alignment(0.0, -0.5),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "No meals logged for this day 😔.",
            style: TextStyle(color: AppColors.primaryText, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 120.0, top: 0),
      itemCount: _currentLoggedMeals.length,
      itemBuilder: (context, index) {
        final meal = _currentLoggedMeals[index];
        return GestureDetector(
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => MealDetailScreen(
                      initialMeal: meal,
                      onMealUpdated: _handleMealUpdated,
                      onMealDeleted: _handleMealDeletedFromDetailScreen,
                      selectedDay: _selectedDay,
                    ),
              ),
            );
          },
          child: LoggedMealItem(meal: meal),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          width: 80,
          height: 80,
          child: FloatingActionButton(
            onPressed: () async { // Made onPressed async
              // Determine which image will be shown in ScannerScreen and precache it
              String scannerInitialImagePath;
              if (_todayMeals.isEmpty) {
                scannerInitialImagePath = 'assets/images/pancakeCamera.png';
              } else if (_isPancakeMealDone && !_isPastaMealDone) {
                scannerInitialImagePath = 'assets/images/pasta.png';
              } else {
                scannerInitialImagePath = 'assets/images/pancakeCamera.png';
              }

              await precacheImage(AssetImage(scannerInitialImagePath), context);

              Navigator.push(
                context,
                SlideFromBottomRoute(
                  page: ScannerScreen(
                    onFlowCompleted: (Meal createdMeal, {required bool isPancakeMealDone, required bool isPastaMealDone, required bool hasAddedSaladToPasta, required bool hasAddedFruitToPancake}) {
                      setState(() {
                        _addMealToToday(createdMeal);
                        _isPancakeMealDone = isPancakeMealDone;
                        _isPastaMealDone = isPastaMealDone;
                        _hasAddedSaladToPasta = hasAddedSaladToPasta;
                        _hasAddedFruitToPancake = hasAddedFruitToPancake;
                      });
                    },
                    isTodayMealsEmpty: _todayMeals.isEmpty,
                    isPancakeMealDone: _isPancakeMealDone,
                    isPastaMealDone: _isPastaMealDone,
                    hasAddedSaladToPasta: _hasAddedSaladToPasta,
                    hasAddedFruitToPancake: _hasAddedFruitToPancake,
                    mode: ScannerMode.createMeal,
                  ),
                ),
              );
            },
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 3.0,
            shape: const CircleBorder(),
            child: SvgPicture.asset(
              "assets/icons/camera.svg", // Make sure this icon exists
              width: 40,
              height: 40,
            ),
          ),
        ),
      ),
    );
  }
}
