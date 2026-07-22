import 'dart:convert';

import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int id;
  final String name;
  final String phoneNumber;
  final String? fcmToken;
  final int? clusterId;
  final String? clusterName;
  final List<String> roles;
  final String? activeRole;
  final bool consentGiven;
  final bool tosAccepted;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.fcmToken,
    this.clusterId,
    this.clusterName,
    this.roles = const [],
    this.activeRole,
    this.consentGiven = false,
    this.tosAccepted = false,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String,
      fcmToken: json['fcm_token'] as String?,
      clusterId: json['cluster_id'] as int?,
      clusterName: json['cluster_name'] as String?,
      roles: (json['roles'] as List<dynamic>?)?.cast<String>() ?? const [],
      activeRole: json['active_role'] as String?,
      consentGiven: json['consent_at'] != null,
      tosAccepted: json['tos_accepted_at'] != null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  factory UserModel.fromJsonString(String source) {
    return UserModel.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'fcm_token': fcmToken,
      'cluster_id': clusterId,
      'cluster_name': clusterName,
      'roles': roles,
      'active_role': activeRole,
      'consent_at': consentGiven ? DateTime.now().toIso8601String() : null,
      'tos_accepted_at': tosAccepted ? DateTime.now().toIso8601String() : null,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  UserModel copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? fcmToken,
    int? clusterId,
    String? clusterName,
    List<String>? roles,
    String? activeRole,
    bool? consentGiven,
    bool? tosAccepted,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fcmToken: fcmToken ?? this.fcmToken,
      clusterId: clusterId ?? this.clusterId,
      clusterName: clusterName ?? this.clusterName,
      roles: roles ?? this.roles,
      activeRole: activeRole ?? this.activeRole,
      consentGiven: consentGiven ?? this.consentGiven,
      tosAccepted: tosAccepted ?? this.tosAccepted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phoneNumber,
        fcmToken,
        clusterId,
        clusterName,
        roles,
        activeRole,
        consentGiven,
        tosAccepted,
      ];
}
