import 'package:expense_tracker/data/models/account_model.dart';
import 'package:expense_tracker/data/services/account_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountController extends AsyncNotifier<List<Account>> {
  final AccountService _service = AccountService();

  @override
  Future<List<Account>> build() async {
    // Called automatically when provider is first used.
    return await _service.getAllAccounts();
  }

  // ---------------- FETCH ACCOUNTS AGAIN ----------------
  Future<void> refreshAccounts() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.getAllAccounts());
  }

  // ---------------- ADD ACCOUNT ----------------
  Future<String?> addAccount(String name, double balance) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        return 'User not logged in';
      }

      final account = Account(name: name, balance: balance, userId: user.id);

      final created = await _service.createAccount(account);

      if (created == null) return 'Failed to create account';

      // Add to existing list
      final updated = [created, ...state.value!];
      state = AsyncData(updated);

      return 'Account added successfully';
    } catch (e) {
      return e.toString();
    }
  }

  // ---------------- UPDATE ACCOUNT ----------------
  Future<String?> updateAccount(Account updatedAccount) async {
    try {
      final updated = await _service.updateAccount(updatedAccount);

      if (updated == null) return 'Failed to update account';

      final list = state.value!.map((acc) {
        return acc.id == updatedAccount.id ? updated : acc;
      }).toList();

      state = AsyncData(list);

      return 'Account updated successfully';
    } catch (e) {
      return e.toString();
    }
  }

  // ---------------- DELETE ACCOUNT ----------------
  Future<String?> deleteAccount(Account account) async {
    try {
      await _service.deleteAccount(account.id!);

      final updated = state.value!.where((a) => a.id != account.id).toList();

      state = AsyncData(updated);

      return 'Account removed successfully';
    } catch (e) {
      return e.toString();
    }
  }
}

// ---------------- PROVIDER ----------------
final accountProvider = AsyncNotifierProvider<AccountController, List<Account>>(
  AccountController.new,
);
