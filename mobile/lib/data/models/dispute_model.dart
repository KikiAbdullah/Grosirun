import 'package:equatable/equatable.dart';

/// A dispute between an initiator and seller over fulfillment.
class DisputeModel extends Equatable {
  final int id;
  final int purchaseOrderId;
  final String purchaseOrderCode;
  final int initiatorId;
  final String initiatorName;
  final int supplierId;
  final String supplierName;
  final String disputeType;
  final String description;
  final List<String> evidenceUrls;
  final String status;
  final String? resolution;
  final String? resolutionNotes;
  final int? refundAmount;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const DisputeModel({
    required this.id,
    required this.purchaseOrderId,
    required this.purchaseOrderCode,
    required this.initiatorId,
    required this.initiatorName,
    required this.supplierId,
    required this.supplierName,
    required this.disputeType,
    required this.description,
    required this.evidenceUrls,
    required this.status,
    this.resolution,
    this.resolutionNotes,
    this.refundAmount,
    required this.createdAt,
    this.resolvedAt,
  });

  bool get isOpen => status == DisputeStatus.open;
  bool get isInReview => status == DisputeStatus.inReview;
  bool get isResolved => status == DisputeStatus.resolved;
  bool get isClosed => status == DisputeStatus.closed;

  String get statusLabel {
    switch (status) {
      case DisputeStatus.open:
        return 'Terbuka';
      case DisputeStatus.inReview:
        return 'Sedang Direview';
      case DisputeStatus.resolved:
        return 'Terselesaikan';
      case DisputeStatus.closed:
        return 'Ditutup';
      default:
        return status;
    }
  }

  factory DisputeModel.fromJson(Map<String, dynamic> json) {
    return DisputeModel(
      id: json['id'] as int,
      purchaseOrderId: json['purchase_order_id'] as int,
      purchaseOrderCode: json['purchase_order_code'] as String? ?? '',
      initiatorId: json['initiator_id'] as int,
      initiatorName: json['initiator_name'] as String? ?? '',
      supplierId: json['supplier_id'] as int,
      supplierName: json['supplier_name'] as String? ?? '',
      disputeType: json['dispute_type'] as String? ?? 'fulfillment',
      description: json['description'] as String? ?? '',
      evidenceUrls: (json['evidence_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      status: json['status'] as String? ?? DisputeStatus.open,
      resolution: json['resolution'] as String?,
      resolutionNotes: json['resolution_notes'] as String?,
      refundAmount: json['refund_amount'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'purchase_order_id': purchaseOrderId,
        'purchase_order_code': purchaseOrderCode,
        'initiator_id': initiatorId,
        'initiator_name': initiatorName,
        'supplier_id': supplierId,
        'supplier_name': supplierName,
        'dispute_type': disputeType,
        'description': description,
        'evidence_urls': evidenceUrls,
        'status': status,
        'resolution': resolution,
        'resolution_notes': resolutionNotes,
        'refund_amount': refundAmount,
        'created_at': createdAt.toIso8601String(),
        'resolved_at': resolvedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, purchaseOrderId, status];
}

class DisputeStatus {
  DisputeStatus._();

  static const String open = 'open';
  static const String inReview = 'in_review';
  static const String resolved = 'resolved';
  static const String closed = 'closed';
}

class DisputeResolution {
  DisputeResolution._();

  static const String replacement = 'replacement';
  static const String refund = 'refund';
  static const String none = 'none';
}
