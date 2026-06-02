import 'package:equatable/equatable.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubscription extends SubscriptionEvent {
  const LoadSubscription();
}

class SyncSubscription extends SubscriptionEvent {
  const SyncSubscription();
}

class CancelSubscription extends SubscriptionEvent {
  const CancelSubscription();
}
