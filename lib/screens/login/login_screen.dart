import 'package:fit_track_pro/models/custom_error.dart';
import 'package:fit_track_pro/screens/login/login_provider.dart';
import 'package:fit_track_pro/utils/error_dialog.dart';
import 'package:fit_track_pro/widgets/email_textfield.dart';
import 'package:fit_track_pro/widgets/password_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../pallete/colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
    });

    final form = _formKey.currentState;

    if (form == null || !form.validate()) return;

    ref.read(loginProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(loginProvider, (previous, state) {
      state.whenOrNull(
        error: (e, st) {
          errorDialog(context, e as CustomError);
        },
      );
    });

    final loginState = ref.watch(loginProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // Logo Image
                Image.asset(
                  'assets/images/login_img.png',
                  height: 150,
                ),
                const SizedBox(height: 32),

                // App Title
                Text(
                  'FitTrackPro',
                  style: GoogleFonts.roboto(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorDark,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Achieve your fitness goals today',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: AppColors.textColorLight,
                  ),
                ),
                const SizedBox(height: 48),

                // Email TextField
                EmailTextField(
                  controller: _emailController,
                  enabled: loginState.maybeWhen(
                    loading: () => false,
                    orElse: () => true,
                  ),
                ),
                const Gap(12),

                // Password TextField
                PasswordTextField(
                  controller: _passwordController,
                  enabled: loginState.maybeWhen(
                    loading: () => false,
                    orElse: () => true,
                  ),
                ),
                const SizedBox(height: 8),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                    },
                    child: Text(
                      'Forgot your password?',
                      style: GoogleFonts.roboto(
                        color: AppColors.primaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: loginState.maybeWhen(
                      loading: () => null,
                      orElse: () => _submit,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.backgroundGrey,
                      foregroundColor: AppColors.textColorDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      loginState.maybeWhen(
                        loading: () => 'Logging in...',
                        orElse: () => 'Login',
                      ),
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.roboto(
                        color: AppColors.textColorLight,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/register');
                      },
                      child: Text(
                        'Register',
                        style: GoogleFonts.roboto(
                          color: AppColors.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
