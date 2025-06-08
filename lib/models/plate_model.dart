import 'package:uuid/uuid.dart';

class Plate {
  final String id;
  final String name;
  final String imageUrl;
  final int calories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatsGrams;
  final int healthScoreAdd;

  Plate({
    String? id, // Allow providing an ID, otherwise generate one
    required this.name,
    required this.imageUrl,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatsGrams,
    required this.healthScoreAdd,
  }) : id = id ?? const Uuid().v4(); // Generate unique ID if not provided
}