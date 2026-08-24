import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:vodan/core/providers/session.dart';
import 'package:vodan/features/workspace_auth/data/repositories/waiting_room_repository.dart';

part 'waiting_room_controller.g.dart';

@riverpod
Stream<Map<String, dynamic>> myStatusStream(Ref ref) {
  final sessionId = ref.watch(currentUserProvider)?.sessionId;
  if (sessionId == null) return const Stream.empty();
  
  final repo = ref.watch(waitingRoomRepoProvider);
  return repo.watchMyStatus(sessionId);
}

@riverpod
Stream<List<String>> otherCashiersStream(Ref ref, {required String workspaceId}) {
  final sessionId = ref.watch(currentUserProvider)?.sessionId;
  if (sessionId == null) {
    // print('🚨 STREAM BERHENTI: sessionId masih null!');
    
    return Stream.value([]);
  }

  final repo = ref.watch(waitingRoomRepoProvider);
  
  return repo.watchOtherCashiers(workspaceId, sessionId).map((list) {
    // print('📦 Data mentah dari Supabase: $list');

    return list.map((e) => e['cashier_name'] as String).toList();
  });
}

@Riverpod(keepAlive: true)
class WaitingRoomController extends _$WaitingRoomController {
  @override
  void build() {} 

  Future<void> join(String workspaceId, String cashierName) async {
    final prefs = ref.read(sharedPrefsProvider);

    String? deviceId = prefs.getString('device_id');

    if (deviceId == null) {
      deviceId = const Uuid().v4();
      prefs.setString('device_id', deviceId);
    }

    final repo = ref.read(waitingRoomRepoProvider);
    final sessionId = await repo.joinWaitingRoom(
      workspaceId: workspaceId, 
      cashierName: cashierName,
      deviceId: deviceId
    );
    
    // Simpan ID Sesi ke provider notifier
    ref.read(currentUserProvider.notifier).setSession(name: cashierName, id: sessionId);
  }

  Future<void> editData(String newName, String newWorkspaceId) async {
    final sessionId = ref.read(currentUserProvider)?.sessionId;
    if (sessionId == null) return;
    
    await ref.read(waitingRoomRepoProvider).updateCredentials(sessionId, newName, newWorkspaceId);
  }

  Future<bool> scanTicket(String passCode, String workspaceId) async {
    final sessionId = ref.read(currentUserProvider)?.sessionId;
    if (sessionId == null) return false;
    
    return await ref.read(waitingRoomRepoProvider).validateShiftPass(passCode, workspaceId, sessionId);
  }
}