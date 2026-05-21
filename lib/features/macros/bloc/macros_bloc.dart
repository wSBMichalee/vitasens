import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/features/macros/bloc/macros_event.dart';
import 'package:vitasense/features/macros/bloc/macros_state.dart';
import 'package:vitasense/features/macros/data/macros_repository.dart';

class MacrosBloc extends Bloc<MacrosEvent, MacrosState> {
  final MacrosRepository repository;

  Map<String, dynamic> _daily = {};
  List<Map<String, dynamic>> _weekly = [];
  List<Map<String, dynamic>> _meals = [];

  MacrosBloc({required this.repository}) : super(const MacrosInitial()) {
    on<LoadDailyMacros>(_onLoadDailyMacros);
    on<LoadWeeklyMacros>(_onLoadWeeklyMacros);
  }

  Future<void> _onLoadDailyMacros(
    LoadDailyMacros event,
    Emitter<MacrosState> emit,
  ) async {
    emit(const MacrosLoading());
    try {
      final daily = await repository.getDailyMacros(event.date);
      final meals = await repository.getTodayMeals();
      _daily = daily;
      _meals = meals;

      final streakDays = (daily['streakDays'] as int?) ?? 0;

      emit(MacrosLoaded(
        daily: _daily,
        weekly: _weekly,
        meals: _meals,
        streakDays: streakDays,
      ));
    } catch (e) {
      emit(MacrosError(e.toString()));
    }
  }

  Future<void> _onLoadWeeklyMacros(
    LoadWeeklyMacros event,
    Emitter<MacrosState> emit,
  ) async {
    try {
      final weekly = await repository.getWeeklyMacros(
        event.startDate,
        event.endDate,
      );

      _weekly = weekly['days'] != null
          ? (weekly['days'] as List<dynamic>)
              .map((e) => e as Map<String, dynamic>)
              .toList()
          : [];

      if (state is MacrosLoaded) {
        final current = state as MacrosLoaded;
        emit(MacrosLoaded(
          daily: current.daily,
          weekly: _weekly,
          meals: current.meals,
          streakDays: current.streakDays,
        ));
      }
    } catch (e) {
      // Weekly load failure is non-critical — don't overwrite existing state
    }
  }
}
