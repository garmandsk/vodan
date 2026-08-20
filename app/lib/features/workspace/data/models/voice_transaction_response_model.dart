enum Intent {
  transaction,
  chat;

  static Intent fromString(String? value) {
    if (value == 'transaction') return Intent.transaction;
    return Intent.chat; 
  }
}

class VoiceOrderItem {
  final String id;
  final String name;
  final num price;
  final int qty;
  final num subTotal;

  VoiceOrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.qty,
    required this.subTotal,
  });

  factory VoiceOrderItem.fromJson(Map<String, dynamic> json) {
    return VoiceOrderItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: json['price'] as num? ?? 0,
      qty: json['qty'] as int? ?? 0,
      subTotal: json['subTotal'] as num? ?? 0,
    );
  }
}

class TtsConfig {
  final String languageCode;
  final double pitch;
  final double rate;

  TtsConfig({
    required this.languageCode,
    required this.pitch,
    required this.rate,
  });

  factory TtsConfig.fromJson(Map<String, dynamic> json) {
    return TtsConfig(
      languageCode: json['language_code']?.toString() ?? 'id-ID',
      pitch: (json['pitch'] as num?)?.toDouble() ?? 1.0, 
      rate: (json['rate'] as num?)?.toDouble() ?? 0.5,
    );
  }
}

class VoiceTransactionResponseModel {
  final Intent intent;
  final List<VoiceOrderItem> orders;
  final String voiceResponse;
  final String fallbackResponse;
  final TtsConfig ttsConfig;
  final num totalPrice;
  final bool isStockAdjusted;

  VoiceTransactionResponseModel({
    required this.intent,
    required this.orders,
    required this.voiceResponse,
    required this.fallbackResponse,
    required this.ttsConfig,
    required this.totalPrice,
    required this.isStockAdjusted,
  });

  factory VoiceTransactionResponseModel.fromJson(Map<String, dynamic> json) {
    return VoiceTransactionResponseModel(
      intent: Intent.fromString(json['intent'] as String?),
      
      orders: (json['orders'] as List<dynamic>?)
              ?.map((e) => VoiceOrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
          
      voiceResponse: json['voice_response']?.toString() ?? '',
      fallbackResponse: json['fallback_response']?.toString() ?? '',
      
      ttsConfig: json['tts_config'] != null 
          ? TtsConfig.fromJson(json['tts_config'] as Map<String, dynamic>)
          : TtsConfig(languageCode: 'id-ID', pitch: 1.0, rate: 0.5),
          
      totalPrice: json['total_price'] as num? ?? 0,
      isStockAdjusted: json['is_stock_adjusted'] as bool? ?? false,
    );
  }
}