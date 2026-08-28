class AccountResponseModel {
  AccountResponseModel({
    required this.id,
    required this.email,
    this.name,
  });

  final String id;
  final String email;
  final String? name;

  factory AccountResponseModel.fromJson(Map<String, dynamic> json) {
    return AccountResponseModel(
      id: json['id'].toString(),
      email: json['email'].toString(),
      name: json['name'].toString(),
    );
  }
}
