import 'package:flutter/foundation.dart';

@immutable
class WalletModel {
  final String id;
  final String userId;
  final double balance; // Saldo líquido disponible para retirar o usar
  final double
  escrowBalance; // Fondos bloqueados en depósito de seguridad por trueques activos
  final String currency;
  final DateTime updatedAt;

  const WalletModel({
    required this.id,
    required this.userId,
    required this.balance,
    required this.escrowBalance,
    this.currency = 'EUR',
    required this.updatedAt,
  });

  // Propiedad calculada para conocer el valor total de activos de la cuenta
  double get totalFunds => balance + escrowBalance;

  WalletModel copyWith({
    String? id,
    String? userId,
    double? balance,
    double? escrowBalance,
    String? currency,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      escrowBalance: escrowBalance ?? this.escrowBalance,
      currency: currency ?? this.currency,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'balance': balance,
      'escrow_balance': escrowBalance,
      'currency': currency,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      escrowBalance: (json['escrow_balance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'EUR',
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}
