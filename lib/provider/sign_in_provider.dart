import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SignInProvider extends ChangeNotifier {
  //Instances of firebaseauth, facebook and google
  final FirebaseAuth firebaseauth = FirebaseAuth.instance;
  final FacebookAuth facebookAuth = FacebookAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  //hasError, errorCode, provider, uid, email, name, imageUrl

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _provider;
  String? get provider => _provider;

  String? _uid;
  String? get uid => _uid;

  String? _email;
  String? get email => _email;

  String? _imageUrl;
  String? get imageUrl => _imageUrl;

  String? _name;
  String? get name => _name;

  SignInProvider() {
    checkSignInUser();
  }

  Future checkSignInUser() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    _isSignedIn = sharedPreferences.getBool("signed_in") ?? false;
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setBool("signed_in", true);
    _isSignedIn = true;
    notifyListeners();
  }

  // sign in with Google
  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn().catchError((error) {
      _isSignedIn = false;
      _hasError = true;
      notifyListeners();
    });

    if (googleSignInAccount != null) {
      // executing Authentication

      try {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken);

        // signing to firebase user instance
        final User userDetails =
            (await firebaseauth.signInWithCredential(credential)).user!;

        //save all values
        _name = userDetails.displayName;
        _email = userDetails.email;
        _uid = userDetails.uid;
        _imageUrl = userDetails.photoURL;
        _provider = "GOOGLE";
        notifyListeners();

        // firebase exception handling
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "auth/account-exists-with-different-credential":
            _errorCode =
                "You already have an account with us. Use correct provider";
            _hasError = true;
            notifyListeners();
            break;

          case "null":
            _errorCode = "Some unexpected error while trying to sign in";
            _hasError = true;
            notifyListeners();
            break;

          default:
            _errorCode = error.toString();
            _hasError = true;
            notifyListeners();
        }
      } on PlatformException catch (err) {
        // Checks for type PlatformException
        if (err.code == 'sign_in_canceled') {
          // Checks for sign_in_canceled exception
          return null;
        } else {
          throw err; // Throws PlatformException again because it wasn't the one we wanted
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  //sign In with Facebook
  Future signInWithFacebook() async {
    final LoginResult loginResult = await facebookAuth.login();
    // getting the profile
    final graphResponse = await http.get(Uri.parse(
        'https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),first_name,last_name,email&access_token=${loginResult.accessToken!.token}'));

    final profile = jsonDecode(graphResponse.body);

    if (loginResult.status == LoginStatus.success) {
      try {
        final OAuthCredential credential =
            FacebookAuthProvider.credential(loginResult.accessToken!.token);
        await firebaseauth.signInWithCredential(credential);

        //saving the values
        _name = profile['name'];
        _email = profile['email'];
        _uid = profile['id'];
        _imageUrl = profile['picture']['data']['url'];
        _provider = "FACEBOOK";
        _hasError = false;
        notifyListeners();
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "auth/account-exists-with-different-credential":
            _errorCode =
                "You already have an account with us. Use correct provider";
            _hasError = true;
            notifyListeners();
            break;

          case "null":
            _errorCode = "Some unexpected error while trying to sign in";
            _hasError = true;
            notifyListeners();
            break;

          default:
            _errorCode = error.toString();
            _hasError = true;
            notifyListeners();
        }
      } on PlatformException catch (err) {
        // Checks for type PlatformException
        if (err.code == 'sign_in_canceled') {
          // Checks for sign_in_canceled exception
          return null;
        } else {
          throw err; // Throws PlatformException again because it wasn't the one we wanted
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  // ENTRY FOR CLOUDSTORE
  Future getUserDataFromFirestore(uid) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get()
        .then((DocumentSnapshot snapshot) => {
              _uid = snapshot['uid'],
              _name = snapshot['name'],
              _email = snapshot['email'],
              _imageUrl = snapshot['image_url'],
              _provider = snapshot['provider']
            });
  }

  Future saveDataToFirestore() async {
    final DocumentReference dr =
        FirebaseFirestore.instance.collection("users").doc(uid);
    await dr.set({
      "name": _name,
      "email": _email,
      "image_url": _imageUrl,
      "provider": _provider,
      "uid": _uid,
    });
    notifyListeners();
  }

  Future saveDataToSharedPreferences() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString('name', _name!);
    await sp.setString('email', _email!);
    await sp.setString('uid', _uid!);
    await sp.setString('image_url', _imageUrl!);
    await sp.setString('provider', _provider!);
    notifyListeners();
  }

  Future getDataFromSharedPreferences() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _name = sp.getString('name');
    _email = sp.getString('email');
    _imageUrl = sp.getString('image_url');
    _provider = sp.getString('provider');
    _uid = sp.getString('uid');
    notifyListeners();
  }

  // check User exists or not in the cloudFirestore
  Future<bool> checkUserExists() async {
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    if (snap.exists) {
      print("EXISTING USER");
      return true;
    } else {
      print("NEW USER");
      return false;
    }
  }

  // sign Out
  Future userSignOut() async {
    await firebaseauth.signOut();
    await googleSignIn.signOut();
    _isSignedIn = false;
    notifyListeners();

    //clear all storage information
    clearStorageData();
  }

  Future clearStorageData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
  }
}
