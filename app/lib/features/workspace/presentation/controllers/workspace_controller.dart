import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vodan/core/providers/session.dart';
import 'package:vodan/features/workspace/data/models/workspace_response_model.dart';
import '../../data/repositories/workspace_repository.dart';

part 'workspace_controller.g.dart';

@riverpod
class WorkspaceController extends _$WorkspaceController {
  @override  
  FutureOr<List<WorkspaceResponseModel>> build() async {
    final repo = ref.read(workspaceRepositoryProvider);
    return await repo.getWorkspaceList();
  }

  Future<void> deleteWorkspace(String id) async {
    await ref.read(workspaceRepositoryProvider).deleteWorkspace(id);

    final currentId = ref.read(currentWorkspaceIdProvider);
    if (currentId == id) {
      ref.read(currentWorkspaceIdProvider.notifier).clearWorkspaceId();
    }

    ref.invalidateSelf();
  }
}