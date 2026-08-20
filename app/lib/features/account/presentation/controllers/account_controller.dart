import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vodan/features/account/data/models/login_request__model.dart';
import 'package:vodan/features/account/data/models/register_request_model.dart';
import '../../data/repositories/account_repository.dart';

part 'account_controller.g.dart';

@riverpod
class AccountController extends _$AccountController {
  @override  
  FutureOr<void> build() {
    return null;
  }

  Future<void> login(LoginRequestModel data) async {
    // Loading
    state = const AsyncValue.loading();
    
    try {
      // Proses
      state = await AsyncValue.guard(() async {
        final repo = ref.read(accountRepositoryProvider);
        await repo.login(data: data);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register(RegisterRequestModel data) async {
    // Loading
    state = const AsyncValue.loading();

    try {
      // Proses
      state = await AsyncValue.guard(() async {
        final repo = ref.read(accountRepositoryProvider);
        await repo.register(data: data);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    // Loading
    state = const AsyncValue.loading();

    // Proses
    try {
      final repo = ref.read(accountRepositoryProvider);
      await repo.logout();
    } catch (e) {
      // print('Gagal logout: $e');
    }
  }
}

@Riverpod(keepAlive: true)
User? getAccount(Ref ref) {
  final repo = ref.watch(accountRepositoryProvider);
  // print(repo.currentUser);
  return repo.currentUser; 
}