import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plate_pal/utils/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plate_pal/data/mock_data.dart';
import 'package:plate_pal/models/meal_model.dart';
import 'package:plate_pal/models/plate_model.dart';
import 'package:plate_pal/screens/scanner_screen.dart';

class PicturesScreen extends StatefulWidget {
  final List<String> initialPicturePaths;
  final Function(Meal createdMeal, {required bool isPancakeMealDone, required bool isPastaMealDone, required bool hasAddedSaladToPasta, required bool hasAddedFruitToPancake}) onFlowCompleted;

  final bool isPancakeMealDone;
  final bool isPastaMealDone;
  final bool hasAddedSaladToPasta;
  final bool hasAddedFruitToPancake;
  final bool isTodayMealsEmpty;

  const PicturesScreen({
    Key? key,
    this.initialPicturePaths = const [],
    required this.onFlowCompleted,
    required this.isPancakeMealDone,
    required this.isPastaMealDone,
    required this.hasAddedSaladToPasta,
    required this.hasAddedFruitToPancake,
    required this.isTodayMealsEmpty,
  }) : super(key: key);

  @override
  State<PicturesScreen> createState() => _PicturesScreenState();
}

class _PicturesScreenState extends State<PicturesScreen> {
  late List<String> _picturePaths;
  late PageController _pageController;
  int _currentIndex = 0;
  bool _areInitialImagesPrecached = false;

  // Map asset paths to Plate objects for easy logic
  final Map<String, Plate> _assetToPlateMap = {
    pancakePlate.imageUrl: pancakePlate,
    fruitPlate.imageUrl: fruitPlate,
    pastaPlate.imageUrl: pastaPlate,
    saladPlate.imageUrl: saladPlate,
  };


  @override
  void initState() {
    super.initState();
    _picturePaths = List.from(widget.initialPicturePaths);
    _currentIndex = 0;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_areInitialImagesPrecached) {
      // Precache all initial images for PicturesScreen (main image and thumbnails)
      for (String path in _picturePaths) {
        precacheImage(AssetImage(path), context);
      }
      _areInitialImagesPrecached = true;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _deleteCurrentImage() {
    if (_picturePaths.isEmpty) return;

    setState(() {
      _picturePaths.removeAt(_currentIndex);
      if (_picturePaths.isEmpty) {
        Navigator.pop(context);
      } else if (_currentIndex >= _picturePaths.length) {
        _currentIndex = _picturePaths.length - 1;
        _pageController.jumpToPage(_currentIndex);
      }
      if (_picturePaths.isEmpty) {
        Navigator.pop(context);
      }
    });
  }

  void _navigateToAddPicture() async {
    Plate? plateToSuggest;

    // Determine which plate to offer based on current pictures
    if (_picturePaths.contains(pancakePlate.imageUrl) &&
        !_picturePaths.contains(fruitPlate.imageUrl)) {
      plateToSuggest = fruitPlate;
    } else if (_picturePaths.contains(pastaPlate.imageUrl) &&
        !_picturePaths.contains(saladPlate.imageUrl)) {
      plateToSuggest = saladPlate;
    }

    if (plateToSuggest != null) {
      // Precache the suggested plate image before pushing ScannerScreen
      await precacheImage(AssetImage(plateToSuggest.imageUrl), context);

      // Pop current PicturesScreen, then push ScannerScreen
      // Await the result from ScannerScreen (the captured plate)
      final capturedPlate = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => ScannerScreen(
            mode: ScannerMode.addPlate, // Set mode to add a single plate
            suggestedPlateForCapture: plateToSuggest, // Pass the suggested plate
            isTodayMealsEmpty: widget.isTodayMealsEmpty, // Pass this to ScannerScreen
            isPancakeMealDone: widget.isPancakeMealDone,
            isPastaMealDone: widget.isPastaMealDone,
            hasAddedSaladToPasta: widget.hasAddedSaladToPasta,
            hasAddedFruitToPancake: widget.hasAddedFruitToPancake,
            onFlowCompleted: widget.onFlowCompleted,
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );

      // If a plate was captured (returned from ScannerScreen)
      if (capturedPlate != null && capturedPlate is Plate) {
        // Precache the newly captured image before adding to list and updating UI
        await precacheImage(AssetImage(capturedPlate.imageUrl), context);

        setState(() {
          _picturePaths.add(capturedPlate.imageUrl);
          _currentIndex = _picturePaths.length - 1;
          _pageController.jumpToPage(_currentIndex);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No more plates can be added for this meal.")),
      );
    }
  }

  void _done() {
    if (_picturePaths.isEmpty) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    Meal finalMeal;
    bool updatedIsPancakeMealDone = widget.isPancakeMealDone;
    bool updatedIsPastaMealDone = widget.isPastaMealDone;
    bool updatedHasAddedSaladToPasta = widget.hasAddedSaladToPasta;
    bool updatedHasAddedFruitToPancake = false;

    Set<Plate> finalPlates = _picturePaths
        .map((path) => _assetToPlateMap[path])
        .where((plate) => plate != null)
        .cast<Plate>()
        .toSet();

    // Determine the meal and update state based on conditions
    if (finalPlates.length == 1 && finalPlates.contains(pancakePlate)) {
      finalMeal = createPancakeMeal();
      updatedIsPancakeMealDone = true;
    } else if (finalPlates.length == 2 && finalPlates.contains(pancakePlate) && finalPlates.contains(fruitPlate)) {
      finalMeal = createPancakeAndFruitMeal();
      updatedIsPancakeMealDone = true;
      updatedHasAddedFruitToPancake = true;
    } else if (finalPlates.length == 1 && finalPlates.contains(fruitPlate)) {
      finalMeal = createFruitMeal();
      updatedIsPancakeMealDone = true;
    } else if (finalPlates.length == 1 && finalPlates.contains(pastaPlate)) {
      finalMeal = createPastaMeal();
      updatedIsPastaMealDone = true;
    } else if (finalPlates.length == 2 && finalPlates.contains(pastaPlate) && finalPlates.contains(saladPlate)) {
      finalMeal = createPastaAndSaladMeal();
      updatedHasAddedSaladToPasta = true;
      updatedIsPastaMealDone = true;
    } else if (finalPlates.length == 1 && finalPlates.contains(saladPlate)) {
      finalMeal = createSaladMeal();
    } else {
      // Fallback for any other combination or if plates are empty (should be caught by _picturePaths.isEmpty)
      // For now, take the first plate if available
      if (finalPlates.isNotEmpty) {
        finalMeal = Meal(
          name: finalPlates.first.name,
          plates: [finalPlates.first],
          time: "12:00", // Default
          accuracyPercentage: 85,
          healthScore: 4,
          healthTip: "Tip for this plate.",
          explainationHealth: "Explanation for this plate.",
        );
      } else {
        // If for some reason finalPlates is empty here, return
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      }
    }

    // Call the callback with the created meal and updated state
    widget.onFlowCompleted(
      finalMeal,
      isPancakeMealDone: updatedIsPancakeMealDone,
      isPastaMealDone: updatedIsPastaMealDone,
      hasAddedSaladToPasta: updatedHasAddedSaladToPasta,
      hasAddedFruitToPancake: updatedHasAddedFruitToPancake,
    );

    // Close the entire flow and return to HomeScreen
    Navigator.of(context).popUntil((route) => route.isFirst);
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
                      color: Colors.black,
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

  @override
  Widget build(BuildContext context) {
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
            if (_picturePaths.isNotEmpty)
              PageView.builder(
                controller: _pageController,
                itemCount: _picturePaths.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final String imagePath = _picturePaths[index];
                  return Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: Text(
                            'Error Loading Image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            else
              Container(
                color: Colors.grey[900],
                child: const Center(
                  child: Text(
                    "No pictures yet. Add one!",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
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
                              'assets/icons/back.svg',
                              height: 20,
                              width: 20,
                            ),
                          ),
                        ),
                      ),
                      const Text(
                        'Pictures',
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
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 70,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.only(left: 16.0),
                                itemCount: _picturePaths.length,
                                itemBuilder: (context, index) {
                                  bool isSelected = index == _currentIndex;
                                  return _buildThumbnailItem(
                                    imagePath: _picturePaths[index],
                                    isSelected: isSelected,
                                    isDeletable: isSelected,
                                    onTap: () {
                                      setState(() {
                                        _currentIndex = index;
                                        _pageController.animateToPage(
                                          index,
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      });
                                    },
                                    onDelete: _deleteCurrentImage,
                                  );
                                },
                              ),
                            ),
                            // Add New Picture Button at the end of the row
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                              ),
                              child: _buildAddButton(_navigateToAddPicture),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      // Done Button
                      ElevatedButton(
                        onPressed: _done,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(
                            200,
                            55,
                          ), // Full width, fixed height
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(70),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  Widget _buildThumbnailItem({
    required String imagePath,
    required bool isSelected,
    required bool isDeletable,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70, // Thumbnail width
        height: 70, // Thumbnail height
        margin: const EdgeInsets.symmetric(horizontal: 6.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(imagePath, fit: BoxFit.cover),
              if (isDeletable)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(196, 95, 99, 0.5),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/bin.svg',
                          width: 35,
                          height: 35,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 70,
        height: 70,
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/add.svg',
            width: 70,
            height: 70,
          ),
        ),
      ),
    );
  }
}
