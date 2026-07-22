import 'package:equatable/equatable.dart';

/// Order model matching API_SPEC response
class OrderModel extends Equatable {
  final int id;
  final int campaignId;
  final String campaignTitle;
  final int userId;
  final String userName;
  final int variantId;
  final String variantName;
  final int quantity;
  final int totalPrice;
  final String paymentMethod; // 'cash' or 'qris'
  final String paymentStatus;
  final String? proofUrl;
  final String? validationNotes;
  final int? validatedById;
  final DateTime createdAt;
  final DateTime? validatedAt;

  const OrderModel({
    required this.id,
    required this.campaignId,
    required this.campaignTitle,
    required this.userId,
    required this.userName,
    required this.variantId,
    required this.variantName,
    required this.quantity,
    required this.totalPrice,
    required this.paymentMethod,
    required this.paymentStatus,
    this.proofUrl,
    this.validationNotes,
    this.validatedById,
    required this.createdAt,
    this.validatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      campaignId: json['campaign_id'] as int,
      campaignTitle: json['campaign_title'] as String? ?? '',
      userId: json['user_id'] as int,
      userName: json['user_name'] as String? ?? '',
      variantId: json['variant_id'] as int,
      variantName: json['variant_name'] as String? ?? '',
      quantity: json['quantity'] as int,
      totalPrice: json['total_price'] as int,
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      proofUrl: json['proof_url'] as String?,
      validationNotes: json['validation_notes'] as String?,
      validatedById: json['validated_by_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      validatedAt: json['validated_at'] != null
          ? DateTime.parse(json['validated_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, campaignId, userId, paymentStatus];
}
