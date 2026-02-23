import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // ─── Form ────────────────────────────────────────────────────────────────────

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // ─── State ───────────────────────────────────────────────────────────────────

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxString errorMessage = ''.obs;

  // ─── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // ─── Actions ─────────────────────────────────────────────────────────────────

  void toggleObscurePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  void clearError() {
    errorMessage.value = '';
  }

  Future<void> login() async {
    // Reset previous error
    clearError();

    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      await _authService.signIn(
        emailController.text,
        passwordController.text,
      );

      // Navigate to dashboard on success
      Get.offAllNamed(AppConstants.routeDashboard);
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _mapFirebaseAuthError(e);
    } on String catch (e) {
      // Custom string errors thrown by AuthService (e.g. not an admin)
      errorMessage.value = e;
    } catch (_) {
      errorMessage.value = AppConstants.errorGeneric;
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Validators ──────────────────────────────────────────────────────────────

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.errorInvalidEmail;
    }
    if (!GetUtils.isEmail(value.trim())) {
      return AppConstants.errorInvalidEmail;
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.errorEmptyPassword;
    }
    if (value.length < 6) {
      return AppConstants.errorWeakPassword;
    }
    return null;
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found for this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'invalid-email':
        return AppConstants.errorInvalidEmail;
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return AppConstants.errorNetworkFailed;
      default:
        return e.message ?? AppConstants.errorGeneric;
    }
  }
}
