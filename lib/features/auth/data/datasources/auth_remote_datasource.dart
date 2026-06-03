import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pomodoro_tasks/core/constants/app_constants.dart';
import 'package:pomodoro_tasks/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel> getCurrentUser();
  Future<String> createPair();
  Future<UserModel> joinPair({required String pairCode});
  Stream<User?> get authStateChanges;
}

class AuthRemoteException implements Exception {
  final String message;

  const AuthRemoteException(this.message);

  @override
  String toString() => message;
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRemoteDatasourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
  });

  @override
  Future<UserModel> signInWithGoogle() async {
    final UserCredential userCredential;
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthRemoteException('Google sign-in was cancelled.');
      }

      final googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        throw const AuthRemoteException(
          'Google sign-in is not configured for this Android build. Add the app SHA fingerprint in Firebase, then download a fresh google-services.json.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      userCredential = await firebaseAuth.signInWithCredential(credential);
    } on PlatformException catch (e) {
      throw AuthRemoteException(_googleSignInMessage(e));
    } on FirebaseAuthException catch (e) {
      throw AuthRemoteException(e.message ?? 'Firebase authentication failed.');
    }

    final uid = userCredential.user!.uid;

    // Check if user doc exists, create if not
    final doc = await firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) {
      final user = UserModel(
        id: uid,
        email: userCredential.user!.email ?? '',
        displayName: userCredential.user!.displayName ?? '',
        createdAt: DateTime.now(),
      );
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .set(user.toFirestore());
      return user;
    }
    return UserModel.fromFirestore(doc);
  }

  String _googleSignInMessage(PlatformException error) {
    final details = error.details?.toString() ?? '';
    final message = error.message ?? '';
    if (error.code == 'sign_in_canceled') {
      return 'Google sign-in was cancelled.';
    }
    if (message.contains('10') ||
        details.contains('10') ||
        message.contains('DEVELOPER_ERROR') ||
        details.contains('DEVELOPER_ERROR')) {
      return 'Google sign-in is not configured for this Android build. Add the app SHA fingerprint in Firebase, then download a fresh google-services.json.';
    }
    if (message.isNotEmpty) {
      return 'Google sign-in failed: $message';
    }
    return 'Google sign-in failed. Check Firebase OAuth configuration for this app.';
  }

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) {
      throw Exception('No user signed in');
    }
    return _getUserModel(firebaseUser.uid);
  }

  @override
  Future<String> createPair() async {
    final userId = firebaseAuth.currentUser!.uid;
    final pairCode = _generatePairCode();

    final pairDoc = await firestore
        .collection(AppConstants.pairsCollection)
        .add({
          'user1Id': userId,
          'user2Id': null,
          'pairCode': pairCode,
          'createdAt': FieldValue.serverTimestamp(),
        });

    await firestore.collection(AppConstants.usersCollection).doc(userId).update(
      {'pairId': pairDoc.id},
    );

    return pairCode;
  }

  @override
  Future<UserModel> joinPair({required String pairCode}) async {
    final userId = firebaseAuth.currentUser!.uid;

    final query = await firestore
        .collection(AppConstants.pairsCollection)
        .where('pairCode', isEqualTo: pairCode)
        .where('user2Id', isNull: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Invalid or already used pair code');
    }

    final pairDoc = query.docs.first;
    final partnerId = pairDoc.data()['user1Id'] as String;

    await firestore
        .collection(AppConstants.pairsCollection)
        .doc(pairDoc.id)
        .update({'user2Id': userId});

    await firestore.collection(AppConstants.usersCollection).doc(userId).update(
      {'pairId': pairDoc.id, 'partnerId': partnerId},
    );

    await firestore
        .collection(AppConstants.usersCollection)
        .doc(partnerId)
        .update({'partnerId': userId});

    return _getUserModel(userId);
  }

  @override
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<UserModel> _getUserModel(String uid) async {
    final doc = await firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) {
      throw Exception('User document not found');
    }
    return UserModel.fromFirestore(doc);
  }

  String _generatePairCode() {
    final random = Random();
    return List.generate(
      AppConstants.pairCodeLength,
      (_) => random.nextInt(10),
    ).join();
  }
}
