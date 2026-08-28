class WorkspaceSessionModel {
  WorkspaceSessionModel({
    required this.id,
    this.name,
    this.isSaleBroadcastOn = true,
  });

  final String id;
  final String? name;
  final bool isSaleBroadcastOn;

  WorkspaceSessionModel copyWith({
    String? id,
    String? name,
    bool? isSaleBroadcastOn
  }) {
    return WorkspaceSessionModel(
      id: id ?? this.id, 
      name: name ?? this.name,
      isSaleBroadcastOn: isSaleBroadcastOn ?? this.isSaleBroadcastOn
    );
  }
}