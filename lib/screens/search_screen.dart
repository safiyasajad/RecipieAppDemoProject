import 'package:flutter/material.dart'; //standard widget that has elements to build interface
import 'package:newproject/models/meal_plan_model.dart';
import 'package:newproject/screens/meals_screen.dart';
import 'package:newproject/services/api_service.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<String> _diets = [
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

  // generates a meal plan by passing parameters to API_service.instance.generateMealPlan
  // and pushes the meal plan onto the screen with navigator.push
  void _searchMealPlan() async {
    MealPlan mealPlan = await ApiService.instance.generateMealPlan(
      targetCalories: _targetCalories.toInt(),
      diet: _diet,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MealsScreen(mealPlan: mealPlan),
      ),
    );
  }

  // what the screen looks like upon loading up
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1498837167922-ddd27525d352?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1350&q=80',
            ),
            fit: BoxFit.cover,
          ),
        ),

        // widget in the centre
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: 30.0,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 30.0,
            ),
            height: MediaQuery.of(context).size.height * 0.55,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(15.0),
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Daily Meal Planner',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),

                SizedBox(height: 20.0),

                RichText(
                  text: TextSpan(
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontSize: 25),

                    children: [
                      TextSpan(
                        text: _targetCalories.truncate().toString(),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      TextSpan(
                        text: ' cal',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // sets the target calories
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbColor: Colors.orange,
                    activeTrackColor: Colors.orange,
                    inactiveTrackColor: Colors.lightBlue[100],
                    trackHeight: 6.0,
                  ),

                  child: Slider(
                    min: 0.0,
                    max: 4500.0,
                    value: _targetCalories,

                    onChanged: (value) => setState(() {
                      _targetCalories = value.round().toDouble();
                    }),
                  ),
                ),

                // dropdown field to select type of diet
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),

                  child: DropdownButtonFormField<String>(
                    items: _diets.map((String priority) {
                      return DropdownMenuItem<String>(
                        value: priority,

                        child: Text(
                          priority,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                          ),
                        ),
                      );
                    }).toList(),

                    decoration: InputDecoration(
                      labelText: 'Diet',
                      labelStyle: TextStyle(fontSize: 18.0),
                    ),

                    onChanged: (value) {
                      setState(() {
                        _diet = value!;
                      });
                    },

                    value: _diet,
                  ),
                ),

                SizedBox(height: 30.0),

                // button which will be triggered
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 60.0,
                      vertical: 8.0,
                    ),

                    backgroundColor:
                        Colors.orange,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),

                  onPressed: _searchMealPlan,

                  child: Text(
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