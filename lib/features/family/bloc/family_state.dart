import 'package:equatable/equatable.dart';
import 'package:vitasense/features/family/data/models/family_model.dart';

abstract class FamilyState extends Equatable {
  const FamilyState();

  @override
  List<Object?> get props => [];
}

class FamilyInitial extends FamilyState {
  const FamilyInitial();
}

class FamilyLoading extends FamilyState {
  const FamilyLoading();
}

class FamilyNoGroup extends FamilyState {
  const FamilyNoGroup();
}

class FamilyLoaded extends FamilyState {
  final FamilyModel family;

  const FamilyLoaded(this.family);

  @override
  List<Object?> get props => [family];
}

class FamilyError extends FamilyState {
  final String message;

  const FamilyError(this.message);

  @override
  List<Object?> get props => [message];
}
