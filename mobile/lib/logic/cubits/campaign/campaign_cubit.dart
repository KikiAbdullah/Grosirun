import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:get_it/get_it.dart';
import '../../../data/repositories/campaign_repository.dart';
import '../../../data/models/campaign_model.dart';

part 'campaign_state.dart';

class CampaignCubit extends Cubit<CampaignState> {
  final CampaignRepository _repository;
  final Logger _logger = GetIt.I<Logger>();

  CampaignCubit({required CampaignRepository repository})
      : _repository = repository,
        super(CampaignInitial());

  Future<void> loadCampaigns({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _logger.d('Loading campaigns');
      emit(CampaignLoading());
      
      final campaigns = await _repository.getCampaigns(
        status: status,
        page: page,
        limit: limit,
      );
      
      emit(CampaignLoaded(campaigns));
      _logger.i('Campaigns loaded: ${campaigns.length} items');
    } catch (e) {
      _logger.e('Error loading campaigns: $e');
      emit(CampaignError(e.toString()));
    }
  }

  Future<void> refreshCampaigns() async {
    await loadCampaigns();
  }

  Future<void> loadCampaignDetail(int id) async {
    try {
      _logger.d('Loading campaign detail: $id');
      emit(CampaignLoading());
      
      final campaign = await _repository.getCampaignDetail(id);
      
      emit(CampaignDetailLoaded(campaign));
      _logger.i('Campaign detail loaded: ${campaign.title}');
    } catch (e) {
      _logger.e('Error loading campaign detail: $e');
      emit(CampaignError(e.toString()));
    }
  }

  Future<void> createCampaign({
    required String title,
    required String description,
    required int productId,
    required int targetQuantity,
    required int deadlineDays,
    required String unit,
  }) async {
    try {
      _logger.d('Creating campaign: $title');
      emit(CampaignLoading());
      
      final campaign = await _repository.createCampaign(
        title: title,
        description: description,
        productId: productId,
        targetQuantity: targetQuantity,
        deadlineDays: deadlineDays,
        unit: unit,
      );
      
      emit(CampaignCreated());
      _logger.i('Campaign created: ${campaign.title}');
      
      // Reload campaigns
      await loadCampaigns();
    } catch (e) {
      _logger.e('Error creating campaign: $e');
      emit(CampaignError(e.toString()));
    }
  }

  Future<void> updateCampaign(int id, Map<String, dynamic> data) async {
    try {
      _logger.d('Updating campaign: $id');
      emit(CampaignLoading());
      
      await _repository.updateCampaign(id, data);
      
      emit(CampaignUpdated());
      _logger.i('Campaign updated: $id');
      
      // Reload campaigns
      await loadCampaigns();
    } catch (e) {
      _logger.e('Error updating campaign: $e');
      emit(CampaignError(e.toString()));
    }
  }

  Future<void> cancelCampaign(int id) async {
    try {
      _logger.d('Cancelling campaign: $id');
      emit(CampaignLoading());
      
      await _repository.cancelCampaign(id);
      
      emit(CampaignCancelled());
      _logger.i('Campaign cancelled: $id');
      
      // Reload campaigns
      await loadCampaigns();
    } catch (e) {
      _logger.e('Error cancelling campaign: $e');
      emit(CampaignError(e.toString()));
    }
  }

  Future<void> completeCampaign(int id) async {
    try {
      _logger.d('Completing campaign: $id');
      emit(CampaignLoading());
      
      await _repository.completeCampaign(id);
      
      emit(CampaignCompleted());
      _logger.i('Campaign completed: $id');
      
      // Reload campaigns
      await loadCampaigns();
    } catch (e) {
      _logger.e('Error completing campaign: $e');
      emit(CampaignError(e.toString()));
    }
  }
}
