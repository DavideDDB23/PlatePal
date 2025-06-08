import 'package:plate_pal/models/meal_model.dart';
import 'package:plate_pal/models/plate_model.dart';

// --- Predefined Plates ---
final Plate pancakePlate = Plate(
  name: 'Pancake',
  imageUrl: 'assets/images/pancakeCamera.png', 
  calories: 780,
  proteinGrams: 28,
  carbsGrams: 120,
  fatsGrams: 35,
);

final Plate pastaPlate = Plate(
  name: 'Pasta Bolognese',
  imageUrl: 'assets/images/pasta.png',
  calories: 650,
  proteinGrams: 35,
  carbsGrams: 90,
  fatsGrams: 20,
);

final Plate saladPlate = Plate(
  name: 'Salad',
  imageUrl: 'assets/images/saladCamera.png',
  calories: 150,
  proteinGrams: 5,
  carbsGrams: 15,
  fatsGrams: 8,
);


Meal createPancakeMeal() {
  return Meal(
    name: 'Pancakes',
    time: '08:30',
    accuracyPercentage: 92,
    healthScore: 3,
    healthTip: "Use whole wheat flour for more fiber next time.",
    explainationHealth: "This meal has a low score due to high carbohydrates and fats.",
    plates: [pancakePlate],
  );
}

Meal createPastaMeal() {
  return Meal(
    name: 'Pasta',
    time: '13:00',
    accuracyPercentage: 88,
    healthScore: 5,
    healthTip: "Add a side of vegetables to balance the meal.",
    explainationHealth: "This meal is balanced but could use more micronutrients.",
    plates: [pastaPlate],
  );
}

Meal createSaladMeal() {
  return Meal(
    name: 'Salad',
    time: '12:45',
    accuracyPercentage: 95,
    healthScore: 9,
    healthTip: "Great choice! This is a well-balanced and healthy meal.",
    explainationHealth: "High in fiber and nutrients, a very healthy option.",
    plates: [saladPlate],
  );
}

Meal createPastaAndSaladMeal() {
  return Meal(
    name: 'Pasta & Salad',
    time: '13:15',
    accuracyPercentage: 90,
    healthScore: 7,
    healthTip: "Good combination of carbs and greens.",
    explainationHealth: "A balanced meal with good macro and micro-nutrient distribution.",
    plates: [pastaPlate, saladPlate],
  );
}