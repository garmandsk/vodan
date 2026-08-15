import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vodan/core/providers/supabase_provider.dart';
import 'package:vodan/features/account_auth/data/models/account_response_model.dart';
import 'package:vodan/features/account_auth/data/models/login_request__model.dart';
import 'package:vodan/features/account_auth/data/models/register_request_model.dart';

part 'account_auth_repository.g.dart';

class AccountAuthRepository {
  AccountAuthRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<AccountResponseModel> login({required LoginRequestModel data}) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: data.email,
        password: data.password
      );

      final user = response.user!;
      // final userData = await _supabase
      //   .from('users')
      //   .select()
      //   .eq('id', user.id)
      //   .single();
      
      return AccountResponseModel(
        id: user.id, 
        email: user.email!,
        displayName: user.userMetadata?['display_name']
      );
    } catch (e) {
      throw Exception('Gagal login: $e');
    }
  }

  Future<void> register({required RegisterRequestModel data}) async {
    try {
      await _supabase.auth.signUp(
        email: data.email,
        password: data.password,
        data: {
          'display_name': data.displayName
        }
      );
    } catch (e) {
      throw Exception('Gagal register: $e');
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  // Stream untuk memantau sesi
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}

@Riverpod(keepAlive: true)
AccountAuthRepository accountAuthRepository(Ref ref) {
  return AccountAuthRepository(ref.watch(supabaseClientProvider));
}