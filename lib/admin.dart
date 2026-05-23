import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:newproject/models/meal_plan_model.dart';
import 'package:newproject/screens/admin_recipes_screen.dart';
import 'package:newproject/screens/meals_screen.dart';
import 'package:newproject/services/api_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // Sign out function
  Future<void> signout() async {
    await FirebaseAuth.instance.signOut();
  }

  // Diet options
  final List<String> _diets = [
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

  double _targetCalories = 2250;
  String _diet = 'None';

  void _showAdminOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add Recipe'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddRecipeDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.restaurant_menu),
                title: const Text('View Admin Recipes'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminRecipesScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('See Users'),
                onTap: () {
                  Navigator.pop(context);
                  _showUsersSheet();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  signout();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddRecipeDialog() {
    final titleController = TextEditingController();
    final imageController = TextEditingController();
    final caloriesController = TextEditingController();
    final descriptionController = TextEditingController();
    final pageMessenger = ScaffoldMessenger.of(context);
    final pageNavigator = Navigator.of(context, rootNavigator: true);
    String selectedDiet = _diet;
    bool isSaving = false;
    bool dialogIsOpen = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
              title: const Text('Add Recipe'),
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
                      onChanged: (value) {
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
                  onPressed: isSaving ? null : () => pageNavigator.pop(),
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
                          final description = descriptionController.text.trim();

                          if (title.isEmpty ||
                              imageUrl.isEmpty ||
                              calories == null) {
                            pageMessenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter recipe name, image URL, and calories.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (!dialogIsOpen) return;

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            await FirebaseFirestore.instance
                                .collection('admin_recipes')
                                .add({
                                  'title': title,
                                  'imageUrl': imageUrl,
                                  'calories': calories,
                                  'diet': selectedDiet,
                                  'description': description,
                                  'createdAt': FieldValue.serverTimestamp(),
                                })
                                .timeout(const Duration(seconds: 12));

                            if (!mounted || !dialogIsOpen) return;

                            pageNavigator.pop();
                            pageMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Recipe added successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (error) {
                            if (!mounted || !dialogIsOpen) return;

                            setDialogState(() {
                              isSaving = false;
                            });

                            pageMessenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Recipe could not be saved: $error',
                                ),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 5),
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
    ).whenComplete(() {
      dialogIsOpen = false;
      titleController.dispose();
      imageController.dispose();
      caloriesController.dispose();
      descriptionController.dispose();
    });
  }

  void _showUsersSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .orderBy('email')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Could not load users: ${snapshot.error}'),
                );
              }

              final users = snapshot.data?.docs ?? [];

              if (users.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No users found.'),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index].data();

                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(user['email'] ?? 'No email'),
                    subtitle: Text('Role: ${user['role'] ?? 'user'}'),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  // Generate meal plan
  void _searchMealPlan() async {
    MealPlan mealPlan = await ApiService.instance.generateMealPlan(
      targetCalories: _targetCalories.toInt(),
      diet: _diet,
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MealsScreen(mealPlan: mealPlan)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAdminOptions,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.admin_panel_settings),
      ),

      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1498837167922-ddd27525d352?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1350&q=80',
            ),
            fit: BoxFit.cover,
          ),
        ),

        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 30.0),

            padding: const EdgeInsets.symmetric(horizontal: 30.0),

            height: MediaQuery.of(context).size.height * 0.55,

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(15.0),
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Daily Meal Planner',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),

                const SizedBox(height: 20.0),

                RichText(
                  text: TextSpan(
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.copyWith(fontSize: 25),

                    children: [
                      TextSpan(
                        text: _targetCalories.round().toString(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const TextSpan(
                        text: ' cal',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                // Slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbColor: Colors.orange,
                    activeTrackColor: Colors.orange,
                    inactiveTrackColor: Colors.orange[100],
                    trackHeight: 6.0,
                  ),

                  child: Slider(
                    min: 0.0,
                    max: 4500.0,
                    value: _targetCalories,

                    onChanged: (value) {
                      setState(() {
                        _targetCalories = value.round().toDouble();
                      });
                    },
                  ),
                ),

                // Diet dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),

                  child: DropdownButtonFormField<String>(
                    items: _diets.map((String diet) {
                      return DropdownMenuItem<String>(
                        value: diet,

                        child: Text(
                          diet,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                          ),
                        ),
                      );
                    }).toList(),

                    decoration: const InputDecoration(
                      labelText: 'Diet',
                      labelStyle: TextStyle(fontSize: 18.0),
                    ),

                    onChanged: (value) {
                      setState(() {
                        _diet = value!;
                      });
                    },

                    initialValue: _diet,
                  ),
                ),

                const SizedBox(height: 30.0),

                // Search button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60.0,
                      vertical: 8.0,
                    ),

                    backgroundColor: Colors.orange,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),

                  onPressed: _searchMealPlan,

                  child: const Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
