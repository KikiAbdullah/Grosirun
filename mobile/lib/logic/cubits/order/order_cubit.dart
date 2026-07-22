import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

// ─── States ───

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<OrderModel> orders;
  final bool hasMore;
  final int page;

  const OrderLoaded({
    required this.orders,
    this.hasMore = false,
    this.page = 1,
  });

  @override
  List<Object?> get props => [orders.length, hasMore, page];
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderCreated extends OrderState {
  final OrderModel order;

  const OrderCreated(this.order);

  @override
  List<Object?> get props => [order.id];
}

class OrderValidated extends OrderState {
  final String message;

  const OrderValidated(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── Cubit ───

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _repository;

  OrderCubit(this._repository) : super(OrderInitial());

  Future<void> loadOrders({int page = 1, int limit = 20}) async {
    try {
      emit(OrderLoading());
      final orders = await _repository.getOrders(page: page, limit: limit);
      emit(OrderLoaded(
        orders: orders,
        hasMore: orders.length >= limit,
        page: page,
      ));
    } catch (e) {
      emit(OrderError('Gagal memuat pesanan: $e'));
    }
  }

  Future<void> refreshOrders() async {
    await loadOrders(page: 1);
  }

  Future<void> loadMoreOrders() async {
    final currentState = state;
    if (currentState is OrderLoaded && currentState.hasMore) {
      try {
        emit(OrderLoading());
        final moreOrders = await _repository.getOrders(
          page: currentState.page + 1,
        );
        emit(OrderLoaded(
          orders: [...currentState.orders, ...moreOrders],
          hasMore: moreOrders.length >= 20,
          page: currentState.page + 1,
        ));
      } catch (e) {
        emit(OrderError('Gagal memuat pesanan tambahan: $e'));
      }
    }
  }

  Future<void> createOrder({
    required int campaignId,
    required int variantId,
    required int quantity,
    required String paymentMethod,
    required int totalPrice,
    required String variantName,
    required String campaignTitle,
  }) async {
    try {
      emit(OrderLoading());
      final order = await _repository.createOrder(
        campaignId: campaignId,
        variantId: variantId,
        quantity: quantity,
        paymentMethod: paymentMethod,
        totalPrice: totalPrice,
        variantName: variantName,
        campaignTitle: campaignTitle,
      );
      emit(OrderCreated(order));
      // Reload orders after creation
      await loadOrders();
    } catch (e) {
      emit(OrderError('Gagal membuat pesanan: $e'));
    }
  }

  Future<void> uploadPaymentProof({
    required int orderId,
    required String filePath,
  }) async {
    try {
      emit(OrderLoading());
      await _repository.uploadPaymentProof(orderId: orderId, filePath: filePath);
      emit(const OrderValidated('Bukti pembayaran berhasil diupload'));
      await loadOrders();
    } catch (e) {
      emit(OrderError('Gagal upload bukti: $e'));
    }
  }

  Future<void> validateOrder({
    required int orderId,
    required bool isValid,
    String? reason,
  }) async {
    try {
      emit(OrderLoading());
      await _repository.validateOrder(
        orderId: orderId,
        isValid: isValid,
        reason: reason,
      );
      emit(OrderValidated(
        isValid ? 'Pesanan divalidasi ✅' : 'Pesanan ditolak ❌',
      ));
      await loadOrders();
    } catch (e) {
      emit(OrderError('Gagal validasi pesanan: $e'));
    }
  }

  Future<void> cancelOrder(int orderId) async {
    try {
      emit(OrderLoading());
      await _repository.cancelOrder(orderId);
      emit(const OrderValidated('Pesanan dibatalkan'));
      await loadOrders();
    } catch (e) {
      emit(OrderError('Gagal membatalkan pesanan: $e'));
    }
  }

  Future<void> markAsDelivered(int orderId) async {
    try {
      emit(OrderLoading());
      await _repository.markAsDelivered(orderId);
      emit(const OrderValidated('Pesanan ditandai sebagai diterima ✅'));
      await loadOrders();
    } catch (e) {
      emit(OrderError('Gagal menandai pesanan: $e'));
    }
  }
}
