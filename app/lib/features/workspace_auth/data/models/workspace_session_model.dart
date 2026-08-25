class WorkspaceSessionModel {
  WorkspaceSessionModel({
    required this.id,
    this.name
  });

  final String id;
  final String? name;

  WorkspaceSessionModel copyWith({
    String? id,
    String? name
  }) {
    return WorkspaceSessionModel(
      id: id ?? this.id, 
      name: name ?? this.name
    );
  }
}