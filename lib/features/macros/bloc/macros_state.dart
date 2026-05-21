import 'package:equatable/equatable.dart';

abstract class MacrosState extends Equatable {
  const MacrosState();

  @override
  List<Object?> get props => [];
}

class MacrosInitial extends MacrosState {
  const MacrosInitial();
}

class MacrosLoading extends MacrosState {
  const MacrosLoading();
}

class MacrosLoaded extends MacrosState {
  final Map<String, dynamic> daily;
  final List<Map<String, dynamic>> weekly;
  final List<Map<String, dynamic>> meals;
  final int streakDays;

  const MacrosLoaded({
    required this.daily,
    required this.weekly,
    required this.meals,
    required this.streakDays,
  });

  @override
  List<Object?> get props => [daily, weekly, meals, streakDays];
}

class MacrosError extends MacrosState {
  final String message;

  const MacrosError(this.message);

  @override
  List<Object?> get props => [message];
}
