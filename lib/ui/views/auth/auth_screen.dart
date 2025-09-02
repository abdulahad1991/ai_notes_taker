import 'package:ai_notes_taker/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../i18n/strings.g.dart';
import 'auth_viewmodel.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For responsive UI
    final isWide = MediaQuery.of(context).size.width > 600;

    return ViewModelBuilder<AuthViewModel>.reactive(
      viewModelBuilder: () => AuthViewModel()..init(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: const Color(0xFFF8F9FA), // soft light gray
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 0 : 24,
                vertical: 32,
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 36,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: model.formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // _buildLanguageToggle(model),
                      // const SizedBox(height: 16),
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildFormFields(model),
                      const SizedBox(height: 28),
                      _buildSubmitButton(model, context),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 24),
                      _buildToggleButton(model),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageToggle(AuthViewModel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageButton(
                model,
                AppLocale.en,
                t.language.english,
                Icons.language,
              ),
              _buildLanguageButton(
                model,
                AppLocale.de,
                t.language.german,
                Icons.language,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageButton(
    AuthViewModel model,
    AppLocale locale,
    String label,
    IconData icon,
  ) {
    final isSelected = model.currentLocale == locale;
    return GestureDetector(
      onTap: () => model.setLanguage(locale),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF667eea) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF667eea),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            t.app.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
              color: Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            t.app.subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w400,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields(AuthViewModel model) {
    return Column(
      children: [
        if (!model.isLogin) ...[
          _buildTextField(
            controller: model.nameController,
            label: t.auth.fullName,
            icon: Icons.person_outline,
            validator: (value) {
              if (value?.isEmpty ?? true) return t.auth.validation.enterName;
              return null;
            },
          ),
          const SizedBox(height: 16),
        ],
        _buildTextField(
          controller: model.emailController,
          label: t.auth.email,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isEmpty ?? true) return t.auth.validation.enterEmail;
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
              return t.auth.validation.validEmail;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: model.passwordController,
          label: t.auth.password,
          icon: Icons.lock_outline,
          isPassword: true,
          isPasswordVisible: model.isPasswordVisible,
          onTogglePassword: model.togglePasswordVisibility,
          validator: (value) {
            if (value?.isEmpty ?? true) return t.auth.validation.enterPassword;
            if (value!.length < 6) return t.auth.validation.passwordLength;
            return null;
          },
        ),
        if (!model.isLogin) ...[
          const SizedBox(height: 16),
          _buildTextField(
            controller: model.confirmPasswordController,
            label: t.auth.confirmPassword,
            icon: Icons.lock_outline,
            isPassword: true,
            isPasswordVisible: model.isConfirmPasswordVisible,
            onTogglePassword: model.toggleConfirmPasswordVisibility,
            validator: (value) {
              if (value?.isEmpty ?? true) return t.auth.validation.confirmPassword;
              if (value != model.passwordController.text) return t.auth.validation.passwordsMatch;
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword && !isPasswordVisible,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey[500],
          ),
          onPressed: onTogglePassword,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:  BorderSide(color: AppColors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
      ),
    );
  }

  Widget _buildSubmitButton(AuthViewModel model, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: model.isBusy ? null : () => model.submitForm(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667eea),
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
        child: model.isBusy
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            model.isLogin ? t.auth.signIn : t.auth.createAccount,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            t.auth.or,
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
      ],
    );
  }

  Widget _buildToggleButton(AuthViewModel model) {
    return Flexible(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text(
            model.isLogin
                ? t.auth.dontHaveAccount
                : t.auth.alreadyHaveAccount,
            style: TextStyle(
              color: Colors.grey[600], 
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          GestureDetector(
            onTap: model.toggleAuthMode,
            child: Text(
              model.isLogin ? t.auth.signUp : t.auth.signIn,
              style: const TextStyle(
                color: Color(0xFF667eea),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
