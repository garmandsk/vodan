import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vodan/core/providers/supabase_provider.dart';

part 'account_auth_repository.g.dart';

class AccountAuthRepository {
  AccountAuthRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<void> login({required String email, required String password}) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password
    );
  }

  Future<void> register({required String name, required String email, required String password}) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'display_name': name
      }
    );
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  // Stream untuk memantau sesi
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}

@riverpod
AccountAuthRepository accountAuthRepository(Ref ref) {
  return AccountAuthRepository(ref.watch(supabaseClientProvider));
}