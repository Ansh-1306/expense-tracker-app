import 'package:expense_tracker/constants/app_colors.dart';
import 'package:expense_tracker/constants/app_routes.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
      body: const SafeArea(
        child: Center(
          child: Text(
            'Your expenses will appear here.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        materialTapTargetSize: MaterialTapTargetSize.padded,
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.accountList);
        },
        tooltip: 'Add Expense',
        child: const Icon(Icons.add),
      ),
      drawer: SafeArea(
        child: Drawer(
          child: Column(
            children: [
              Container(
                color: AppColors.drawerHeaderBg,
                height: 180,
                child: const Center(child: Text('header')),
              ),
              Expanded(child: ListView(shrinkWrap: true, children: const [])),
              SizedBox(height: 60, child: Center(child: Text('footer'))),
            ],
          ),
        ),
      ),
    );
  }
}
