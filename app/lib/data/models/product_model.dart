class ProductModel {
  final String id;
  final String workspaceId;
  final String name;
  final String category;
  final List<String> nlpAlias;
  final int price;
  final int stock;
  final int sold;
  final bool isActive;

  ProductModel({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.category,
    required this.nlpAlias,
    required this.price,
    required this.stock,
    required this.sold,
    required this.isActive,
  });

  ProductModel copyWith({
    String? name,
    String? category,
    List<String>? nlpAlias,
    int? price,
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
      price: (json['price'] ?? 0).toInt(),
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