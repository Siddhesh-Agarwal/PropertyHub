import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/services/db_service.dart';
import '/services/constants.dart';

enum UserStatus { notInvited, invited, active }

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get user => firebaseAuth.currentUser;
  String? userName;
  UserMode? userMode;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final userCreds = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _getCurrentUserInfo();
    return userCreds;
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    var userStatus = await _getUserStatus(email);
    if (userStatus == UserStatus.notInvited) {
      throw Exception("User not invited");
    }

    // Create the account
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
    userMode = null;
  }

  Future<void> resetPassword({required String email}) async {
    var userStatus = await _getUserStatus(email);
    if (userStatus == UserStatus.notInvited) {
      throw Exception("User not invited");
    }
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  UserMode _convertStringToMode(String role) {
    switch (role) {
      case 'Admin':
        return UserMode.admin;
      case 'User':
        return UserMode.user;
      default:
        throw Exception("Invalid role: $role");
    }
  }

  Future<void> _getCurrentUserInfo() async {
    var value =
        await db.collection('users').doc(firebaseAuth.currentUser!.email).get();
    if (!value.exists) {
      throw Exception("User not found in database.");
    }
    var doc = value.data()!;
    var role = doc['role'];
    userMode = _convertStringToMode(role);
    userName = doc['displayName'];
  }

  Future<UserStatus> _getUserStatus(String email) async {
    var value = await db.collection('users').doc(email).get();
    if (!value.exists) {
      return UserStatus.notInvited;
    }
    var doc = value.data()!;
    switch (doc['status']) {
      case 'invited':
        return UserStatus.invited;
      case 'active':
        return UserStatus.active;
      default:
        throw Exception("Unknown user status $doc['status']");
    }
  }
}
