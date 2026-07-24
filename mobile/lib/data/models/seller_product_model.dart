import 'package:equatable/equatable.dart';

/// A seller's product listing.
class SellerProductModel extends Equatable {
  final int id;
  final int supplierId;
  final String name;
  final String baseUnit;
  final String? description;
  final String? imageUrl;
  final List<ProductVariantModel> variants;
  final DateTime createdAt;

  const SellerProductModel({
    required this.id,
    required this.supplierId,
    required this.name,
    required this.baseUnit,
    this.description,
    this.imageUrl,
    this.variants = const [],
    required this.createdAt,
  });

  factory SellerProductModel.fromJson(Map<String, dynamic> json) {
    return SellerProductModel(
      id: json['id'] as int,
      supplierId: json['supplier_id'] as int,
      name: json['name'] as String,
      baseUnit: json['base_unit'] as String? ?? 'kg',
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      variants: (json['variants'] as List<dynamic>?)
              ?.map((v) => ProductVariantModel.fromJson(v as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'supplier_id': supplierId,
        'name': name,
        'base_unit': baseUnit,
        'description': description,
        'image_url': imageUrl,
        'variants': variants.map((v) => v.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, name, baseUnit];
}

/// A packaging variant of a product.
class ProductVariantModel extends Equatable {
  final int id;
  final int productId;
  final String name;
  final int packageQuantity;
  final int? stockQuantity;

  const ProductVariantModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.packageQuantity,
    this.stockQuantity,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      name: json['name'] as String,
      packageQuantity: json['package_quantity'] as int,
      stockQuantity: json['stock_quantity'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'name': name,
        'package_quantity': packageQuantity,
        'stock_quantity': stockQuantity,
      };

  @override
  List<Object?> get props => [id, productId, name, packageQuantity];
}

/// Audit log entry for admin actions.
class AuditLogModel extends Equatable {
  final int id;
  final String action;
  final String targetType;
  final int? targetId;
  final int userId;
  final String userName;
  final String? description;
  final Map<String, dynamic>? metadata;
  final String? ticketId;
  final DateTime createdAt;

  const AuditLogModel({
    required this.id,
    required this.action,
    required this.targetType,
    this.targetId,
    required this.userId,
    required this.userName,
    this.description,
    this.metadata,
    this.ticketId,
    required this.createdAt,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] as int,
      action: json['action'] as String,
      targetType: json['target_type'] as String,
      targetId: json['target_id'] as int?,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String? ?? '',
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      ticketId: json['ticket_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'action': action,
        'target_type': targetType,
        'target_id': targetId,
        'user_id': userId,
        'user_name': userName,
        'description': description,
        'metadata': metadata,
        'ticket_id': ticketId,
        'created_at': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, action, targetId, createdAt];
}
