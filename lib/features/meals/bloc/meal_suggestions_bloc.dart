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

  MealSuggestionsBloc({required this.repository}) : super(MealSuggestionsInitial()) {
    on<LoadSuggestion>(_onLoad);
  }

  Future<void> _onLoad(LoadSuggestion event, Emitter<MealSuggestionsState> emit) async {
    emit(MealSuggestionsLoading());
    try {
      final suggestions = await repository.getSuggestions(
        mealType: event.mealType,
        excludeIds: [..._shownIds, ...event.excludeIds],
      );
      if (suggestions.isEmpty) {
        _shownIds.clear();
        final fresh = await repository.getSuggestions(mealType: event.mealType);
        if (fresh.isEmpty) {
          emit(MealSuggestionsError('No suggestions available'));
          return;
        }
        _shownIds.add(fresh.first.id);
        emit(MealSuggestionsLoaded(suggestion: fresh.first, shownIds: List.from(_shownIds)));
        return;
      }
      _shownIds.add(suggestions.first.id);
      emit(MealSuggestionsLoaded(suggestion: suggestions.first, shownIds: List.from(_shownIds)));
    } catch (e) {
      emit(MealSuggestionsError(e.toString()));
    }
  }
}
