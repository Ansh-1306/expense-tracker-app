import 'package:expense_tracker/constants/app_routes.dart';
import 'package:expense_tracker/screens/accounts_list_screen.dart';
import 'package:expense_tracker/screens/auth_screen.dart';
import 'package:expense_tracker/screens/home_screen.dart';
import 'package:expense_tracker/screens/settings_screen.dart';
import 'package:flutter/material.dart';

class AppScreens {
  static Map<String, WidgetBuilder> screens = {
    AppRoutes.home: (context) => const HomeScreen(),
    AppRoutes.auth: (context) => const AuthScreen(),
    AppRoutes.accountList: (context) => AccountListScreen(),
    AppRoutes.settings: (context) => const SettingsScreen(),
  };
}
