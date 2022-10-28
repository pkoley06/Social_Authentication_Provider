import 'dart:async';

import 'package:auth_using_provider/provider/sign_in_provider.dart';
import 'package:auth_using_provider/screens/home_screen.dart';
import 'package:auth_using_provider/screens/login_screen.dart';
import 'package:auth_using_provider/utils/config.dart';
import 'package:auth_using_provider/utils/next_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  //init state
  @override
  void initState() {
    final sp = context.read<SignInProvider>();
    super.initState();
    //create a timer
    Timer(const Duration(seconds: 2), () {
      sp.isSignedIn == false
          ? nextScreen(context, const LogInScreen())
          : nextScreen(context, const HomeScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
          child: Center(
              child: Image(
        image: AssetImage(Config.appIcon),
        height: 80,
        width: 80,
      ))),
    );
  }
}
