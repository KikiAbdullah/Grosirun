import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/campaign_model.dart';
import '../../../data/repositories/repositories.dart';

// ─── States ───

abstract class CampaignListState extends Equatable {
  const CampaignListState();
  @override
  List<Object?> get props => [];
}

class CampaignListInitial extends CampaignListState {}
class CampaignListLoading extends CampaignListState {}

class CampaignListLoaded extends CampaignListState {
  final List<CampaignModel> campaigns;
  const CampaignListLoaded(this.campaigns);
  @override
  List<Object?> get props => [campaigns.length];
}

class CampaignListError extends CampaignListState {
  final String message;
  const CampaignListError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Cubit ───

class CampaignListCubit extends Cubit<CampaignListState> {
  final CampaignRepository _repository;

  CampaignListCubit(this._repository) : super(CampaignListInitial());

  Future<void> loadCampaigns() async {
    emit(CampaignListLoading());
    try {
      final campaigns = await _repository.getActiveCampaigns();
      emit(CampaignListLoaded(campaigns));
    } catch (e) {
      emit(const CampaignListError('Gagal memuat campaign. Cek koneksi internet.'));
    }
  }

  Future<void> refresh() async {
    await loadCampaigns();
  }
}

// ─── Campaign Detail States ───

abstract class CampaignDetailState extends Equatable {
  const CampaignDetailState();
  @override
  List<Object?> get props => [];
}

class CampaignDetailInitial extends CampaignDetailState {}
class CampaignDetailLoading extends CampaignDetailState {}

class CampaignDetailLoaded extends CampaignDetailState {
  final CampaignModel campaign;
  const CampaignDetailLoaded(this.campaign);
  @override
  List<Object?> get props => [campaign.id, campaign.currentQuantity];
}

class CampaignDetailError extends CampaignDetailState {
  final String message;
  const CampaignDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Campaign Detail Cubit ───

class CampaignDetailCubit extends Cubit<CampaignDetailState> {
  final CampaignRepository _repository;

  CampaignDetailCubit(this._repository) : super(CampaignDetailInitial());

  Future<void> loadDetail(int campaignId) async {
    emit(CampaignDetailLoading());
    try {
      final campaign = await _repository.getCampaignDetail(campaignId);
      emit(CampaignDetailLoaded(campaign));
    } catch (e) {
      emit(const CampaignDetailError('Gagal memuat detail campaign.'));
    }
  }

  Future<void> refresh(int campaignId) async {
    await loadDetail(campaignId);
  }
}
