import 'package:expense_tracker/data/models/account_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountService {
  static const String table = 'account';
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Account>> getAllAccounts() async {
    final response = await _supabase
        .from(table)
        .select()
        .eq('is_deleted', 0)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => Account.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Account?> getAccountById(int id) async {
    final response = await _supabase
        .from(table)
        .select()
        .eq('id', id)
        .maybeSingle();

    return response != null ? Account.fromJson(response) : null;
  }

  Future<Account?> createAccount(Account account) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final response = await _supabase
        .from(table)
        .insert({...account.toJson(forInsert: true), 'user_id': user.id})
        .select()
        .maybeSingle();

    return response != null ? Account.fromJson(response) : null;
  }

  Future<Account?> updateAccount(Account account) async {
    final id = account.id;
    if (id == null) throw Exception("Account ID is required for update");

    final response = await _supabase
        .from(table)
        .update(account.toJson())
        .eq('id', id)
        .select()
        .maybeSingle();

    return response != null ? Account.fromJson(response) : null;
  }

  Future<void> deleteAccount(int id) async {
    await _supabase
        .from(table)
        .update({
          'is_deleted': 1,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  Future<void> hardDeleteAccount(int id) async {
    await _supabase.from(table).delete().eq('id', id);
  }
}
