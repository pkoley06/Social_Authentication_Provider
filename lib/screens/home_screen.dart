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
  Future getData() async {
    final sp = context.read<SignInProvider>();
    sp.getDataFromSharedPreferences();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage("${sp.imageUrl}"),
            radius: 50,
          ),
          const SizedBox(height: 20),
          Text(
            "${sp.name}",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          Text(
            "${sp.email}",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          Text(
            "${sp.uid}",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("PROVIDER: "),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  "${sp.provider}".toUpperCase(),
                  style: const TextStyle(color: Colors.red),
                )
              ]),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                sp.userSignOut();
                nextScreenReplacement(context, LogInScreen());
              },
              child: const Icon(Icons.login_outlined))
        ],
      )),
    );
  }
}
