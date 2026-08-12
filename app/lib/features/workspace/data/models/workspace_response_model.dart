class WorkspaceResponseModel {
  WorkspaceResponseModel({
    required this.id,
    required this.name
  });

  final String id;
  final String name;

  factory WorkspaceResponseModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceResponseModel(
      id: json['id'].toString(),
      name: json['name'].toString()
    );
  }
}