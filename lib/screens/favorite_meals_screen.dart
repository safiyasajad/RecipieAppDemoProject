import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newproject/models/recipie_model.dart';
import 'package:newproject/screens/recipie_screen.dart';
import 'package:newproject/services/api_service.dart';
import 'package:newproject/widgets/auth_floating_button.dart';

// Shows the meals that the logged-in user marked as favorites.
// Favorites are saved under users/{uid}/favorite_meals in Firestore.
class FavoriteMealsScreen extends StatelessWidget {
  const FavoriteMealsScreen({super.key});

  CollectionReference<Map<String, dynamic>>? _favoritesCollection() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return null;
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorite_meals');
  }

  Future<void> _openRecipe(
    BuildContext context,
    Map<String, dynamic> meal,
  ) async {
    final mealId = meal['id'];

    if (mealId == null) {
      return;
    }

    Recipe recipe = await ApiService.instance.fetchRecipe(mealId.toString());

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeScreen(
          mealType: meal['mealType'] ?? 'Favorite Meal',
          recipe: recipe,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favorites = _favoritesCollection();

    if (favorites == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view favorites.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Meals')),
      floatingActionButton: const AuthFloatingButton(),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: favorites.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Could not load favorites: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final meals = snapshot.data?.docs ?? [];

          if (meals.isEmpty) {
            return const Center(child: Text('No favorite meals yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final favoriteDoc = meals[index];
              final meal = favoriteDoc.data();

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _openRecipe(context, meal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        meal['imageUrl'] ?? '',
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 180,
                            color: Colors.black12,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image, size: 40),
                          );
                        },
                      ),
                      ListTile(
                        title: Text(meal['title'] ?? 'Untitled Meal'),
                        subtitle: Text(meal['mealType'] ?? 'Favorite Meal'),
                        trailing: IconButton(
                          tooltip: 'Remove favorite',
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await favorites.doc(favoriteDoc.id).delete();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
