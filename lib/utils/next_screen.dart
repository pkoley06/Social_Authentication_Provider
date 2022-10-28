import 'package:flutter/material.dart';

// void nextScreen(context, page) {
//   Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => page,
//       ));
// }

void nextScreenReplacement(context, page) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => page,
    ),
    (route) => false,
  );
}
