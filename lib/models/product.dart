enum TradeType { trade, sale, tradeAndMoney }

class Product {
  final String id;
  final String title;
  final String description;
  final double? price;
  final List<String> images;
  final String category;
  final String owner;
  final String ownerId;
  final String condition;
  final TradeType tradeType;
  final String wanted;
  final String location;
  final double? latitude;
  final double? longitude;
  final int viewsCount;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    this.price,
    required this.images,
    required this.category,
    required this.owner,
    required this.ownerId,
    required this.condition,
    required this.tradeType,
    required this.wanted,
    required this.location,
    this.latitude,
    this.longitude,
    this.viewsCount = 0,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      images:
          (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      category: json['category'] as String? ?? '',
      owner: json['owner'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      condition: json['condition'] as String? ?? '',
      tradeType: json['trade_type'] == 'sale'
          ? TradeType.sale
          : json['trade_type'] == 'tradeAndMoney'
          ? TradeType.tradeAndMoney
          : TradeType.trade,
      wanted: json['wanted'] as String? ?? '',
      location: json['location'] as String? ?? '',
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      viewsCount: json['views_count'] as int? ?? json['views'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'image_urls': images,
      'category': category,
      'owner': owner,
      'owner_id': ownerId,
      'condition': condition,
      'trade_type': tradeType.name,
      'wanted': wanted,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'views_count': viewsCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get imageUrl => images.isNotEmpty ? images.first : '';
}
