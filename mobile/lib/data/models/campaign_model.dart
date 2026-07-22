import 'package:equatable/equatable.dart';

/// Campaign model matching API_SPEC response
class CampaignModel extends Equatable {
  final int id;
  final String title;
  final String description;
  final String status;
  final int clusterId;
  final String clusterName;
  final int initiatorId;
  final String initiatorName;
  final String unit;
  final int targetQuantity;
  final int currentQuantity;
  final int buyerUnitPrice;
  final int supplierUnitPrice;
  final DateTime deadline;
  final String? imageUrl;
  final String? locationDistribution;
  final List<CampaignVariantModel> variants;
  final DateTime createdAt;
  final DateTime? distributionCompletedAt;

  const CampaignModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.clusterId,
    required this.clusterName,
    required this.initiatorId,
    required this.initiatorName,
    required this.unit,
    required this.targetQuantity,
    required this.currentQuantity,
    required this.buyerUnitPrice,
    required this.supplierUnitPrice,
    required this.deadline,
    this.imageUrl,
    this.locationDistribution,
    this.variants = const [],
    required this.createdAt,
    this.distributionCompletedAt,
  });

  double get progressPercent =>
      targetQuantity > 0 ? currentQuantity / targetQuantity : 0;

  bool get isTargetReached => currentQuantity >= targetQuantity;

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: json['status'] as String,
      clusterId: json['cluster_id'] as int,
      clusterName: json['cluster_name'] as String? ?? '',
      initiatorId: json['initiator_id'] as int,
      initiatorName: json['initiator_name'] as String? ?? '',
      unit: json['unit'] as String? ?? 'kg',
      targetQuantity: json['target_quantity'] as int,
      currentQuantity: json['current_quantity'] as int? ?? 0,
      buyerUnitPrice: json['buyer_unit_price'] as int,
      supplierUnitPrice: json['supplier_unit_price'] as int? ?? 0,
      deadline: DateTime.parse(json['deadline'] as String),
      imageUrl: json['image_url'] as String?,
      locationDistribution: json['location_distribution'] as String?,
      variants: (json['variants'] as List<dynamic>?)
              ?.map((v) =>
                  CampaignVariantModel.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      distributionCompletedAt: json['distribution_completed_at'] != null
          ? DateTime.parse(json['distribution_completed_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        status,
        targetQuantity,
        currentQuantity,
        deadline,
      ];
}

/// Campaign Variant model
class CampaignVariantModel extends Equatable {
  final int id;
  final String name;
  final int quantityPerVariant;
  final int maxQuantity;
  final int soldQuantity;

  const CampaignVariantModel({
    required this.id,
    required this.name,
    required this.quantityPerVariant,
    required this.maxQuantity,
    this.soldQuantity = 0,
  });

  int get remaining => maxQuantity - soldQuantity;
  bool get isSoldOut => remaining <= 0;

  factory CampaignVariantModel.fromJson(Map<String, dynamic> json) {
    return CampaignVariantModel(
      id: json['id'] as int,
      name: json['name'] as String,
      quantityPerVariant: json['quantity_per_variant'] as int,
      maxQuantity: json['max_quantity'] as int,
      soldQuantity: json['sold_quantity'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, quantityPerVariant, maxQuantity, soldQuantity];
}
