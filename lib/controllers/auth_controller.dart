import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ───────────────────────────────────────────────
// AUTH STATE MODEL
// ───────────────────────────────────────────────

class AuthState {
  final bool isLogin;
  final bool isLoading;
  final String? error;
  final String? message;
  final bool navigateToHome;

  AuthState({
    this.isLogin = true,
    this.isLoading = false,
    this.error,
    this.message,
    this.navigateToHome = false,
  });

  AuthState copyWith({
    bool? isLogin,
    bool? isLoading,
    String? error,
    String? message,
    bool? navigateToHome,
  }) {
    return AuthState(
      isLogin: isLogin ?? this.isLogin,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      message: message,
      navigateToHome: navigateToHome ?? false,
    );
  }
}

// ───────────────────────────────────────────────
// AUTH CONTROLLER (Notifier)
// ───────────────────────────────────────────────

class AuthController extends Notifier<AuthState> {
  final _supabase = Supabase.instance.client;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  AuthState build() => AuthState();

  // ─────────────── AUTHENTICATE (email/password) ──────────────
  Future<void> authenticate() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(error: "Email and Password cannot be empty");
      return;
    }

    state = state.copyWith(isLoading: true, error: null, message: null);

    try {
      if (state.isLogin) {
        // LOGIN
        final res = await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (res.user != null) {
          state = state.copyWith(navigateToHome: true);
        }
      } else {
        // SIGNUP
        final res = await _supabase.auth.signUp(
          email: email,
          password: password,
        );

        if (res.user != null) {
          state = state.copyWith(
            message: "Signup successful! Please verify your email.",
            isLogin: true,
          );
        }
      }
    } on AuthException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (_) {
      state = state.copyWith(error: "Unexpected error occurred");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // ─────────────── GOOGLE LOGIN ──────────────
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null, message: null);

    try {
      final googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize(
        serverClientId:
            "620029946687-shn3kgbeoouuufeca7belankr4bbfgkp.apps.googleusercontent.com",
      );

      var googleUser = await googleSignIn.attemptLightweightAuthentication();
      googleUser ??= await googleSignIn.authenticate();

      final scopes = ['email', 'profile'];

      final authorization =
          await googleUser.authorizationClient.authorizationForScopes(scopes) ??
          await googleUser.authorizationClient.authorizeScopes(scopes);

      final idToken = googleUser.authentication.idToken;

      if (idToken == null) {
        state = state.copyWith(error: "No ID token received from Google");
        return;
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: authorization.accessToken,
      );

      if (response.user == null) {
        state = state.copyWith(error: "Supabase login failed");
        return;
      }

      state = state.copyWith(navigateToHome: true);
    } on AuthException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (_) {
      state = state.copyWith(error: "Error logging in with Google");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // ─────────────── TOGGLE LOGIN/SIGNUP MODE ──────────────
  void toggleMode() {
    state = state.copyWith(isLogin: !state.isLogin, error: null, message: null);
  }

  void disposeControllers() {
    emailController.dispose();
    passwordController.dispose();
  }
}

// ───────────────────────────────────────────────
// PROVIDER
// ───────────────────────────────────────────────

final authProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
