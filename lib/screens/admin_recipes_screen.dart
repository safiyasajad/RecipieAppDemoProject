import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newproject/widgets/auth_floating_button.dart';

class AdminRecipesScreen extends StatefulWidget {
  const AdminRecipesScreen({super.key});

  @override
  State<AdminRecipesScreen> createState() => _AdminRecipesScreenState();
}

class _AdminRecipesScreenState extends State<AdminRecipesScreen> {
  final Set<String> _expandedRecipeIds = {};
  late final Future<bool> _isAdminFuture = _isAdmin();

  static const List<String> _diets = [
    'None',
    'Gluten Free',
    'Ketogenic',
    'Lacto-Vegetarian',
    'Ovo-Vegetarian',
    'Vegan',
    'Pescetarian',
    'Paleo',
    'Primal',
    'Whole30',
  ];

  Future<bool> _isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return false;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return userDoc.data()?['role'] == 'admin';
  }

  void _toggleRecipe(String recipeId) {
    setState(() {
      if (_expandedRecipeIds.contains(recipeId)) {
        _expandedRecipeIds.remove(recipeId);
      } else {
        _expandedRecipeIds.add(recipeId);
      }
    });
  }

  Future<void> _deleteRecipe(String recipeId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Recipe'),
          content: const Text('Are you sure you want to delete this recipe?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('admin_recipes')
          .doc(recipeId)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe deleted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not delete recipe: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _editRecipe(String recipeId, Map<String, dynamic> recipe) async {
    final titleController = TextEditingController(text: recipe['title'] ?? '');
    final imageController = TextEditingController(
      text: recipe['imageUrl'] ?? '',
    );
    final caloriesController = TextEditingController(
      text: '${recipe['calories'] ?? ''}',
    );
    final proteinController = TextEditingController(
      text: '${recipe['protein'] ?? ''}',
    );
    final carbsController = TextEditingController(
      text: '${recipe['carbs'] ?? ''}',
    );
    final fatController = TextEditingController(text: '${recipe['fat'] ?? ''}');
    final descriptionController = TextEditingController(
      text: recipe['description'] ?? '',
    );
    String selectedDiet = _diets.contains(recipe['diet'])
        ? recipe['diet']
        : 'None';
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Recipe'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Recipe name',
                      ),
                    ),
                    TextField(
                      controller: imageController,
                      decoration: const InputDecoration(labelText: 'Image URL'),
                    ),
                    TextField(
                      controller: caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Calories'),
                    ),
                    TextField(
                      controller: proteinController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Protein'),
                    ),
                    TextField(
                      controller: carbsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Carbs'),
                    ),
                    TextField(
                      controller: fatController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Fat'),
                    ),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Recipe details',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedDiet,
                      decoration: const InputDecoration(labelText: 'Diet'),
                      items: _diets.map((diet) {
                        return DropdownMenuItem<String>(
                          value: diet,
                          child: Text(diet),
                        );
                      }).toList(),
                      onChanged: isSaving
                          ? null
                          : (value) {
                              setDialogState(() {
                                selectedDiet = value!;
                              });
                            },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final title = titleController.text.trim();
                          final imageUrl = imageController.text.trim();
                          final calories = int.tryParse(
                            caloriesController.text.trim(),
                          );
                          final protein = int.tryParse(
                            proteinController.text.trim(),
                          );
                          final carbs = int.tryParse(
                            carbsController.text.trim(),
                          );
                          final fat = int.tryParse(fatController.text.trim());
                          final description = descriptionController.text.trim();

                          if (title.isEmpty ||
                              imageUrl.isEmpty ||
                              calories == null ||
                              protein == null ||
                              carbs == null ||
                              fat == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter all required recipe details.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            await FirebaseFirestore.instance
                                .collection('admin_recipes')
                                .doc(recipeId)
                                .update({
                                  'title': title,
                                  'imageUrl': imageUrl,
                                  'calories': calories,
                                  'protein': protein,
                                  'carbs': carbs,
                                  'fat': fat,
                                  'diet': selectedDiet,
                                  'description': description,
                                });

                            if (!dialogContext.mounted) return;

                            Navigator.pop(dialogContext);

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Recipe updated'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (error) {
                            setDialogState(() {
                              isSaving = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Could not update recipe: $error',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: Text(isSaving ? 'Saving...' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    imageController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();
    descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Recipes')),
      floatingActionButton: const AuthFloatingButton(),
      body: FutureBuilder<bool>(
        future: _isAdminFuture,
        builder: (context, adminSnapshot) {
          if (adminSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final isAdmin = adminSnapshot.data ?? false;

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 40,
                                  ),
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
                                    if (isAdmin)
                                      PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            _editRecipe(recipeDoc.id, recipe);
                                          } else if (value == 'delete') {
                                            _deleteRecipe(recipeDoc.id);
                                          }
                                        },
                                        itemBuilder: (context) {
                                          return const [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Text('Edit'),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Delete'),
                                            ),
                                          ];
                                        },
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Protein: ${recipe['protein'] ?? 0} g',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          'Carbs: ${recipe['carbs'] ?? 0} g',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          'Fat: ${recipe['fat'] ?? 0} g',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          (recipe['description'] ?? '').isEmpty
                                              ? 'No recipe details added.'
                                              : recipe['description'],
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
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
          );
        },
      ),
    );
  }
}
