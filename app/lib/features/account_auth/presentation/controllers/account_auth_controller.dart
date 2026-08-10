import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/account_auth_repository.dart';

part 'account_auth_controller.g.dart';

@riverpod
class AccountAuthController extends _$AccountAuthController {
  @override  
  FutureOr<void> build() {
    return null;
  }

  Future<void> login(String email, String password) async {
    // Loading
    state = const AsyncValue.loading();
    
    // Proses
    state = await AsyncValue.guard(() async {
      final repo = ref.read(accountAuthRepositoryProvider);
      await repo.login(email: email, password: password);
    });
  }

  Future<void> register(String name, String email, String password) async {
    // Loading
    state = const AsyncValue.loading();

    // Proses
    state = await AsyncValue.guard(() async {
      final repo = ref.read(accountAuthRepositoryProvider);
      await repo.register(name: name, email: email, password: password);
    });
  }
}