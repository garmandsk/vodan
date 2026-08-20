import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vodan/core/providers/supabase_provider.dart';
import 'package:vodan/features/account/data/models/account_response_model.dart';
import 'package:vodan/features/account/data/models/login_request__model.dart';
import 'package:vodan/features/account/data/models/register_request_model.dart';

part 'account_repository.g.dart';

class AccountRepository {
  AccountRepository(this._supabase);

  final SupabaseClient _supabase;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  User? get currentUser => _supabase.auth.currentUser;

  Future<AccountResponseModel> login({required LoginRequestModel data}) async {
    try {
      final response = await _supabase.auth
          .signInWithPassword(email: data.email, password: data.password);

      final user = response.user!;
      // final userData = await _supabase
      //   .from('users')
      //   .select()
      //   .eq('id', user.id)
      //   .single();

      return AccountResponseModel(
          id: user.id, email: user.email!, name: user.userMetadata?['name']);
    } catch (e) {
      throw Exception('Gagal login: $e');
    }
  }

  Future<void> register({required RegisterRequestModel data}) async {
    try {
      await _supabase.auth.signUp(
          email: data.email,
          password: data.password,
          data: {'name': data.name});
    } catch (e) {
      throw Exception('Gagal register: $e');
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}

@Riverpod(keepAlive: true)
AccountRepository accountRepository(Ref ref) {
  return AccountRepository(ref.watch(supabaseClientProvider));
}
