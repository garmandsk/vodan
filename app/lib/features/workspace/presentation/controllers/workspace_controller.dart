import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vodan/core/providers/session.dart';
import 'package:vodan/features/workspace/data/models/workspace_response_model.dart';
import '../../data/repositories/workspace_repository.dart';

part 'workspace_controller.g.dart';

@Riverpod(keepAlive: true)
class WorkspaceController extends _$WorkspaceController {
  @override  
  FutureOr<List<WorkspaceResponseModel>> build() async {
    final repo = ref.read(workspaceRepositoryProvider);
    return await repo.getWorkspaceList();
  }

  Future<String?> editPin(String workspaceId, String newPin) async {
    try {
      final repo = ref.read(workspaceRepositoryProvider);
      await repo.editPin(workspaceId, newPin);
      return null;
    } catch (e) {
      return 'Gagal edit pin lapak';
      // return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> editWorkspaceName(String workspaceId, String newName) async {
    try {
      final repo = ref.read(workspaceRepositoryProvider);
      await repo.editWorkspaceName(workspaceId, newName);

      ref.read(currentWorkspaceProvider.notifier).setWorkspaceSession(workspaceId: workspaceId, workspaceName: newName);
      return null;
    } catch (e) {
      // return 'Gagal edit nama lapak';
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> deleteWorkspace(String id) async {
    await ref.read(workspaceRepositoryProvider).deleteWorkspace(id);

    final currentId = ref.read(currentWorkspaceProvider)?.id;
    if (currentId == id) {
      ref.read(currentWorkspaceProvider.notifier).clearWorkspaceSession();
    }

    ref.invalidateSelf();
  }
}