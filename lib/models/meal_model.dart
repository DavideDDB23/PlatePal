import 'package:plate_pal/models/plate_model.dart'; // Import the new Plate model
import 'package:uuid/uuid.dart';

class Meal {
  final String id;
  String name; // Meal name can be changed if needed, e.g., based on plates
  final List<Plate> plates;
  final String time;
  final int accuracyPercentage; // e.g., 85
  final int healthScore; // e.g., 3 for 3/10
  final String healthTip;

  Meal({
    String? id,
    required this.name,
    required this.plates,
    required this.time,
    this.accuracyPercentage = 85, // Default value
    this.healthScore = 3,         // Default value
    this.healthTip = "Add some greek yogurt to increase protein.", // Default
  }) : id = id ?? const Uuid().v4();

  // Calculated properties
  int get totalCalories => plates.fold(0, (sum, plate) => sum + plate.calories);
  int get totalProteinGrams => plates.fold(0, (sum, plate) => sum + plate.proteinGrams);
  int get totalCarbsGrams => plates.fold(0, (sum, plate) => sum + plate.carbsGrams);
  int get totalFatsGrams => plates.fold(0, (sum, plate) => sum + plate.fatsGrams);

  // For the mosaic view on HomeScreen
  List<String> get imageUrls {
    if (plates.isEmpty) return [];
    return plates.map((plate) => plate.imageUrl).toList();
  }

  // Helper to check if meal is empty (no plates)
  bool get isEmpty => plates.isEmpty;
}