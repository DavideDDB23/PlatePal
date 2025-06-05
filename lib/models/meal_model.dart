class Meal {
  final String name;
  final List<String> imageUrls;
  final int calories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatsGrams;
  final String time; // e.g., "12:57"

  Meal({
    required this.name,
    required this.imageUrls,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatsGrams,
    required this.time,
  });
}