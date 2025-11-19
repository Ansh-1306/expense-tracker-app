import 'package:expense_tracker/constants/app_routes.dart';
import 'package:expense_tracker/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authProvider);
    final notifier = ref.read(authProvider.notifier);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // LISTEN FOR ERRORS + MESSAGES + NAVIGATION
    ref.listen(authProvider, (prev, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }

      if (next.message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message!)));
      }

      if (next.navigateToHome) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (_) => false,
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(state, theme, colorScheme),
                const SizedBox(height: 32),
                _buildForm(notifier, theme, colorScheme),
                const SizedBox(height: 28),
                _mainButton(state, notifier, colorScheme),
                const SizedBox(height: 24),
                _buildDivider(theme),
                const SizedBox(height: 24),
                _googleButton(state, notifier, colorScheme),
                const SizedBox(height: 32),
                _toggleAuth(state, notifier, colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────── HEADER ─────────────────
  Widget _buildHeader(
    AuthState state,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            size: 40,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          state.isLogin ? "Welcome Back" : "Create Account",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          state.isLogin
              ? "Sign in to manage your expenses"
              : "Get started with your expense tracker",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ───────────────── FORM ─────────────────
  Widget _buildForm(
    AuthController notifier,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        TextField(
          controller: notifier.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: "Email",
            prefixIcon: Icon(Icons.email_rounded, color: colorScheme.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: notifier.passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Password",
            prefixIcon: Icon(Icons.lock_rounded, color: colorScheme.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────── MAIN LOGIN/SIGNUP BUTTON ─────────────────
  Widget _mainButton(
    AuthState state,
    AuthController notifier,
    ColorScheme colorScheme,
  ) {
    return ElevatedButton(
      onPressed: state.isLoading ? null : notifier.authenticate,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: state.isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: colorScheme.onPrimary,
                strokeWidth: 2,
              ),
            )
          : Text(
              state.isLogin ? "Sign In" : "Create Account",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    );
  }

  // ───────────────── DIVIDER ─────────────────
  Widget _buildDivider(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: theme.dividerColor.withValues(alpha: 0.3)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "or continue with",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
        Expanded(
          child: Divider(color: theme.dividerColor.withValues(alpha: 0.3)),
        ),
      ],
    );
  }

  // ───────────────── GOOGLE BUTTON ─────────────────
  Widget _googleButton(
    AuthState state,
    AuthController notifier,
    ColorScheme colorScheme,
  ) {
    return OutlinedButton.icon(
      onPressed: state.isLoading ? null : notifier.signInWithGoogle,
      icon: Image.asset('assets/google_logo.png', height: 20, width: 20),
      label: const Text(
        "Continue with Google",
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ───────────────── TOGGLE LOGIN/SIGNUP ─────────────────
  Widget _toggleAuth(
    AuthState state,
    AuthController notifier,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          state.isLogin ? "Don't have an account?" : "Already have an account?",
          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: notifier.toggleMode,
          child: Text(
            state.isLogin ? "Sign up" : "Sign in",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
