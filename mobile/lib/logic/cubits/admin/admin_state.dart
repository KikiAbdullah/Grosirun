part of 'admin_cubit.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminDashboardLoaded extends AdminState {
  final Map<String, dynamic> metrics;
  final int openDisputes;

  const AdminDashboardLoaded({
    required this.metrics,
    required this.openDisputes,
  });

  @override
  List<Object?> get props => [metrics, openDisputes];
}

class AdminSuppliersLoaded extends AdminState {
  final List<SupplierModel> suppliers;

  const AdminSuppliersLoaded(this.suppliers);

  @override
  List<Object?> get props => [suppliers.length];
}

class AdminOffersLoaded extends AdminState {
  final List<SupplierOfferModel> offers;

  const AdminOffersLoaded(this.offers);

  @override
  List<Object?> get props => [offers.length];
}

class AdminUsersLoaded extends AdminState {
  final List<UserModel> users;

  const AdminUsersLoaded(this.users);

  @override
  List<Object?> get props => [users.length];
}

class AdminDisputesLoaded extends AdminState {
  final List<DisputeModel> disputes;

  const AdminDisputesLoaded(this.disputes);

  @override
  List<Object?> get props => [disputes.length];
}

class AdminAuditLogsLoaded extends AdminState {
  final List<AuditLogModel> logs;

  const AdminAuditLogsLoaded(this.logs);

  @override
  List<Object?> get props => [logs.length];
}

class AdminActionSuccess extends AdminState {
  final String message;

  const AdminActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}
