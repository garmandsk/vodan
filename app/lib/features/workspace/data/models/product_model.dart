class ProductModel {
  ProductModel({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.category,
    required this.nlpAlias,
    required this.price,
    required this.currency,
    required this.stock,
    required this.sold,
    required this.isActive,
  });

  final String id;
  final String workspaceId;
  final String name;
  final String category;
  final List<String> nlpAlias;
  final double price;
  final String currency;
  final int stock;
  final int sold;
  final bool isActive;

  ProductModel copyWith({
    String? name,
    String? category,
    List<String>? nlpAlias,
    double? price,
    String? currency,
    int? stock,
    int? sold,
    bool? isActive
  }) {
    return ProductModel(
      id: id,
      workspaceId: workspaceId,
      name: name ?? this.name,
      category: category ?? this.category,
      nlpAlias: nlpAlias ?? this.nlpAlias,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      stock: stock ?? this.stock,
      sold: sold ?? this.sold,
      isActive: isActive ?? this.isActive
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),
      workspaceId: json['workspace_id'].toString(),
      name: json['name'].toString(),
      category: json['category'].toString(),
      nlpAlias: List<String>.from(json['nlp_alias'] ?? []),
      price: (json['price'] ?? 0).toDouble(),
      currency: (json['currency'] as String),
      stock: json['stock'] ?? 0,
      sold: json['sold'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workspace_id': workspaceId,
      'name': name,
      'category': category,
      'nlp_alias': nlpAlias,
      'price': price,
      'stock': stock,
      'sold': sold,
      'is_active': isActive
    };
  }
}