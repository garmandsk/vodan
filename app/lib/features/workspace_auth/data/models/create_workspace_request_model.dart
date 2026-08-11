class AiCredential {
  AiCredential({required this.provider, required this.key});

  final String provider;
  final String key;

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
  final List<AiCredential> aiKeys;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'admin_pin': adminPin,
      'ai_keys': aiKeys.map((credential) => credential.toJson()).toList(),
    };
  }
}