import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plate_pal/screens/pictures_screen.dart';
import 'package:plate_pal/utils/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plate_pal/models/meal_model.dart';
import 'package:plate_pal/data/mock_data.dart';
import 'package:plate_pal/models/plate_model.dart'; // Import Plate model for imageUrl access

enum ScannerMode { createMeal, addPlate } // New enum

class ScannerScreen extends StatefulWidget {
  final Function(Meal createdMeal, {required bool isPancakeMealDone, required bool isPastaMealDone, required bool hasAddedSaladToPasta, required bool hasAddedFruitToPancake})? onFlowCompleted; // Made optional
  final Plate? suggestedPlateForCapture; // New parameter
  final ScannerMode mode; // New parameter

  final bool isTodayMealsEmpty;
  final bool isPancakeMealDone;
  final bool isPastaMealDone;
  final bool hasAddedSaladToPasta;
  final bool hasAddedFruitToPancake;

  const ScannerScreen({
    Key? key,
    this.onFlowCompleted, // Made optional for addPlate mode
    this.suggestedPlateForCapture, // Initialize new parameter
    this.mode = ScannerMode.createMeal, // Default mode
    required this.isTodayMealsEmpty,
    required this.isPancakeMealDone,
    required this.isPastaMealDone,
    required this.hasAddedSaladToPasta,
    required this.hasAddedFruitToPancake,
  }) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isFlashOn = false;

  String _getBackgroundImagePath() {
    if (widget.mode == ScannerMode.addPlate && widget.suggestedPlateForCapture != null) {
      return widget.suggestedPlateForCapture!.imageUrl;
    }
    if (widget.isTodayMealsEmpty) {
      return 'assets/images/pancakeCamera.png';
    } else if (widget.isPancakeMealDone && !widget.isPastaMealDone) {
      return 'assets/images/pasta.png';
    } else {
      // Default or other conditions if any
      return 'assets/images/pancakeCamera.png'; // Fallback
    }
  }

  void _showScannerHelpInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      builder: (BuildContext bContext) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 60,
                left: 15,
                right: 15,
                bottom: 50,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      text: 'Take a photo of one plate at a time.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "Each photo adds to the full meal.",
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "Make sure to take the photo from above, with the plate fully visible in the frame.",
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.primaryText,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "Then you can check the photos and tap the trash icon to remove one, or the "+" to add a new one.",
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.primaryText,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: 10,
              right: 10,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    Navigator.pop(bContext);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      // Use decoration if you want shaped background
                      color: Colors.black, // From your image
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/close_2.svg',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onCapture() {
    if (widget.mode == ScannerMode.addPlate && widget.suggestedPlateForCapture != null) {
      // In addPlate mode, pop and return the captured plate
      Navigator.of(context).pop(widget.suggestedPlateForCapture);
      return;
    }

    // Original logic for createMeal mode
    String imageToUse;
    if (widget.isTodayMealsEmpty) {
      imageToUse = pancakePlate.imageUrl;
    } else if (widget.isPancakeMealDone && !widget.isPastaMealDone) {
      imageToUse = pastaPlate.imageUrl;
    } else {
      // Default or other conditions if any
      imageToUse = pancakePlate.imageUrl; // Fallback
    }

    final List<String> initialPicture = [imageToUse];

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                PicturesScreen(
                  initialPicturePaths: initialPicture,
                  onFlowCompleted: (Meal createdMeal, {required bool isPancakeMealDone, required bool isPastaMealDone, required bool hasAddedSaladToPasta, required bool hasAddedFruitToPancake}) {
                    widget.onFlowCompleted!(
                      createdMeal,
                      isPancakeMealDone: isPancakeMealDone,
                      isPastaMealDone: isPastaMealDone,
                      hasAddedSaladToPasta: hasAddedSaladToPasta,
                      hasAddedFruitToPancake: hasAddedFruitToPancake,
                    );
                  },
                  isPancakeMealDone: widget.isPancakeMealDone,
                  isPastaMealDone: widget.isPastaMealDone,
                  hasAddedSaladToPasta: widget.hasAddedSaladToPasta,
                  hasAddedFruitToPancake: widget.hasAddedFruitToPancake,
                  isTodayMealsEmpty: widget.isTodayMealsEmpty,
                ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String backgroundImagePath = _getBackgroundImagePath();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        // Makes status bar icons light
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor:
            Colors.black, // Fallback if image fails or for areas not covered
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.asset(
              backgroundImagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image fails to load
                return Container(
                  color: Colors.grey[800],
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error loading background image.\nMake sure "$backgroundImagePath" exists and is declared in pubspec.yaml.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height:
                  MediaQuery.of(context).size.height /
                  4.5, // 1/5th of screen height
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(1),
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.5, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            // Top Bar UI (Close, Title, Help)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        // Use InkWell for tap effect
                        onTap: () {
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
                              'assets/icons/close_2.svg',
                              height: 20,
                              width: 20,
                            ),
                          ),
                        ),
                      ),
                      const Text(
                        'Scanner',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _showScannerHelpInfo(context); // Show help info
                        },
                        customBorder:
                            const CircleBorder(), // For circular tap ripple
                        child: Container(
                          height:
                              50, // Match the width of the left button's container
                          width:
                              50, // Match the width of the left button's container
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          alignment:
                              Alignment
                                  .centerRight, // Center the SVG within this 50x50 container
                          child: SvgPicture.asset(
                            'assets/icons/question.svg',
                            width:
                                25, // Actual desired size of the question mark SVG
                            height: 25,
                            // If question.svg is single color and needs to be white:
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: SvgPicture.asset(
                'assets/icons/frame.svg',
                fit: BoxFit.contain,
              ),
            ),

            // Bottom Controls (Flash, Capture)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildCircularIconButton(
                        icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        iconColor: Colors.black,
                        onPressed: () {
                          setState(() {
                            _isFlashOn = !_isFlashOn;
                          });
                        },
                        iconSize: 24,
                        padding: 10,
                      ),
                      GestureDetector(
                        onTap: _onCapture,
                        child: Container(
                          width: 80,
                          height: 80,
                          padding: const EdgeInsets.all(
                            3.5,
                          ), // Space for the outer border
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3.5),
                          ),
                          child: Container(
                            // Inner white circle
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 24 + 10 * 2,
                      ), // Spacer to balance row (iconSize + padding*2)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    double iconSize = 28.0,
    double padding = 8.0,
    Color iconColor = Colors.white,
  }) {
    return Material(
      // Use Material for InkWell ripple effect
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: iconSize),
        ),
      ),
    );
  }
}
