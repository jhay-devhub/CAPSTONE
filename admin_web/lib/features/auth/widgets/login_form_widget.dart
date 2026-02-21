import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/login_controller.dart';

class LoginFormWidget extends GetView<LoginController> {
  const LoginFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EmailField(controller: controller),
          const SizedBox(height: 16),
          _PasswordField(controller: controller),
          const SizedBox(height: 8),

          // Error message
          Obx(() {
            if (controller.errorMessage.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.errorMessage.value,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 24),
          _SubmitButton(controller: controller),
        ],
      ),
    );
  }
}

// ─── Email Field ──────────────────────────────────────────────────────────────

class _EmailField extends StatelessWidget {
  final LoginController controller;
  const _EmailField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConstants.labelEmail,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          onChanged: (_) => controller.clearError(),
          validator: controller.validateEmail,
          decoration: _inputDecoration(
            hint: 'admin@example.com',
            icon: Icons.email_outlined,
          ),
        ),
      ],
    );
  }
}

// ─── Password Field ───────────────────────────────────────────────────────────

class _PasswordField extends StatelessWidget {
  final LoginController controller;
  const _PasswordField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConstants.labelPassword,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Obx(
          () => TextFormField(
            controller: controller.passwordController,
            obscureText: controller.obscurePassword.value,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => controller.login(),
            onChanged: (_) => controller.clearError(),
            validator: controller.validatePassword,
            decoration: _inputDecoration(
              hint: '••••••••',
              icon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: controller.toggleObscurePassword,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Submit Button ────────────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  final LoginController controller;
  const _SubmitButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.login,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  AppConstants.buttonLogin,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Input Decoration Helper ──────────────────────────────────────────────────

InputDecoration _inputDecoration({
  required String hint,
  required IconData icon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
    prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: AppColors.inputFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.inputBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.inputBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.inputFocusBorder, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
  );
}
