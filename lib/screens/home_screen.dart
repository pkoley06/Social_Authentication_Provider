import 'package:auth_using_provider/provider/sign_in_provider.dart';
import 'package:auth_using_provider/screens/login_screen.dart';
import 'package:auth_using_provider/utils/next_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final sp = context.read<SignInProvider>();
    return Scaffold(
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              sp.userSignOut();
              nextScreenReplacement(context, LogInScreen());
            },
            child: const Text("Sign out")),
      ),
    );
  }
}
