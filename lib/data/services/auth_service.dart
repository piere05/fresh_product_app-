import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../models/user_role.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AppUser> signIn({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'User not found.',
      );
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'profile-missing',
        message: 'User profile not found.',
      );
    }

    final profile = AppUser.fromDoc(doc);
    if (profile.role != role) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'role-mismatch',
        message: 'Role mismatch.',
      );
    }

    if (profile.isBlocked) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'account-blocked',
        message: 'Account blocked by admin.',
      );
    }

    if (role == UserRole.farmer && !profile.isApproved) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'farmer-not-approved',
        message: 'Farmer account pending approval.',
      );
    }

    return profile;
  }

  Future<AppUser> registerFarmer({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Unable to create user.',
      );
    }

    final profile = AppUser(
      id: user.uid,
      name: name,
      email: email,
      phone: phone,
      role: UserRole.farmer,
      isApproved: false,
      isBlocked: false,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(profile.toMap());
    return profile;
  }

  Future<void> signOut() {
    return _auth.signOut();
  }
}
