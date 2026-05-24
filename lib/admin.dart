import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:newproject/models/meal_plan_model.dart';
import 'package:newproject/screens/meals_screen.dart';
import 'package:newproject/services/api_service.dart';
import 'package:newproject/widgets/auth_floating_button.dart';

// Main page for admin users after login.
// Admins get the same meal planner as normal users, plus admin tools through
// the persistent floating button.
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // Diet options shown in the dropdown and sent to the meal plan API.
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

  // Uses the part of the admin's email before @ as the name in the app bar.
  // Example: admin@gmail.com becomes admin.
  String get _adminName {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    if (!email.contains('@')) {
      return email;
    }

    return email.split('@').first;
  }

  // Generates a meal plan with the selected target calories and diet, then
  // opens the meal results screen.
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
      appBar: AppBar(title: Text('Hi admin $_adminName')),
      // This button shows admin actions: add recipe, view recipes, see users,
      // change roles, and logout.
      floatingActionButton: const AuthFloatingButton(),

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

                // Slider changes the calorie target used when searching.
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

                // Dropdown changes the diet sent to the API.
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

                // Search button calls the API and navigates to MealsScreen.
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
