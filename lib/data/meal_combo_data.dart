import 'package:plate_pal/data/mock_data.dart';
import 'package:plate_pal/models/plate_model.dart';
import 'package:collection/collection.dart';

class MealCombo {
  final Set<String> plateNames;

  final String mealName;
  final String healthTip;
  final String explanation;

  MealCombo({
    required this.plateNames,
    required this.mealName,
    required this.healthTip,
    required this.explanation,
  });
}

// List of all possible meal combinations, ordered from most specific to least specific.
final List<MealCombo> mealCombos = [
  MealCombo(
    plateNames: {cornettoPlate.name},
    mealName: "Sweet Start",
    healthTip: "Add protein like yogurt or eggs to balance the high carbs.",
    explanation: "because the cornetto is high in refined carbs and low in protein, making it an unbalanced breakfast on its own.",
  ),

  MealCombo(
    plateNames: {cappuccinoPlate.name},
    mealName: "Light Coffee Break",
    healthTip: "Pair with a protein-rich snack for a more filling combo.",
    explanation: "because cappuccino alone is low in calories and protein, making it suitable only as a light snack or drink.",
  ),

  MealCombo(
    plateNames: {pizzaPlate.name},
    mealName: "Solo Pizza Plate",
    healthTip: "Add vegetables or lean protein to make it more balanced.",
    explanation: "because pizza is calorie-dense and high in fats and carbs, but lacks fiber and micronutrients.",
  ),

  MealCombo(
    plateNames: {gelatoPlate.name},
    mealName: "Sweet Chill",
    healthTip: "Enjoy occasionally, and consider pairing with fruit or nuts.",
    explanation: "because Gelato is high in sugars and fats, offering little nutritional value aside from calories.",
  ),

  MealCombo(
    plateNames: {lasagnaPlate.name, potatoesPlate.name},
    mealName: "Carb-Heavy Dinner",
    healthTip: "Replace one starchy item with vegetables or salad to improve balance.",
    explanation: "because it is heavy in carbs and fats, with little fiber or micronutrients.",
  ),

  MealCombo(
    plateNames: {lasagnaPlate.name, tiramisuPlate.name},
    mealName: "Indulgent Italian Meal",
    healthTip: "Limit portions or swap dessert for fruit to improve overall health score.",
    explanation: "because it is high in calories, saturated fats, and refined carbs, making it indulgent but unbalanced.",
  ),

  MealCombo(
    plateNames: {potatoesPlate.name, tiramisuPlate.name},
    mealName: "Sweet & Starchy Combo",
    healthTip: "Add protein or fiber to reduce the glycemic load of this meal.",
    explanation: "because combining starches and sugar results in a high glycemic load, with minimal nutritional diversity.",
  ),

  MealCombo(
    plateNames: {lasagnaPlate.name},
    mealName: "Hearty Main",
    healthTip: "Pair with a side salad for fiber and balance.",
    explanation: "because lasagna provides protein and energy but lacks vegetables or fiber.",
  ),

  MealCombo(
    plateNames: {potatoesPlate.name},
    mealName: "Starchy Side",
    healthTip: "Add a lean protein or salad to make this part of a balanced meal.",
    explanation: "because potatoes are a good carb source but are low in protein and fiber when eaten alone.",
  ),

  MealCombo(
    plateNames: {tiramisuPlate.name},
    mealName: "Dessert Delight",
    healthTip: "Enjoy in moderation and pair with a protein-based snack to slow sugar absorption.",
    explanation: "because tiramisu is rich and sugary, best consumed in moderation due to its high fat and sugar content.",
  ),

  MealCombo(
    plateNames: {pancakePlate.name, fruitPlate.name},
    mealName: "Pancakes with Fruit",
    healthTip: "The fruit makes this a much more balanced breakfast.",
    explanation: "because the fiber and vitamins from the fruit complement the meal.",
  ),

  MealCombo(
    plateNames: {pancakePlate.name, fruitPlate.name},
    mealName: "Pancakes & Fruit",
    healthTip: "The fruit makes this a much more balanced breakfast.",
    explanation: "because the fiber and vitamins from the fruit complement the meal.",
  ),

  MealCombo(
    plateNames: {fruitPlate.name},
    mealName: "Fruit",
    healthTip: "The fruit makes this a much more balanced breakfast.",
    explanation: "because the fiber and vitamins from the fruit complement the meal.",
  ),

  MealCombo(
    plateNames: {pancakePlate.name},
    mealName: "Pancakes",
    healthTip: "The fruit makes this a much more balanced breakfast.",
    explanation: "because the fiber and vitamins from the fruit complement the meal.",
  ),
];

MealCombo? findBestComboForPlates(List<Plate> plates) {
  if (plates.isEmpty) {
    return null;
  }

  final currentPlateNames = plates.map((p) => p.name).toSet();

  for (final combo in mealCombos) {
    if (SetEquality().equals(currentPlateNames, combo.plateNames)) {
      return combo;
    }
  }
  return null;
}
