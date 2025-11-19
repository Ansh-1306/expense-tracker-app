import 'package:expense_tracker/constants/app_routes.dart';
import 'package:expense_tracker/constants/app_screens.dart';
import 'package:expense_tracker/core/network_service.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  NetworkService.instance.initialize();

  await Supabase.initialize(
    url: 'https://yknqjyfdybzkvjbjpgqg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlrbnFqeWZkeWJ6a3ZqYmpwZ3FnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk1NzExNjcsImV4cCI6MjA3NTE0NzE2N30.PjPbl4k7euWeUtmLszVWun4CnNvAiNnzLb3ADiAhDTg',
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void networkListener() {
    final connected = NetworkService.instance.isConnectedNotifier.value;

    final messenger = ScaffoldMessenger.of(navigatorKey.currentContext!);

    if (!connected) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('You are currently offline.'),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(days: 1),
        ),
      );
    } else {
      messenger.clearSnackBars();
    }
  }

  @override
  void initState() {
    super.initState();
    NetworkService.instance.isConnectedNotifier.addListener(networkListener);
  }

  @override
  void dispose() {
    NetworkService.instance.isConnectedNotifier.removeListener(networkListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Expense Tracker',
      theme: FlexThemeData.light(scheme: FlexScheme.blueM3),
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.blueM3),
      debugShowCheckedModeBanner: false,
      initialRoute: Supabase.instance.client.auth.currentUser == null
          ? AppRoutes.auth
          : AppRoutes.home,
      routes: AppScreens.screens,
    );
  }
}
