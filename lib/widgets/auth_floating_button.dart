import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthFloatingButton extends StatefulWidget {
  const AuthFloatingButton({super.key});

  @override
  State<AuthFloatingButton> createState() => _AuthFloatingButtonState();
}

class _AuthFloatingButtonState extends State<AuthFloatingButton> {
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

  late final Future<bool> _adminFuture = _isAdmin();

  Future<void> _signout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.of(context, rootNavigator: true).popUntil((route) {
      return route.isFirst;
    });
  }

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

  void _openRecipes(BuildContext context) {
    Navigator.pushNamed(context, '/admin-recipes');
  }

  void _showOptions(BuildContext context, bool isAdmin) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isAdmin)
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Add Recipe'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showAddRecipeDialog(context);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.restaurant_menu),
                title: const Text('Admin Recipes'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openRecipes(context);
                },
              ),
              if (isAdmin)
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('See Users'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showUsersSheet(context);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _signout(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddRecipeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _AddRecipeDialog(diets: _diets),
    );
  }

  void _showUsersSheet(BuildContext context) {
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

              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final userDoc = users[index];
                    final user = userDoc.data();
                    final role = user['role'] == 'admin' ? 'admin' : 'user';

                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(user['email'] ?? 'No email'),
                      subtitle: Text('Role: $role'),
                      trailing: DropdownButton<String>(
                        value: role,
                        items: const [
                          DropdownMenuItem(value: 'user', child: Text('User')),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                        ],
                        onChanged: (newRole) async {
                          if (newRole == null || newRole == role) {
                            return;
                          }

                          final messenger = ScaffoldMessenger.of(context);

                          try {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userDoc.id)
                                .update({'role': newRole});

                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Role changed to $newRole for ${user['email'] ?? 'user'}.',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (error) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Could not update role: $error'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _adminFuture,
      builder: (context, snapshot) {
        final isAdmin = snapshot.data ?? false;

        return FloatingActionButton(
          onPressed: snapshot.connectionState == ConnectionState.waiting
              ? null
              : () => _showOptions(context, isAdmin),
          backgroundColor: Colors.orange,
          child: Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.restaurant_menu,
          ),
        );
      },
    );
  }
}

class _AddRecipeDialog extends StatefulWidget {
  final List<String> diets;

  const _AddRecipeDialog({required this.diets});

  @override
  State<_AddRecipeDialog> createState() => _AddRecipeDialogState();
}

class _AddRecipeDialogState extends State<_AddRecipeDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedDiet = 'None';
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _imageController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveRecipe() async {
    final title = _titleController.text.trim();
    final imageUrl = _imageController.text.trim();
    final calories = int.tryParse(_caloriesController.text.trim());
    final protein = int.tryParse(_proteinController.text.trim());
    final carbs = int.tryParse(_carbsController.text.trim());
    final fat = int.tryParse(_fatController.text.trim());
    final description = _descriptionController.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (title.isEmpty ||
        imageUrl.isEmpty ||
        calories == null ||
        protein == null ||
        carbs == null ||
        fat == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter recipe name, image URL, calories, protein, carbs, and fat.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('admin_recipes')
          .add({
            'title': title,
            'imageUrl': imageUrl,
            'calories': calories,
            'protein': protein,
            'carbs': carbs,
            'fat': fat,
            'diet': _selectedDiet,
            'description': description,
            'createdAt': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 12));

      if (!mounted) return;

      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Recipe added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text('Recipe could not be saved: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Recipe'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Recipe name'),
            ),
            TextField(
              controller: _imageController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Calories'),
            ),
            TextField(
              controller: _proteinController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Protein (g)'),
            ),
            TextField(
              controller: _carbsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Carbs (g)'),
            ),
            TextField(
              controller: _fatController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Fat (g)'),
            ),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Recipe details'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedDiet,
              decoration: const InputDecoration(labelText: 'Diet'),
              items: widget.diets.map((diet) {
                return DropdownMenuItem<String>(value: diet, child: Text(diet));
              }).toList(),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      setState(() {
                        _selectedDiet = value!;
                      });
                    },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveRecipe,
          child: Text(_isSaving ? 'Saving...' : 'Save'),
        ),
      ],
    );
  }
}
