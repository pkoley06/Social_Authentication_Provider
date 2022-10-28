import 'package:auth_using_provider/provider/internet_provider.dart';
import 'package:auth_using_provider/provider/sign_in_provider.dart';
import 'package:auth_using_provider/screens/home_screen.dart';
import 'package:auth_using_provider/utils/config.dart';
import 'package:auth_using_provider/utils/next_screen.dart';
import 'package:auth_using_provider/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
  final RoundedLoadingButtonController googleController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController facebookController =
      RoundedLoadingButtonController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 30, right: 30, top: 90, bottom: 30),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Image(
                          image: AssetImage(Config.appIcon),
                          height: 80,
                          width: 80,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "Welcome to Flutter Firebase",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Authentication with Provider",
                          style:
                              TextStyle(fontSize: 15, color: Colors.grey[500]),
                        )
                      ],
                    )),

                //rounded button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Google button
                    RoundedLoadingButton(
                      width: MediaQuery.of(context).size.width * 0.80,
                      controller: googleController,
                      successColor: Colors.red,
                      elevation: 5,
                      color: Colors.red,
                      onPressed: () {
                        handleGoogleSignIn();
                      },
                      child: Wrap(
                        children: const [
                          Icon(
                            FontAwesomeIcons.google,
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Sign In with Google",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    //Facebook Button
                    RoundedLoadingButton(
                      width: MediaQuery.of(context).size.width * 0.80,
                      controller: facebookController,
                      successColor: Colors.blue,
                      elevation: 5,
                      color: Colors.blue,
                      onPressed: () {},
                      child: Wrap(
                        children: const [
                          Icon(
                            FontAwesomeIcons.facebook,
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Sign In with Facebook",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // handling google sign In
  Future handleGoogleSignIn() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInterrnetConnection();

    if (ip.hasInternet == false) {
      openSnackbar(context, "Check your Internet connection", Colors.red);
      googleController.reset();
    } else {
      await sp.signInWithGoogle().then((value) => {
            if (sp.hasError == true)
              {
                openSnackbar(context, sp.errorCode.toString(), Colors.red),
                googleController.reset()
              }
            else
              {
                // checking wheather user exists or not
                sp.checkUserExists().then((value) async => {
                      if (value == true)
                        {
                          // user exists
                          await sp
                              .getUserDataFromFirestore(sp.uid)
                              .then((value) => {
                                    sp
                                        .saveDataToSharedPreferences()
                                        .then((value) => {
                                              sp.setSignIn().then((value) => {
                                                    googleController.success(),
                                                    handleAfterSignIn()
                                                  })
                                            })
                                  })
                        }
                      else
                        {
                          // user does not exist
                          sp.saveDataToFirestore().then((value) => sp
                              .saveDataToSharedPreferences()
                              .then((value) => {
                                    sp.setSignIn().then(
                                        (value) => googleController.success()),
                                    handleAfterSignIn()
                                  }))
                        }
                    })
              }
          });
    }
  }

  // handling after sign In
  handleAfterSignIn() {
    Future.delayed(const Duration(milliseconds: 1000))
        .then((value) => {nextScreenReplacement(context, const HomeScreen())});
  }
}
