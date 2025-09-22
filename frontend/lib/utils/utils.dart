import 'package:flutter/foundation.dart';

bool isValidEmail(String email) {
  return RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  ).hasMatch(email);
}

void debugPrint(String message) {
  if (kDebugMode) {
    print(message);
  }
}
