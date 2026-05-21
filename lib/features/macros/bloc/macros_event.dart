import 'package:equatable/equatable.dart';

abstract class MacrosEvent extends Equatable {
  const MacrosEvent();

  @override
  List<Object?> get props => [];
}

class LoadDailyMacros extends MacrosEvent {
  final String date;

  const LoadDailyMacros(this.date);

  @override
  List<Object?> get props => [date];
}

class LoadWeeklyMacros extends MacrosEvent {
  final String startDate;
  final String endDate;

  const LoadWeeklyMacros(this.startDate, this.endDate);

  @override
  List<Object?> get props => [startDate, endDate];
}
