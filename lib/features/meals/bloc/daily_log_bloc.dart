import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/meals_repository.dart';
import 'daily_log_event.dart';
import 'daily_log_state.dart';

class DailyLogBloc extends Bloc<DailyLogEvent, DailyLogState> {
  DailyLogBloc() : super(const DailyLogInitial()) {
    on<LoadDailyLog>(_onLoad);
    on<DeleteMeal>(_onDelete);
  }

  final _repo = MealsRepository();

  Future<void> _onLoad(LoadDailyLog event, Emitter<DailyLogState> emit) async {
    emit(const DailyLogLoading());
    try {
      final meals = await _repo.getMealsForDate(event.date);
      emit(DailyLogLoaded(meals));
    } catch (e) {
      emit(DailyLogError(e.toString()));
    }
  }

  Future<void> _onDelete(DeleteMeal event, Emitter<DailyLogState> emit) async {
    try {
      await _repo.deleteMeal(event.mealId);
      add(LoadDailyLog(event.date));
    } catch (_) {}
  }
}
