import 'package:flutter/material.dart';
import 'package:newproject/models/recipie_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RecipeScreen extends StatefulWidget {
  final String mealType;
  final Recipe recipe;

  const RecipeScreen({
    super.key,
    required this.mealType,
    required this.recipe,
  });

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(widget.recipe.spoonacularSourceUrl),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mealType),
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}