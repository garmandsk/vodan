import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vodan/core/providers/session.dart';
import 'package:vodan/features/workspace/data/models/workspace_response_model.dart';
import 'package:vodan/features/workspace/data/models/payment_config_model.dart';
import 'package:vodan/features/workspace_auth/data/models/create_workspace_request_model.dart';
import '../../data/repositories/workspace_repository.dart';

part 'workspace_controller.g.dart';

@Riverpod(keepAlive: true)
class WorkspaceController extends _$WorkspaceController {
  @override
  FutureOr<List<WorkspaceResponseModel>> build() async {
    final repo = ref.read(workspaceRepositoryProvider);
    return await repo.getWorkspaceList();
  }

  Future<String?> getWorkspaceById(String id) async {
    try {
      final repo = ref.read(workspaceRepositoryProvider);
      final workspace = await repo.getWorkspaceById(id);

      ref.read(currentWorkspaceProvider.notifier).setWorkspaceSession(
          workspaceId: workspace.id, workspaceName: workspace.name);
      return null;
    } catch (e) {
      return 'Gagal mengambil data lapak';
      // return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<List<AiKeys>?> getWorkspaceAiKeys(String workspaceId) async {
    try {
      final repo = ref.read(workspaceRepositoryProvider);
      final aiKeys = await repo.getWorkspaceAiKeys(workspaceId);
      return aiKeys;
    } catch (e) {
      return null;
    }
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

      ref.read(currentWorkspaceProvider.notifier).setWorkspaceSession(
          workspaceId: workspaceId, workspaceName: newName);
      return null;
    } catch (e) {
      return 'Gagal edit nama lapak';
      // return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> editWorkspaceAiKeys(
      String workspaceId, List<AiKeys> newAiKeys) async {
    try {
      final repo = ref.read(workspaceRepositoryProvider);
      await repo.editWorkspaceAiKeys(workspaceId, newAiKeys);
      return null;
    } catch (e) {
      return 'Gagal edit AI keys lapak';
      // return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> toggleSaleBroadcast(
      String workspaceId, bool currentValue) async {
    try {
      final repo = ref.read(workspaceRepositoryProvider);
      final newValue = !currentValue;
      await repo.editIsSaleBroadcastOn(workspaceId, newValue);

      ref
          .read(currentWorkspaceProvider.notifier)
          .updateSaleBroadcastStatus(newValue);

      return null;
    } catch (e) {
      // return 'gagal toggle sale broadcast
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> deleteWorkspace(String id) async {
    try {
      final repo = ref.read(workspaceRepositoryProvider);
      await repo.deleteWorkspace(id);

      final currentId = ref.read(currentWorkspaceProvider)?.id;
      if (currentId == id) {
        ref.read(currentWorkspaceProvider.notifier).clearWorkspaceSession();
      }

      return null;
    } catch (e) {
      return 'Gagal hapus lapak: $e';
      // return e.toString().replaceAll('Exception: ', '');
    }
  }
}

@riverpod
Future<PaymentConfigModel> workspacePaymentConfig(Ref ref, String workspaceId) {
  return ref.read(workspaceRepositoryProvider).getPaymentConfig(workspaceId);
}
