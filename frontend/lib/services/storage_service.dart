import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

final storage = FirebaseStorage.instance;
final storageRef = storage.ref();

Future<String> uploadFile(String filePath) {
  final fileRef = storageRef.child(filePath);
  fileRef.putFile(File(filePath));
  return fileRef.getDownloadURL();
}
