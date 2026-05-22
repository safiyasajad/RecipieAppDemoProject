class Meal {
  final int id;
  final String title;
  final String imageUrl;
  final String? diet;
  final int? calories;
  final bool isAdminMeal;

  Meal({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.diet,
    this.calories,
    this.isAdminMeal = false,
  });

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'],
      title: map['title'],
      imageUrl: 'https://spoonacular.com/recipeImages/${map['image']}',
    );
  }

  factory Meal.fromFirestore(Map<String, dynamic> map) {
    return Meal(
      id: 0,
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      diet: map['diet'],
      calories: (map['calories'] as num?)?.toInt(),
      isAdminMeal: true,
    );
  }
}
