class AccountResponseModel {
  AccountResponseModel({
    required this.id,
    required this.email,
    this.displayName,
  });

  final String id;
  final String email;
  final String? displayName;

  factory AccountResponseModel.fromJson(Map<String, dynamic> json) {
    return AccountResponseModel(
      id: json['id'].toString(), 
      email: json['email'].toString(),
      displayName: json['display_name'].toString(),
    );
  } 
}