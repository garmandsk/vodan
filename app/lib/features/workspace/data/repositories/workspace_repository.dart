import 'dart:typed_data';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vodan/core/providers/supabase_provider.dart';
import 'package:vodan/features/workspace/data/models/workspace_response_model.dart';
import 'package:vodan/features/workspace/data/models/payment_config_model.dart';
import 'package:vodan/features/workspace_auth/data/models/create_workspace_request_model.dart';

part 'workspace_repository.g.dart';

class WorkspaceRepository {
  WorkspaceRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<List<WorkspaceResponseModel>> getWorkspaceList() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Sesi telah habis, Silahkan login kembali');
      }

      final response = await _supabase
          .from('workspaces')
          .select('id, name')
          .eq('owner_id', userId);

      final List<dynamic> data = response;
      return data.map((json) => WorkspaceResponseModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil daftar lapak: $e');
    }
  }

  Future<WorkspaceResponseModel> getWorkspaceById(String id) async {
    try {
      final response = await _supabase
          .from('workspaces')
          .select('id, name')
          .eq('id', id)
          .maybeSingle();
      if (response == null) throw Exception('Lapak tidak dimukan');
      return WorkspaceResponseModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil data lapak: $e');
    }
  }

  Future<List<AiKeys>> getWorkspaceAiKeys(String workspaceId) async {
    try {
      final response = await _supabase
          .from('workspaces')
          .select('ai_keys')
          .eq('id', workspaceId)
          .maybeSingle();
      if (response == null) throw Exception('Lapak tidak dimukan');
      final aiKeysJson = response['ai_keys'] as List?;
      if (aiKeysJson == null) throw Exception('AI keys tidak ditemukan');
      return aiKeysJson.map((json) => AiKeys.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil AI key lapak: $e');
    }
  }

  Future<bool> getIsSaleBroadcastOn(String workspaceId) async {
    try {
      final response = await _supabase
          .from('workspaces')
          .select('is_sale_broadcast_on')
          .eq('id', workspaceId)
          .single();
      return response['is_sale_broadcast_on'] as bool? ?? false;
    } catch (e) {
      throw Exception('Gagal mengambil status sale broadcast: $e');
    }
  }

  Future<bool> checkWorkspaceExists(String id) async {
    try {
      final response = await _supabase
          .from('workspaces')
          .select('id')
          .eq('id', id)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteWorkspace(String id) async {
    try {
      await _supabase.from('workspaces').delete().eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus lapak: $e');
    }
  }

  Future<String?> verifyPin(
      {required String workspaceId,
      required String deviceId,
      required String pin}) async {
    try {
      // print('pin: $pin');
      // print('workspaceId: $workspaceId');

      final pinBytes = utf8.encode(pin);
      final hashedPin = sha256.convert(pinBytes).toString();

      final response = await _supabase.rpc('verify_workspace', params: {
        'p_workspace_id': workspaceId,
        'p_device_id': deviceId,
        'p_input_pin': hashedPin
      });

      final data = response as Map<String, dynamic>;

      final status = data['status'] as String;
      final message = data['message'] as String;

      if (status == 'success') {
        return null;
      } else {
        return message;
      }
    } catch (e) {
      throw Exception('Gagal verifikasi pin lapak: $e');
    }
  }

  Future<bool> editPin(String workspaceId, String newPin) async {
    try {
      final pinBytes = utf8.encode(newPin);
      final hashedPin = sha256.convert(pinBytes).toString();

      final response = await _supabase
          .from('workspaces')
          .update({'admin_pin': hashedPin})
          .eq('id', workspaceId)
          .select('id');

      return response.isNotEmpty;
    } catch (e) {
      throw Exception('Gagal ubah pin lapak: $e');
    }
  }

  Future<bool> editWorkspaceName(String workspaceId, String newName) async {
    try {
      final response = await _supabase
          .from('workspaces')
          .update({'name': newName})
          .eq('id', workspaceId)
          .select('id');

      return response.isNotEmpty;
    } catch (e) {
      throw Exception('Gagal ubah nama lapak: $e');
    }
  }

  Future<bool> editWorkspaceAiKeys(
      String workspaceId, List<AiKeys> newAiKeys) async {
    try {
      final aiKeysJson = newAiKeys.map((key) => key.toJson()).toList();

      final response = await _supabase
          .from('workspaces')
          .update({'ai_keys': aiKeysJson})
          .eq('id', workspaceId)
          .select('id');
      return response.isNotEmpty;
    } catch (e) {
      throw Exception('Gagal ubah AI keys lapak: $e');
    }
  }

  Future<void> editIsSaleBroadcastOn(String workspaceId, bool isEnabled) async {
    try {
      await _supabase
          .from('workspaces')
          .update({'is_sale_broadcast_on': isEnabled}).eq('id', workspaceId);
    } catch (e) {
      throw Exception('Gagal mengubah status sale broadcast: $e');
    }
  }

  Future<PaymentConfigModel> getPaymentConfig(String workspaceId) async {
    try {
      final response = await _supabase
          .from('workspaces')
          .select('qris_image_url, transfer_accounts')
          .eq('id', workspaceId)
          .single();
      return PaymentConfigModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal ambil konfigurasi metode pembayaran lapak: $e');
    }
  }

  Future<void> updateTransferAccounts(
      String workspaceId, List<TransferAccountModel> accounts) async {
    await _supabase.from('workspaces').update({
      'transfer_accounts': accounts.map((account) => account.toJson()).toList(),
    }).eq('id', workspaceId);
  }

  Future<String> uploadQrisImage(String workspaceId, Uint8List bytes) async {
    if (_supabase.auth.currentSession == null) {
      throw Exception('Sesi login tidak valid. Silakan login kembali.');
    }

    final path =
        '$workspaceId/qris-${DateTime.now().millisecondsSinceEpoch}.png';
    try {
      await _supabase.storage.from('workspace-qris').uploadBinary(
            path,
            bytes,
            fileOptions:
                const FileOptions(upsert: false, contentType: 'image/png'),
          );
    } catch (e) {
      throw Exception('Gagal upload file QRIS ke Storage: $e');
    }

    try {
      final url = _supabase.storage.from('workspace-qris').getPublicUrl(path);
      await _supabase
          .from('workspaces')
          .update({'qris_image_url': url}).eq('id', workspaceId);
      return url;
    } catch (e) {
      throw Exception(
          'File QRIS berhasil diupload, tetapi gagal menyimpan URL ke workspaces: $e');
    }
  }
}

@Riverpod(keepAlive: true)
WorkspaceRepository workspaceRepository(Ref ref) {
  return WorkspaceRepository(ref.watch(supabaseClientProvider));
}
