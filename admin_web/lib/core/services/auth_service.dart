import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../models/admin_user_model.dart';

/// Wraps Firebase Auth + Firestore admin verification.
class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Observables ────────────────────────────────────────────────────────────

  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<AdminUserModel?> adminUser = Rx<AdminUserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    // Keep firebaseUser in sync with auth state changes.
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  // ─── Auth Operations ─────────────────────────────────────────────────────────

  /// Signs in with email & password, then verifies the user exists in
  /// the Firestore [AppConstants.adminsCollection] and is active.
  ///
  /// Returns the [AdminUserModel] on success.
  /// Throws a [String] error message on failure.
  Future<AdminUserModel> signIn(String email, String password) async {
    // Step 1 – Firebase Auth sign-in
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;

    // Step 2 – Verify admin record in Firestore
    final doc = await _firestore
        .collection(AppConstants.adminsCollection)
        .doc(uid)
        .get();

    if (!doc.exists) {
      await _auth.signOut();
      throw AppConstants.errorNotAdmin;
    }

    final admin = AdminUserModel.fromFirestore(doc, uid);

    if (!admin.isActive) {
      await _auth.signOut();
      throw 'Your admin account has been deactivated. Please contact support.';
    }

    adminUser.value = admin;
    return admin;
  }

  /// Signs out the current user and clears the local admin model.
  Future<void> signOut() async {
    await _auth.signOut();
    adminUser.value = null;
  }

  /// Returns true when a Firebase user session exists AND the admin
  /// record is loaded (or can be re-fetched).
  Future<bool> isLoggedInAsAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore
          .collection(AppConstants.adminsCollection)
          .doc(user.uid)
          .get();

      if (!doc.exists) return false;

      final admin = AdminUserModel.fromFirestore(doc, user.uid);
      if (!admin.isActive) return false;

      adminUser.value = admin;
      return true;
    } catch (_) {
      return false;
    }
  }
}
