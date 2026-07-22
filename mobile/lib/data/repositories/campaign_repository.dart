import 'package:logger/logger.dart';
import 'package:get_it/get_it.dart';
import '../models/campaign_model.dart';
import '../datasources/remote/mock_data.dart';
import '../../core/network/dio_client.dart';

class CampaignRepository {
  final DioClient _dioClient;
  final Logger _logger = GetIt.I<Logger>();

  CampaignRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<List<CampaignModel>> getCampaigns({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _logger.d('Fetching campaigns - status: $status, page: $page');
      
      // TODO: Implement real API call
      // final response = await _dioClient.dio.get(
      //   '/campaigns',
      //   queryParameters: {
      //     if (status != null) 'status': status,
      //     'page': page,
      //     'limit': limit,
      //   },
      // );
      // return (response.data['data'] as List)
      //     .map((json) => CampaignModel.fromJson(json))
      //     .toList();

      // Mock response
      await Future.delayed(const Duration(milliseconds: 600));
      final campaigns = MockData.campaigns;
      
      _logger.i('Campaigns fetched: ${campaigns.length} items');
      return campaigns;
    } catch (e) {
      _logger.e('Error fetching campaigns: $e');
      throw Exception('Gagal memuat campaign');
    }
  }

  Future<CampaignModel> getCampaignDetail(int id) async {
    try {
      _logger.d('Fetching campaign detail: $id');
      
      // TODO: Implement real API call
      // final response = await _dioClient.dio.get('/campaigns/$id');
      // return CampaignModel.fromJson(response.data['data']);

      // Mock response
      await Future.delayed(const Duration(milliseconds: 400));
      final campaign = MockData.campaigns.firstWhere((c) => c.id == id);
      
      _logger.i('Campaign detail fetched: ${campaign.title}');
      return campaign;
    } catch (e) {
      _logger.e('Error fetching campaign detail: $e');
      throw Exception('Gagal memuat detail campaign');
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
    try {
      _logger.d('Creating campaign: $title');
      
      // TODO: Implement real API call
      // final response = await _dioClient.dio.post(
      //   '/campaigns',
      //   data: {
      //     'title': title,
      //     'description': description,
      //     'product_id': productId,
      //     'target_quantity': targetQuantity,
      //     'deadline_days': deadlineDays,
      //     'unit': unit,
      //   },
      // );
      // return CampaignModel.fromJson(response.data['data']);

      // Mock response
      await Future.delayed(const Duration(milliseconds: 800));
      final campaign = MockData.campaigns.first;
      
      _logger.i('Campaign created: ${campaign.title}');
      return campaign;
    } catch (e) {
      _logger.e('Error creating campaign: $e');
      throw Exception('Gagal membuat campaign');
    }
  }

  Future<void> updateCampaign(int id, Map<String, dynamic> data) async {
    try {
      _logger.d('Updating campaign: $id');
      
      // TODO: Implement real API call
      // await _dioClient.dio.patch('/campaigns/$id', data: data);

      // Mock response
      await Future.delayed(const Duration(milliseconds: 500));
      
      _logger.i('Campaign updated: $id');
    } catch (e) {
      _logger.e('Error updating campaign: $e');
      throw Exception('Gagal memperbarui campaign');
    }
  }

  Future<void> cancelCampaign(int id) async {
    try {
      _logger.d('Cancelling campaign: $id');
      
      // TODO: Implement real API call
      // await _dioClient.dio.post('/campaigns/$id/cancel');

      // Mock response
      await Future.delayed(const Duration(milliseconds: 500));
      
      _logger.i('Campaign cancelled: $id');
    } catch (e) {
      _logger.e('Error cancelling campaign: $e');
      throw Exception('Gagal membatalkan campaign');
    }
  }

  Future<void> completeCampaign(int id) async {
    try {
      _logger.d('Completing campaign: $id');
      
      // TODO: Implement real API call
      // await _dioClient.dio.post('/campaigns/$id/complete');

      // Mock response
      await Future.delayed(const Duration(milliseconds: 500));
      
      _logger.i('Campaign completed: $id');
    } catch (e) {
      _logger.e('Error completing campaign: $e');
      throw Exception('Gagal menyelesaikan campaign');
    }
  }
}
