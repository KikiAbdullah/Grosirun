part of 'seller_cubit.dart';

abstract class SellerState extends Equatable {
  const SellerState();

  @override
  List<Object?> get props => [];
}

class SellerInitial extends SellerState {}

class SellerLoading extends SellerState {}

class SellerProductsLoaded extends SellerState {
  final List<SellerProductModel> products;

  const SellerProductsLoaded(this.products);

  @override
  List<Object?> get props => [products.length];
}

class SellerOffersLoaded extends SellerState {
  final List<SupplierOfferModel> offers;

  const SellerOffersLoaded(this.offers);

  @override
  List<Object?> get props => [offers.length];
}

class SellerPurchaseOrdersLoaded extends SellerState {
  final List<PurchaseOrderModel> purchaseOrders;

  const SellerPurchaseOrdersLoaded(this.purchaseOrders);

  @override
  List<Object?> get props => [purchaseOrders.length];
}

class SellerDashboardLoaded extends SellerState {
  final List<PurchaseOrderModel> purchaseOrders;
  final List<SellerProductModel> products;
  final List<SupplierOfferModel> offers;
  final int totalPO;
  final int activeOffers;
  final double fulfillmentRate;

  const SellerDashboardLoaded({
    required this.purchaseOrders,
    required this.products,
    required this.offers,
    required this.totalPO,
    required this.activeOffers,
    required this.fulfillmentRate,
  });

  @override
  List<Object?> get props => [totalPO, activeOffers, fulfillmentRate];
}

class SellerActionSuccess extends SellerState {
  final String message;

  const SellerActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class SellerError extends SellerState {
  final String message;

  const SellerError(this.message);

  @override
  List<Object?> get props => [message];
}
