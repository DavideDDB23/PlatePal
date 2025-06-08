import 'package:plate_pal/models/meal_model.dart';
import 'package:plate_pal/models/plate_model.dart';

// import 'package:intl/intl.dart';
// String _currentTime() => DateFormat('HH:mm').format(DateTime.now());

// ======================================================================
// --- 1. DEFINE ALL INDIVIDUAL PLATES ---
// ======================================================================

// --- YESTERDAY'S PLATES ---

final Plate cornettoPlate = Plate(
  name: 'Plain Cornetto',
  imageUrl: 'assets/images/cornetto.jpeg',
  calories: 220,
  proteinGrams: 4,
  carbsGrams: 28,
  fatsGrams: 10,
  healthScoreAdd: 1, // Removing improves balance.
);

final Plate cappuccinoPlate = Plate(
  name: 'Cappuccino',
  imageUrl: 'assets/images/cappuccino.jpg',
  calories: 90,
  proteinGrams: 4,
  carbsGrams: 9,
  fatsGrams: 6,
  healthScoreAdd: 0, // Neutral.
);

final Plate pizzaPlate = Plate(
  name: 'Pizza',
  imageUrl: 'assets/images/pizza.png',
  calories: 850,
  proteinGrams: 32,
  carbsGrams: 90,
  fatsGrams: 38,
  healthScoreAdd: 1,
);

final Plate gelatoPlate = Plate(
  name: 'Gelato',
  imageUrl: 'assets/images/gelato.jpg',
  calories: 450,
  proteinGrams: 6,
  carbsGrams: 50,
  fatsGrams: 22,
  healthScoreAdd: 2,
);

final Plate lasagnaPlate = Plate(
  name: 'Bolognese Lasagna',
  imageUrl: 'assets/images/lasagna.jpg',
  calories: 400,
  proteinGrams: 20,
  carbsGrams: 35,
  fatsGrams: 20,
  healthScoreAdd: 1,
);

final Plate potatoesPlate = Plate(
  name: 'Baked Potatoes',
  imageUrl: 'assets/images/patate.png',
  calories: 180,
  proteinGrams: 4,
  carbsGrams: 37,
  fatsGrams: 2,
  healthScoreAdd: 0,
);

final Plate tiramisuPlate = Plate(
  name: 'Tiramisù',
  imageUrl: 'assets/images/tiramisu.jpeg',
  calories: 420,
  proteinGrams: 6,
  carbsGrams: 45,
  fatsGrams: 25,
  healthScoreAdd: 2,
);

// --- TODAY'S PLATES ---

final Plate pancakePlate = Plate(
  name: 'Pancake',
  imageUrl: 'assets/images/pancakeCamera.png',
  calories: 780,
  proteinGrams: 28,
  carbsGrams: 120,
  fatsGrams: 35,
  healthScoreAdd: 0,
);

final Plate pastaPlate = Plate(
  name: 'Pasta Bolognese',
  imageUrl: 'assets/images/pasta.png',
  calories: 650,
  proteinGrams: 35,
  carbsGrams: 90,
  fatsGrams: 20,
  healthScoreAdd: 0,
);

final Plate saladPlate = Plate(
  name: 'Salad',
  imageUrl: 'assets/images/saladCamera.png',
  calories: 150,
  proteinGrams: 5,
  carbsGrams: 15,
  fatsGrams: 8,
  healthScoreAdd: 0,
);

// ======================================================================
// --- 2. DEFINE MEAL ---
// ======================================================================

// --- YESTERDAY'S MEALS ---

final List<Meal> yesterdayMealsMock = [
  Meal(
    name: 'Italian Breakfast',
    time: '09:35',
    accuracyPercentage: 90,
    healthScore: 3,
    healthTip:"Try a whole grain cornetto and add Greek yogurt for protein.",
    explainationHealth: "because it is high in refined carbs and low in protein and fiber. It lacks the nutritional balance needed for sustained energy and satiety.",
    plates: [cornettoPlate, cappuccinoPlate],
  ),
  Meal(
    name: 'Double Temptation',
    time: '15:00',
    accuracyPercentage: 95,
    healthScore: 4,
    healthTip: "Use whole wheat dough and add chicken for more fiber and protein.",
    explainationHealth: "due to being high in calories, saturated fats, and refined carbs, while lacking fiber and sufficient protein.",
    plates: [pizzaPlate, gelatoPlate],
  ),
  Meal(
    name: 'Italian Dinner',
    time: '20:40',
    accuracyPercentage: 93,
    healthScore: 3,
    healthTip: "Add a side salad or grilled vegetables to boost fiber and reduce calorie density.",
    explainationHealth: "due to being high in calories, saturated fats, and refined carbs, while lacking fiber and lean protein. Adding vegetables and reducing dessert portions could improve balance.",
    plates: [lasagnaPlate, potatoesPlate, tiramisuPlate],
  )
];

Meal createPancakeMeal() {
  return Meal(
    name: 'Pancakes',
    time: '08:30',
    accuracyPercentage: 92,
    healthScore: 3,
    healthTip: "Use whole wheat flour for more fiber next time.",
    explainationHealth:
        "This meal has a low score due to high carbohydrates and fats.",
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
    explainationHealth:
        "This meal is balanced but could use more micronutrients.",
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
    explainationHealth:
        "A balanced meal with good macro and micro-nutrient distribution.",
    plates: [pastaPlate, saladPlate],
  );
}
