import 'package:equatable/equatable.dart';
import 'package:vitasense/features/subscription/data/models/subscription_model.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial();
}

class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading();
}

class SubscriptionLoaded extends SubscriptionState {
  final SubscriptionModel subscription;

  const SubscriptionLoaded(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}

class SubscriptionCancelled extends SubscriptionState {
  const SubscriptionCancelled();
}
