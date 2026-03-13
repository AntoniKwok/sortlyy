import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/social_sign_in_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          state.maybeWhen(
            authenticated: (_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const OnboardingPage()),
              );
            },
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: AppColors.delete,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          final isBlocLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(flex: 5, child: _HeroSection()),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                    child: _AuthSection(isBlocLoading: isBlocLoading),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Hero section ─────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const _BackgroundPhotoFrames(),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _PhotoStackIcon()
                .animate()
                .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 28),
            const Text(
              'Sortlyy',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 52,
                fontWeight: FontWeight.w800,
                letterSpacing: -3.0,
                height: 1.0,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 150.ms, curve: Curves.easeOut)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 10),
            const Text(
              'Tinder for your camera roll.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.2,
              ),
            )
                .animate()
                .fadeIn(
                    duration: 600.ms, delay: 250.ms, curve: Curves.easeOut),
          ],
        ),
      ],
    );
  }
}

class _PhotoStackIcon extends StatelessWidget {
  const _PhotoStackIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.22,
            child: _photoCard(
                color: AppColors.surfaceElevated,
                borderColor: const Color(0xFF303030),
                size: 72),
          ),
          Transform.rotate(
            angle: 0.14,
            child: _photoCard(
                color: AppColors.surface,
                borderColor: const Color(0xFF383838),
                size: 72),
          ),
          _photoCard(
            color: AppColors.cardBackground,
            borderColor: AppColors.border,
            size: 72,
            icon: const Icon(Icons.photo_library_rounded,
                color: AppColors.textTertiary, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _photoCard(
      {required Color color,
      required Color borderColor,
      required double size,
      Widget? icon}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: icon != null ? Center(child: icon) : null,
    );
  }
}

class _BackgroundPhotoFrames extends StatelessWidget {
  const _BackgroundPhotoFrames();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            _frame(top: 60, left: -20, angle: -0.3, opacity: 0.06, size: 80),
            _frame(top: 40, right: -10, angle: 0.4, opacity: 0.05, size: 64),
            _frame(
                bottom: 80, left: 20, angle: 0.2, opacity: 0.07, size: 56),
            _frame(
                bottom: 60, right: 15, angle: -0.25, opacity: 0.05, size: 70),
          ],
        ),
      ),
    );
  }

  Widget _frame(
      {double? top,
      double? bottom,
      double? left,
      double? right,
      required double angle,
      required double opacity,
      required double size}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: angle,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Auth section ─────────────────────────────────────────────────────────────

class _AuthSection extends StatefulWidget {
  final bool isBlocLoading;
  const _AuthSection({required this.isBlocLoading});

  @override
  State<_AuthSection> createState() => _AuthSectionState();
}

class _AuthSectionState extends State<_AuthSection> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isEmailLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isLoading => widget.isBlocLoading || _isEmailLoading;

  Future<void> _submitEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter your email and password.');
      return;
    }

    setState(() => _isEmailLoading = true);
    try {
      if (_isSignUp) {
        await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );
      } else {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      }
      // AuthBloc stream listener handles navigation on success
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    } catch (_) {
      if (mounted) _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isEmailLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.delete,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Email form ────────────────────────────────────────────────
        _EmailField(controller: _emailController, enabled: !_isLoading),
        const SizedBox(height: 10),
        _PasswordField(
          controller: _passwordController,
          enabled: !_isLoading,
          obscure: _obscurePassword,
          onToggleObscure: () =>
              setState(() => _obscurePassword = !_obscurePassword),
          onSubmit: _submitEmail,
        ),
        const SizedBox(height: 14),
        _EmailSubmitButton(
          isSignUp: _isSignUp,
          isLoading: _isEmailLoading,
          onPressed: _submitEmail,
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 300.ms, curve: Curves.easeOut)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 10),

        // ── Toggle sign in / sign up ──────────────────────────────────
        GestureDetector(
          onTap: () => setState(() => _isSignUp = !_isSignUp),
          child: Text(
            _isSignUp
                ? 'Already have an account? Sign in'
                : "Don't have an account? Create one",
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 350.ms),

        const SizedBox(height: 20),

        // ── Divider ───────────────────────────────────────────────────
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'or',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.border)),
          ],
        ).animate().fadeIn(duration: 500.ms, delay: 380.ms),

        const SizedBox(height: 16),

        // ── Google sign-in ────────────────────────────────────────────
        SocialSignInButton(
          provider: SocialProvider.google,
          isLoading: widget.isBlocLoading,
          onPressed: () => context
              .read<AuthBloc>()
              .add(const AuthEvent.googleSignInRequested()),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 420.ms, curve: Curves.easeOut)
            .slideY(begin: 0.3, end: 0),

        // ── Apple sign-in (iOS only) ──────────────────────────────────
        if (Platform.isIOS) ...[
          const SizedBox(height: 10),
          SocialSignInButton(
            provider: SocialProvider.apple,
            isLoading: widget.isBlocLoading,
            onPressed: () => context
                .read<AuthBloc>()
                .add(const AuthEvent.appleSignInRequested()),
          )
              .animate()
              .fadeIn(
                  duration: 500.ms, delay: 480.ms, curve: Curves.easeOut)
              .slideY(begin: 0.3, end: 0),
        ],

        const SizedBox(height: 20),

        // ── Legal ─────────────────────────────────────────────────────
        const Text(
          'By continuing, you agree to our Terms of Service\nand Privacy Policy. Photos never leave your device.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11,
            height: 1.6,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 520.ms),
      ],
    );
  }
}

// ─── Form widgets ─────────────────────────────────────────────────────────────

class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const _EmailField({required this.controller, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: _inputDecoration('Email', Icons.mail_outline_rounded),
    ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideY(begin: 0.3, end: 0);
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  const _PasswordField({
    required this.controller,
    required this.enabled,
    required this.obscure,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscure,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => onSubmit(),
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: _inputDecoration('Password', Icons.lock_outline_rounded)
          .copyWith(
        suffixIcon: IconButton(
          onPressed: onToggleObscure,
          icon: Icon(
            obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: AppColors.textTertiary,
            size: 18,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 450.ms).slideY(begin: 0.3, end: 0);
  }
}

class _EmailSubmitButton extends StatelessWidget {
  final bool isSignUp;
  final bool isLoading;
  final VoidCallback onPressed;

  const _EmailSubmitButton({
    required this.isSignUp,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          foregroundColor: AppColors.background,
          disabledBackgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.background,
                ),
              )
            : Text(
                isSignUp ? 'Create Account' : 'Sign In',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String label, IconData icon) {
  return InputDecoration(
    hintText: label,
    hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
    prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 18),
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.textSecondary),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    ),
  );
}
