import 'package:equatable/equatable.dart';

/// A supplier's offer to supply products at tiered prices.
class SupplierOfferModel extends Equatable {
  final int id;
  final int supplierId;
  final String supplierName;
  final String productName;
  final String unit;
  final int minimumOrder;
  final int capacity;
  final List<PriceTier> tiers;
  final List<String> serviceAreas;
  final int deliveryCost;
  final DateTime validUntil;
  final String status;
  final String? moderationNote;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;

  const SupplierOfferModel({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.productName,
    required this.unit,
    required this.minimumOrder,
    required this.capacity,
    required this.tiers,
    required this.serviceAreas,
    required this.deliveryCost,
    required this.validUntil,
    required this.status,
    this.moderationNote,
    this.description,
    this.imageUrl,
    required this.createdAt,
  });

  bool get isDraft => status == OfferStatus.draft;
  bool get isPendingModeration => status == OfferStatus.pendingModeration;
  bool get isActive => status == OfferStatus.active;
  bool get isExpired => status == OfferStatus.expired;
  bool get isRejected => status == OfferStatus.rejected;

  String get statusLabel {
    switch (status) {
      case OfferStatus.draft:
        return 'Draft';
      case OfferStatus.pendingModeration:
        return 'Menunggu Moderasi';
      case OfferStatus.active:
        return 'Aktif';
      case OfferStatus.expired:
        return 'Kadaluarsa';
      case OfferStatus.rejected:
        return 'Ditolak';
      default:
        return status;
    }
  }

  factory SupplierOfferModel.fromJson(Map<String, dynamic> json) {
    return SupplierOfferModel(
      id: json['id'] as int,
      supplierId: json['supplier_id'] as int,
      supplierName: json['supplier_name'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      unit: json['unit'] as String? ?? 'kg',
      minimumOrder: json['minimum_order'] as int,
      capacity: json['capacity'] as int,
      tiers: (json['tiers'] as List<dynamic>?)
              ?.map((t) => PriceTier.fromJson(t as Map<String, dynamic>))
              .toList() ??
          const [],
      serviceAreas: (json['service_areas'] as List<dynamic>?)
              ?.map((a) => a.toString())
              .toList() ??
          const [],
      deliveryCost: json['delivery_cost'] as int? ?? 0,
      validUntil: DateTime.parse(json['valid_until'] as String),
      status: json['status'] as String? ?? OfferStatus.draft,
      moderationNote: json['moderation_note'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'supplier_id': supplierId,
        'supplier_name': supplierName,
        'product_name': productName,
        'unit': unit,
        'minimum_order': minimumOrder,
        'capacity': capacity,
        'tiers': tiers.map((t) => t.toJson()).toList(),
        'service_areas': serviceAreas,
        'delivery_cost': deliveryCost,
        'valid_until': validUntil.toIso8601String(),
        'status': status,
        'moderation_note': moderationNote,
        'description': description,
        'image_url': imageUrl,
        'created_at': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, supplierId, status, productName];
}

/// Price tier for an offer.
class PriceTier extends Equatable {
  final int minQuantity;
  final int maxQuantity;
  final int unitPrice;

  const PriceTier({
    required this.minQuantity,
    required this.maxQuantity,
    required this.unitPrice,
  });

  factory PriceTier.fromJson(Map<String, dynamic> json) {
    return PriceTier(
      minQuantity: json['min_quantity'] as int,
      maxQuantity: json['max_quantity'] as int? ?? 0,
      unitPrice: json['unit_price'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'min_quantity': minQuantity,
        'max_quantity': maxQuantity,
        'unit_price': unitPrice,
      };

  @override
  List<Object?> get props => [minQuantity, maxQuantity, unitPrice];
}

class OfferStatus {
  OfferStatus._();

  static const String draft = 'draft';
  static const String pendingModeration = 'pending_moderation';
  static const String active = 'active';
  static const String expired = 'expired';
  static const String rejected = 'rejected';
}
