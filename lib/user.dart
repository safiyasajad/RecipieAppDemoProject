import 'package:flutter/material.dart';
import 'package:newproject/widgets/auth_floating_button.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User")),
      body: const Center(child: Text("User Page")),
      floatingActionButton: const AuthFloatingButton(),
    );
  }
}
