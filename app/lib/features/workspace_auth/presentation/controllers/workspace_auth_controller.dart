import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vodan/features/workspace_auth/data/models/create_workspace_request_model.dart';
import '../../data/repositories/workspace_auth_repository.dart';

part 'workspace_auth_controller.g.dart';

@riverpod
class WorkspaceAuthController extends _$WorkspaceAuthController {
  @override  
  FutureOr<String?> build() {
    return null;
  }

  Future<String?> createWorkspace(CreateWorkspaceRequestModel data) async {
    // Loading
    state = const AsyncValue.loading();

    try {
      // Proses
      final repo = ref.read(workspaceAuthRepositoryProvider);
      final newWorkspaceId = await repo.createWorkspace(data: data);
      state = AsyncValue.data(newWorkspaceId);

      return newWorkspaceId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);

      return null;
    }
  }
}