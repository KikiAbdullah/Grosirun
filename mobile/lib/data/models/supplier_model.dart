import 'package:equatable/equatable.dart';

/// Supplier entity – represents a verified or pending business entity.
class SupplierModel extends Equatable {
  final int id;
  final String name;
  final String? siup;
  final String? npwp;
  final String address;
  final String contactPhone;
  final String contactEmail;
  final String status;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? verifiedAt;

  const SupplierModel({
    required this.id,
    required this.name,
    this.siup,
    this.npwp,
    required this.address,
    required this.contactPhone,
    required this.contactEmail,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    this.verifiedAt,
  });

  bool get isPending => status == SupplierStatus.pendingVerification;
  bool get isVerified => status == SupplierStatus.verified;
  bool get isRejected => status == SupplierStatus.rejected;
  bool get isSuspended => status == SupplierStatus.suspended;

  String get statusLabel {
    switch (status) {
      case SupplierStatus.pendingVerification:
        return 'Menunggu Verifikasi';
      case SupplierStatus.verified:
        return 'Terverifikasi';
      case SupplierStatus.rejected:
        return 'Ditolak';
      case SupplierStatus.suspended:
        return 'Ditangguhkan';
      default:
        return status;
    }
  }

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'] as int,
      name: json['name'] as String,
      siup: json['siup'] as String?,
      npwp: json['npwp'] as String?,
      address: json['address'] as String? ?? '',
      contactPhone: json['contact_phone'] as String? ?? '',
      contactEmail: json['contact_email'] as String? ?? '',
      status: json['status'] as String? ?? SupplierStatus.pendingVerification,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'siup': siup,
        'npwp': npwp,
        'address': address,
        'contact_phone': contactPhone,
        'contact_email': contactEmail,
        'status': status,
        'rejection_reason': rejectionReason,
        'created_at': createdAt.toIso8601String(),
        'verified_at': verifiedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, name, status];
}

class SupplierStatus {
  SupplierStatus._();

  static const String pendingVerification = 'pending_verification';
  static const String verified = 'verified';
  static const String rejected = 'rejected';
  static const String suspended = 'suspended';
}
