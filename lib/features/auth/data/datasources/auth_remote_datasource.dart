import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await firebaseAuth.signInWithCredential(credential);
    final uid = userCredential.user!.uid;

    // Check if user doc exists, create if not
    final doc = await firestore.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists) {
      final user = UserModel(
        id: uid,
        email: userCredential.user!.email ?? '',
        displayName: userCredential.user!.displayName ?? '',
        createdAt: DateTime.now(),
      );
      await firestore.collection(AppConstants.usersCollection).doc(uid).set(user.toFirestore());
      return user;
    }
    return UserModel.fromFirestore(doc);
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

    final pairDoc = await firestore.collection(AppConstants.pairsCollection).add({
      'user1Id': userId,
      'user2Id': null,
      'pairCode': pairCode,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await firestore.collection(AppConstants.usersCollection).doc(userId).update({
      'pairId': pairDoc.id,
    });

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

    await firestore.collection(AppConstants.pairsCollection).doc(pairDoc.id).update({
      'user2Id': userId,
    });

    await firestore.collection(AppConstants.usersCollection).doc(userId).update({
      'pairId': pairDoc.id,
      'partnerId': partnerId,
    });

    await firestore.collection(AppConstants.usersCollection).doc(partnerId).update({
      'partnerId': userId,
    });

    return _getUserModel(userId);
  }

  @override
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<UserModel> _getUserModel(String uid) async {
    final doc = await firestore.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists) {
      throw Exception('User document not found');
    }
    return UserModel.fromFirestore(doc);
  }

  String _generatePairCode() {
    final random = Random();
    return List.generate(AppConstants.pairCodeLength, (_) => random.nextInt(10)).join();
  }
}
