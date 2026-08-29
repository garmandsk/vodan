import 'package:flutter_test/flutter_test.dart';
import 'package:vodan/features/workspace/data/models/ticket_model.dart';
import 'package:vodan/features/workspace/data/repositories/workspace_repository.dart';

void main() {
  group('WorkspaceRepository ticket helper', () {
    test('generateShiftPassCode creates 8-char uppercase alphanumeric code',
        () {
      final code = WorkspaceRepository.generateShiftPassCode();

      expect(code.length, 8);
      expect(code, matches(RegExp(r'^[A-Z0-9]{8}$')));
    });

    test('TicketModel parses ISO timestamp from database into DateTime', () {
      final ticket = TicketModel.fromJson({
        'pass_code': 'ABC12345',
        'expires_at': '2026-08-29T10:00:00.000Z',
      });

      expect(ticket.passCode, 'ABC12345');
      expect(ticket.expiresAt, isA<DateTime>());
      expect(ticket.expiresAt.toIso8601String(), '2026-08-29T10:00:00.000Z');
    });
  });
}
