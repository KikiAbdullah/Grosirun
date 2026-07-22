part of 'campaign_cubit.dart';

abstract class CampaignState extends Equatable {
  const CampaignState();

  @override
  List<Object> get props => [];
}

class CampaignInitial extends CampaignState {}

class CampaignLoading extends CampaignState {}

class CampaignLoaded extends CampaignState {
  final List<CampaignModel> campaigns;

  const CampaignLoaded(this.campaigns);

  @override
  List<Object> get props => [campaigns];
}

class CampaignDetailLoaded extends CampaignState {
  final CampaignModel campaign;

  const CampaignDetailLoaded(this.campaign);

  @override
  List<Object> get props => [campaign];
}

class CampaignCreated extends CampaignState {
  @override
  List<Object> get props => [];
}

class CampaignUpdated extends CampaignState {
  @override
  List<Object> get props => [];
}

class CampaignCancelled extends CampaignState {
  @override
  List<Object> get props => [];
}

class CampaignCompleted extends CampaignState {
  @override
  List<Object> get props => [];
}

class CampaignError extends CampaignState {
  final String message;

  const CampaignError(this.message);

  @override
  List<Object> get props => [message];
}
