import 'package:flutter/foundation.dart';

enum TransactionStatus {
  pending, // Oferta propuesta, esperando respuesta del vendedor
  accepted, // Oferta aceptada, trato en proceso de encuentro o envío
  completed, // Trato finalizado con éxito (aquí se habilita la reseña)
  cancelled, // Trato cancelado por alguna de las partes
}

@immutable
class ProductTransaction {
  final String id;
  final String productId;
  final String productTitle;
  final String sellerId;
  final String sellerName;
  final String buyerId;
  final String buyerName;
  final double? price; // null si es un trueque puro
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductTransaction({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.sellerId,
    required this.sellerName,
    required this.buyerId,
    required this.buyerName,
    this.price,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  ProductTransaction copyWith({
    String? id,
    String? productId,
    String? productTitle,
    String? sellerId,
    String? sellerName,
    String? buyerId,
    String? buyerName,
    double? price,
    TransactionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductTransaction(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productTitle: productTitle ?? this.productTitle,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      price: price ?? this.price,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_title': productTitle,
      'seller_id': sellerId,
      'seller_name': sellerName,
      'buyer_id': buyerId,
      'buyer_name': buyerName,
      'price': price,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ProductTransaction.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'pending';
    final currentStatus = TransactionStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => TransactionStatus.pending,
    );

    return ProductTransaction(
      id: json['id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      productTitle: json['product_title'] as String? ?? '',
      sellerId: json['seller_id'] as String? ?? '',
      sellerName: json['seller_name'] as String? ?? 'Vendedor',
      buyerId: json['buyer_id'] as String? ?? '',
      buyerName: json['buyer_name'] as String? ?? 'Comprador',
      price: (json['price'] as num?)?.toDouble(),
      status: currentStatus,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}
