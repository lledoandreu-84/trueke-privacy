class ProductModel {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;

  ProductModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
    this.latitude,
    this.longitude,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawLat = json['latitude'];
    final rawLng = json['longitude'];
    return ProductModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      latitude: rawLat is num ? rawLat.toDouble() : null,
      longitude: rawLng is num ? rawLng.toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
