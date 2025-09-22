import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/db_service.dart';

class UserService {
  Future<void> addUser({
    required String displayName,
    required String email,
    required String role,
  }) async {
    if (await _userExists(email)) {
      throw Exception("User already exists");
    }
    await db.collection('users').doc(email).set({
      "displayName": displayName,
      "role": role,
      "status": "invited",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUsers() async {
    final querySnapshot = await db.collection('users').get();
    return querySnapshot;
  }

  Future<Map<String, dynamic>?> getUser({required String email}) async {
    final querySnapshot = await db.collection('users').doc(email).get();
    if (!querySnapshot.exists) {
      throw Exception("User not found");
    }
    return querySnapshot.data();
  }

  Future<void> updateUserInfo({
    required String displayName,
    required String email,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required String gender,
    required String qatarId,
  }) async {
    await db.collection('users').doc(email).update({
      "displayName": displayName,
      "phoneNumber": phoneNumber,
      "dateOfBirth": dateOfBirth,
      "gender": gender,
      "qatarId": qatarId,
      "status": "active",
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<bool> _userExists(String email) async {
    final querySnapshot = await db.collection('users').doc(email).get();
    return querySnapshot.exists;
  }
}
