import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vodan/features/account_auth/data/models/login_request__model.dart';
import 'package:vodan/features/account_auth/data/models/register_request_model.dart';
import '../../data/repositories/account_auth_repository.dart';

part 'account_auth_controller.g.dart';

@riverpod
class AccountAuthController extends _$AccountAuthController {
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
        final repo = ref.read(accountAuthRepositoryProvider);
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
        final repo = ref.read(accountAuthRepositoryProvider);
        await repo.register(data: data);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}