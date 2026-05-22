import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:newproject/models/meal_plan_model.dart';
import 'package:newproject/models/recipie_model.dart';

class ApiService {
  ApiService._instantiate();

  static final ApiService instance = ApiService._instantiate();

  final String _baseUrl = 'api.spoonacular.com';

  static const String _apiKey = '65351aeef8ce4893bb95e1004b5744d1';

  // Generate Meal Plan
  Future<MealPlan> generateMealPlan({
    required int targetCalories,
    required String diet,
  }) async {
    if (diet == 'None') {
      diet = '';
    }

    final Map<String, String> parameters = {
      'timeFrame': 'day',
      'targetCalories': targetCalories.toString(),
      'diet': diet,
      'apiKey': _apiKey,
    };

    final Uri uri = Uri.https(
      _baseUrl,
      '/recipes/mealplans/generate',
      parameters,
    );

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      final http.Response response = await http.get(
        uri,
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to generate meal plan. Status code: ${response.statusCode}',
        );
      }

      final Map<String, dynamic> data =
          json.decode(response.body) as Map<String, dynamic>;

      final MealPlan mealPlan = MealPlan.fromMap(data);

      return mealPlan;
    } catch (err) {
      throw Exception('Error generating meal plan: $err');
    }
  }

  // Recipe Info
  Future<Recipe> fetchRecipe(String id) async {
    final Map<String, String> parameters = {
      'includeNutrition': 'false',
      'apiKey': _apiKey,
    };

    final Uri uri = Uri.https(
      _baseUrl,
      '/recipes/$id/information',
      parameters,
    );

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      final http.Response response = await http.get(
        uri,
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch recipe. Status code: ${response.statusCode}',
        );
      }

      final Map<String, dynamic> data =
          json.decode(response.body) as Map<String, dynamic>;

      final Recipe recipe = Recipe.fromMap(data);

      return recipe;
    } catch (err) {
      throw Exception('Error fetching recipe: $err');
    }
  }
}