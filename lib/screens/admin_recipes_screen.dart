import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:newproject/widgets/auth_floating_button.dart';

class AdminRecipesScreen extends StatefulWidget {
  const AdminRecipesScreen({super.key});

  @override
  State<AdminRecipesScreen> createState() => _AdminRecipesScreenState();
}

class _AdminRecipesScreenState extends State<AdminRecipesScreen> {
  final Set<String> _expandedRecipeIds = {};

  void _toggleRecipe(String recipeId) {
    setState(() {
      if (_expandedRecipeIds.contains(recipeId)) {
        _expandedRecipeIds.remove(recipeId);
      } else {
        _expandedRecipeIds.add(recipeId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Recipes')),
      floatingActionButton: const AuthFloatingButton(),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('admin_recipes')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Could not load recipes: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final recipes = snapshot.data?.docs ?? [];

          if (recipes.isEmpty) {
            return const Center(child: Text('No admin recipes added yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipeDoc = recipes[index];
              final recipe = recipeDoc.data();
              final imageUrl = recipe['imageUrl'] ?? '';
              final isExpanded = _expandedRecipeIds.contains(recipeDoc.id);

              return GestureDetector(
                onTap: () => _toggleRecipe(recipeDoc.id),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl.isNotEmpty)
                        Image.network(
                          imageUrl,
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
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    recipe['title'] ?? 'Untitled Recipe',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${recipe['diet'] ?? 'No diet'} - ${recipe['calories'] ?? 0} cal',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            AnimatedCrossFade(
                              firstChild: const SizedBox.shrink(),
                              secondChild: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  (recipe['description'] ?? '').isEmpty
                                      ? 'No recipe details added.'
                                      : recipe['description'],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              crossFadeState: isExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 200),
                            ),
                          ],
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
