import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

final storage = FirebaseStorage.instance;
final storageRef = storage.ref();

Future<String> uploadFile(String filePath) async {
  final fileRef = storageRef.child(filePath);
  await fileRef.putFile(File(filePath));

  // Add small delay/retry for getDownloadURL as it can sometimes fail with object-not-found
  // immediately after putFile due to eventual consistency
  for (int i = 0; i < 3; i++) {
    try {
      return await fileRef.getDownloadURL();
    } catch (e) {
      if (i == 2) rethrow;
      await Future.delayed(Duration(milliseconds: 500 * (i + 1)));
    }
  }
  throw Exception("Failed to get download URL");
}
