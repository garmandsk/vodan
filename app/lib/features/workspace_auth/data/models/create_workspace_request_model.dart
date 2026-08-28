class AiKeys {
  AiKeys({required this.provider, required this.key});

  final String provider;
  final String key;

  factory AiKeys.fromJson(Map<String, dynamic> json) {
    return AiKeys(
      provider: json['provider'] as String,
      key: json['key'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'key': key
    };
  }
}

class CreateWorkspaceRequestModel {
  CreateWorkspaceRequestModel({
    required this.name,
    required this.adminPin,
    required this.aiKeys,
  });

  final String name;
  final String adminPin;
  final List<AiKeys> aiKeys;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'admin_pin': adminPin,
      'ai_keys': aiKeys.map((credential) => credential.toJson()).toList(),
    };
  }
}