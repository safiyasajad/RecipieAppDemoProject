import 'package:newproject/models/meal_model.dart';

class MealPlan {
  final List<Meal> meals;
  final double calories;
  final double carbs;
  final double fat;
  final double protein;

  MealPlan({
    required this.meals,
    required this.calories,
    required this.carbs,
    required this.fat,
    required this.protein,
  });

  factory MealPlan.fromMap(Map<String, dynamic> map) {
    final List<Meal> meals = (map['meals'] as List<dynamic>)
        .map((mealMap) => Meal.fromMap(mealMap as Map<String, dynamic>))
        .toList();

    final nutrients = map['nutrients'] as Map<String, dynamic>;

    return MealPlan(
      meals: meals,
      calories: (nutrients['calories'] as num).toDouble(),
      carbs: (nutrients['carbohydrates'] as num).toDouble(),
      fat: (nutrients['fat'] as num).toDouble(),
      protein: (nutrients['protein'] as num).toDouble(),
    );
  }
}