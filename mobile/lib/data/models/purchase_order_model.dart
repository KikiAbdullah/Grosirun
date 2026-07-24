import 'dart:convert';

import 'package:equatable/equatable.dart';

/// A purchase order placed by an initiator to a seller/supplier.
class PurchaseOrderModel extends Equatable {
  final int id;
  final String code;
  final int campaignId;
  final String campaignTitle;
  final int initiatorId;
  final String initiatorName;
  final int supplierId;
  final String supplierName;
  final String productName;
  final String unit;
  final int quantity;
  final int unitPrice;
  final int subtotal;
  final int deliveryCost;
  final int totalAmount;
  final String status;
  final String? rejectReason;
  final String? paymentProofUrl;
  final String? invoiceUrl;
  final String? shippingDocUrl;
  final String? trackingNumber;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? paidAt;
  final DateTime? shippedAt;
  final DateTime? completedAt;

  const PurchaseOrderModel({
    required this.id,
    required this.code,
    required this.campaignId,
    required this.campaignTitle,
    required this.initiatorId,
    required this.initiatorName,
    required this.supplierId,
    required this.supplierName,
    required this.productName,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.deliveryCost,
    required this.totalAmount,
    required this.status,
    this.rejectReason,
    this.paymentProofUrl,
    this.invoiceUrl,
    this.shippingDocUrl,
    this.trackingNumber,
    required this.createdAt,
    this.acceptedAt,
    this.paidAt,
    this.shippedAt,
    this.completedAt,
  });

  bool get isSubmitted => status == POStatus.submitted;
  bool get isAccepted => status == POStatus.accepted;
  bool get isPaid => status == POStatus.paid;
  bool get isProcessing => status == POStatus.processing;
  bool get isShipped => status == POStatus.shipped;
  bool get isCompleted => status == POStatus.completed;
  bool get isRejected => status == POStatus.rejected;
  bool get isCancelled => status == POStatus.cancelled;

  String get statusLabel {
    switch (status) {
      case POStatus.submitted:
        return 'Menunggu Respon';
      case POStatus.accepted:
        return 'Diterima';
      case POStatus.awaitingPayment:
        return 'Menunggu Bayar';
      case POStatus.paid:
        return 'Sudah Bayar';
      case POStatus.processing:
        return 'Diproses';
      case POStatus.shipped:
        return 'Dikirim';
      case POStatus.completed:
        return 'Selesai';
      case POStatus.rejected:
        return 'Ditolak';
      case POStatus.cancelled:
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  factory PurchaseOrderModel.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderModel(
      id: json['id'] as int,
      code: json['code'] as String? ?? 'PO-${json['id']}',
      campaignId: json['campaign_id'] as int,
      campaignTitle: json['campaign_title'] as String? ?? '',
      initiatorId: json['initiator_id'] as int,
      initiatorName: json['initiator_name'] as String? ?? '',
      supplierId: json['supplier_id'] as int,
      supplierName: json['supplier_name'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      unit: json['unit'] as String? ?? 'kg',
      quantity: json['quantity'] as int,
      unitPrice: json['unit_price'] as int,
      subtotal: json['subtotal'] as int,
      deliveryCost: json['delivery_cost'] as int? ?? 0,
      totalAmount: json['total_amount'] as int,
      status: json['status'] as String? ?? POStatus.submitted,
      rejectReason: json['reject_reason'] as String?,
      paymentProofUrl: json['payment_proof_url'] as String?,
      invoiceUrl: json['invoice_url'] as String?,
      shippingDocUrl: json['shipping_doc_url'] as String?,
      trackingNumber: json['tracking_number'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      shippedAt: json['shipped_at'] != null
          ? DateTime.parse(json['shipped_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'campaign_id': campaignId,
      'campaign_title': campaignTitle,
      'initiator_id': initiatorId,
      'initiator_name': initiatorName,
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'product_name': productName,
      'unit': unit,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'delivery_cost': deliveryCost,
      'total_amount': totalAmount,
      'status': status,
      'reject_reason': rejectReason,
      'payment_proof_url': paymentProofUrl,
      'invoice_url': invoiceUrl,
      'shipping_doc_url': shippingDocUrl,
      'tracking_number': trackingNumber,
      'created_at': createdAt.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'shipped_at': shippedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  @override
  List<Object?> get props => [id, code, status, totalAmount];
}

class POStatus {
  POStatus._();

  static const String submitted = 'submitted';
  static const String accepted = 'accepted';
  static const String awaitingPayment = 'awaiting_payment';
  static const String paid = 'paid';
  static const String processing = 'processing';
  static const String shipped = 'shipped';
  static const String completed = 'completed';
  static const String rejected = 'rejected';
  static const String cancelled = 'cancelled';
}
