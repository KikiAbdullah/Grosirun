import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

import '../../core/constants/app_constants.dart';
import '../datasources/remote/mock_data.dart';
import '../models/campaign_model.dart';

class CampaignRepository {
  final Logger _logger = GetIt.I<Logger>();

  CampaignRepository();

  Box get _campaignBox => Hive.box(AppConstants.boxCampaigns);

  Future<List<CampaignModel>> getCampaigns({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 350));
      final campaigns = MockData.campaigns.where((campaign) {
        if (status == null) {
          return true;
        }
        return campaign.status == status;
      }).toList();

      await _campaignBox.put(
        'campaign_list',
        campaigns.map((campaign) => campaign.toJson()).toList(),
      );

      _logger.i('Campaign cache refreshed: ${campaigns.length} items');
      return campaigns;
    } catch (error) {
      _logger.w('Campaign remote failed, using cache: $error');
      final cached = _campaignBox.get('campaign_list') as List<dynamic>?;
      if (cached == null) {
        rethrow;
      }
      return cached
          .whereType<Map>()
          .map((json) => CampaignModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }
  }

  Future<CampaignModel> getCampaignDetail(int id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 250));
      final campaign = MockData.campaigns.firstWhere((item) => item.id == id);
      await _campaignBox.put('campaign_$id', campaign.toJson());
      return campaign;
    } catch (error) {
      final cached = _campaignBox.get('campaign_$id');
      if (cached is Map) {
        return CampaignModel.fromJson(Map<String, dynamic>.from(cached));
      }
      rethrow;
    }
  }

  Future<CampaignModel> createCampaign({
    required String title,
    required String description,
    required int productId,
    required int targetQuantity,
    required int deadlineDays,
    required String unit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final created = MockData.campaigns.first.copyWith(
      title: title,
      description: description,
      targetQuantity: targetQuantity,
      unit: unit,
    );
    return created;
  }

  Future<void> updateCampaign(int id, Map<String, dynamic> data) async {
    _logger.i('Campaign updated: $id');
  }

  Future<void> cancelCampaign(int id) async {
    _logger.i('Campaign cancelled: $id');
  }

  Future<void> completeCampaign(int id) async {
    _logger.i('Campaign completed: $id');
  }
}

extension CampaignCopy on CampaignModel {
  CampaignModel copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    int? clusterId,
    String? clusterName,
    int? initiatorId,
    String? initiatorName,
    String? unit,
    int? targetQuantity,
    int? currentQuantity,
    int? buyerUnitPrice,
    int? supplierUnitPrice,
    DateTime? deadline,
    String? imageUrl,
    String? locationDistribution,
    List<CampaignVariantModel>? variants,
    DateTime? createdAt,
    DateTime? distributionCompletedAt,
  }) {
    return CampaignModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      clusterId: clusterId ?? this.clusterId,
      clusterName: clusterName ?? this.clusterName,
      initiatorId: initiatorId ?? this.initiatorId,
      initiatorName: initiatorName ?? this.initiatorName,
      unit: unit ?? this.unit,
      targetQuantity: targetQuantity ?? this.targetQuantity,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      buyerUnitPrice: buyerUnitPrice ?? this.buyerUnitPrice,
      supplierUnitPrice: supplierUnitPrice ?? this.supplierUnitPrice,
      deadline: deadline ?? this.deadline,
      imageUrl: imageUrl ?? this.imageUrl,
      locationDistribution: locationDistribution ?? this.locationDistribution,
      variants: variants ?? this.variants,
      createdAt: createdAt ?? this.createdAt,
      distributionCompletedAt: distributionCompletedAt ?? this.distributionCompletedAt,
    );
  }
}
