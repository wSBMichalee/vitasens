import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/meal_suggestion_model.dart';
import '../data/meal_suggestions_repository.dart';

// Events
abstract class MealSuggestionsEvent extends Equatable {
  @override List<Object?> get props => [];
}
class LoadSuggestion extends MealSuggestionsEvent {
  final String mealType;
  final List<String> excludeIds;
  LoadSuggestion(this.mealType, {this.excludeIds = const []});
  @override List<Object?> get props => [mealType, excludeIds];
}

// States
abstract class MealSuggestionsState extends Equatable {
  @override List<Object?> get props => [];
}
class MealSuggestionsInitial extends MealSuggestionsState {}
class MealSuggestionsLoading extends MealSuggestionsState {}
class MealSuggestionsLoaded extends MealSuggestionsState {
  final MealSuggestionModel suggestion;
  final List<String> shownIds;
  MealSuggestionsLoaded({required this.suggestion, required this.shownIds});
  @override List<Object?> get props => [suggestion, shownIds];
}
class MealSuggestionsError extends MealSuggestionsState {
  final String message;
  MealSuggestionsError(this.message);
  @override List<Object?> get props => [message];
}

// BLoC
class MealSuggestionsBloc extends Bloc<MealSuggestionsEvent, MealSuggestionsState> {
  final MealSuggestionsRepository repository;
  final List<String> _shownIds = [];

  static final Map<String, MealSuggestionModel> _cache = {};
  static final Set<String> _todayShownIds = {};
  static String _todayDate = '';

  MealSuggestionsBloc({required this.repository}) : super(MealSuggestionsInitial()) {
    on<LoadSuggestion>(_onLoad);
  }

  Future<void> _onLoad(LoadSuggestion event, Emitter<MealSuggestionsState> emit) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (_todayDate != today) {
      _todayDate = today;
      _cache.clear();
      _todayShownIds.clear();
    }

    // Sprawdź cache najpierw
    final cacheKey = '${event.mealType}_$today';
    if (_cache.containsKey(cacheKey)) {
      emit(MealSuggestionsLoaded(suggestion: _cache[cacheKey]!, shownIds: [_cache[cacheKey]!.id]));
      return;
    }

    emit(MealSuggestionsLoading());
    try {
      final suggestions = await repository.getSuggestions(
        mealType: event.mealType,
        excludeIds: [..._shownIds, ..._todayShownIds, ...event.excludeIds],
      );
      if (suggestions.isEmpty) {
        _shownIds.clear();
        final fresh = await repository.getSuggestions(mealType: event.mealType);
        if (fresh.isEmpty) {
          emit(MealSuggestionsError('No suggestions available'));
          return;
        }
        _shownIds.add(fresh.first.id);
        _cache[cacheKey] = fresh.first;
        emit(MealSuggestionsLoaded(suggestion: fresh.first, shownIds: List.from(_shownIds)));
        return;
      }
      _shownIds.add(suggestions.first.id);
      _todayShownIds.add(suggestions.first.id);
      _cache[cacheKey] = suggestions.first;
      emit(MealSuggestionsLoaded(suggestion: suggestions.first, shownIds: List.from(_shownIds)));
    } catch (e) {
      emit(MealSuggestionsError(e.toString()));
    }
  }
}
