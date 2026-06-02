import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/features/subscription/bloc/subscription_event.dart';
import 'package:vitasense/features/subscription/bloc/subscription_state.dart';
import 'package:vitasense/features/subscription/data/subscription_repository.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository _repository;

  SubscriptionBloc({SubscriptionRepository? repository})
      : _repository = repository ?? SubscriptionRepository(),
        super(const SubscriptionInitial()) {
    on<LoadSubscription>(_onLoadSubscription);
    on<SyncSubscription>(_onSyncSubscription);
    on<CancelSubscription>(_onCancelSubscription);
  }

  Future<void> _onLoadSubscription(
    LoadSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    try {
      final subscription = await _repository.getStatus();
      emit(SubscriptionLoaded(subscription));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onSyncSubscription(
    SyncSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    try {
      final subscription = await _repository.syncSubscription();
      emit(SubscriptionLoaded(subscription));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onCancelSubscription(
    CancelSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    try {
      await _repository.cancelSubscription();
      emit(const SubscriptionCancelled());
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }
}
