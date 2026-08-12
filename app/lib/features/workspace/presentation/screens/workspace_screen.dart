import 'package:flutter/material.dart';
import 'package:vodan/core/presentation/widgets/vodan_scaffold.dart';

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({
    super.key,
    required this.workspaceId
  });

  final String workspaceId;

  @override
  Widget build(BuildContext context) {
    return VodanScaffold(
      title: 'Workspace',
      body: Text('Workspace-ID: $workspaceId')
    );
  }
}