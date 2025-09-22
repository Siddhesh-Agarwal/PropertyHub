import 'package:flutter/material.dart';

void _snackBar(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
    ),
  );
}

void errorSnack(BuildContext context, String message) {
  _snackBar(context, message, Colors.red);
}

void successSnack(BuildContext context, String message) {
  _snackBar(context, message, Colors.green);
}

void warningSnack(BuildContext context, String message) {
  _snackBar(context, message, Colors.amber);
}

void infoSnack(BuildContext context, String message) {
  _snackBar(context, message, Colors.blue);
}
