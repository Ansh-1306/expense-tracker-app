import 'package:expense_tracker/constants/app_routes.dart';
import 'package:expense_tracker/features/accounts/accounts_screen.dart';
import 'package:expense_tracker/features/auth/auth_screen.dart';
import 'package:expense_tracker/features/home/home_screen.dart';
import 'package:expense_tracker/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';

class AppScreens {
  static Map<String, WidgetBuilder> screens = {
    AppRoutes.home: (context) => const HomeScreen(),
    AppRoutes.auth: (context) => const AuthScreen(),
    AppRoutes.accountList: (context) => AccountListScreen(),
    AppRoutes.settings: (context) => const SettingsScreen(),
  };
}
