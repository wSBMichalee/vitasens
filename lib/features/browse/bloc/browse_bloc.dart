import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/features/browse/bloc/browse_event.dart';
import 'package:vitasense/features/browse/bloc/browse_state.dart';
import 'package:vitasense/features/browse/data/browse_repository.dart';
import 'package:vitasense/features/browse/data/models/browse_filters_model.dart';

class BrowseBloc extends Bloc<BrowseEvent, BrowseState> {
  final BrowseRepository _repository;

  BrowseBloc({BrowseRepository? repository})
      : _repository = repository ?? BrowseRepository(),
        super(const BrowseInitial()) {
    on<LoadBrowse>(_onLoadBrowse);
    on<SearchRecipes>(_onSearchRecipes);
    on<FilterByCuisine>(_onFilterByCuisine);
    on<FilterByDietTag>(_onFilterByDietTag);
    on<ChangeSortBy>(_onChangeSortBy);
    on<LoadMoreRecipes>(_onLoadMoreRecipes);
    on<ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadBrowse(
    LoadBrowse event,
    Emitter<BrowseState> emit,
  ) async {
    emit(const BrowseLoading());
    try {
      const initialFilters = BrowseFiltersModel();

      final results = await Future.wait([
        _repository.getFeatured(),
        _repository.getCuisines(),
        _repository.getDietTags(),
        _repository.browseRecipes(initialFilters),
      ]);

      final featured = results[0] as List<Map<String, dynamic>>;
      final cuisines = results[1] as List<String>;
      final dietTags = results[2] as List<String>;
      final browseResponse = results[3] as Map<String, dynamic>;

      final recipes = List<Map<String, dynamic>>.from(browseResponse['recipes'] ?? []);
      final hasMore = browseResponse['has_more'] as bool? ?? false;

      emit(BrowseLoaded(
        recipes: recipes,
        featured: featured,
        cuisines: cuisines,
        dietTags: dietTags,
        filters: initialFilters,
        hasMore: hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(BrowseError(e.toString()));
    }
  }

  Future<void> _onSearchRecipes(
    SearchRecipes event,
    Emitter<BrowseState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BrowseLoaded) return;

    final newFilters = currentState.filters.copyWith(
      searchQuery: event.query,
      page: 0,
    );

    await _fetchWithNewFilters(newFilters, emit, currentState);
  }

  Future<void> _onFilterByCuisine(
    FilterByCuisine event,
    Emitter<BrowseState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BrowseLoaded) return;

    final currentCuisines = List<String>.from(currentState.filters.selectedCuisines);
    if (currentCuisines.contains(event.cuisine)) {
      currentCuisines.remove(event.cuisine);
    } else {
      currentCuisines.add(event.cuisine);
    }

    final newFilters = currentState.filters.copyWith(
      selectedCuisines: currentCuisines,
      page: 0,
    );

    await _fetchWithNewFilters(newFilters, emit, currentState);
  }

  Future<void> _onFilterByDietTag(
    FilterByDietTag event,
    Emitter<BrowseState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BrowseLoaded) return;

    final currentTags = List<String>.from(currentState.filters.selectedDietTags);
    if (currentTags.contains(event.tag)) {
      currentTags.remove(event.tag);
    } else {
      currentTags.add(event.tag);
    }

    final newFilters = currentState.filters.copyWith(
      selectedDietTags: currentTags,
      page: 0,
    );

    await _fetchWithNewFilters(newFilters, emit, currentState);
  }

  Future<void> _onChangeSortBy(
    ChangeSortBy event,
    Emitter<BrowseState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BrowseLoaded) return;

    final newFilters = currentState.filters.copyWith(
      sortBy: event.sortBy,
      page: 0,
    );

    await _fetchWithNewFilters(newFilters, emit, currentState);
  }

  Future<void> _onLoadMoreRecipes(
    LoadMoreRecipes event,
    Emitter<BrowseState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BrowseLoaded) return;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPageFilters = currentState.filters.copyWith(
        page: currentState.filters.page + 1,
      );

      final response = await _repository.browseRecipes(nextPageFilters);
      final newRecipes = List<Map<String, dynamic>>.from(response['recipes'] ?? []);
      final hasMore = response['has_more'] as bool? ?? false;

      emit(currentState.copyWith(
        recipes: [...currentState.recipes, ...newRecipes],
        filters: nextPageFilters,
        hasMore: hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
      // Optionally could emit an error state here, but we usually want to keep the UI intact if load more fails
    }
  }

  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<BrowseState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BrowseLoaded) return;

    const defaultFilters = BrowseFiltersModel();
    await _fetchWithNewFilters(defaultFilters, emit, currentState);
  }

  Future<void> _fetchWithNewFilters(
    BrowseFiltersModel newFilters,
    Emitter<BrowseState> emit,
    BrowseLoaded currentState,
  ) async {
    // Show a loading state but keep the previous recipes to prevent flickering if you want,
    // or just reset recipes. The spec says emit BrowseLoaded z nowymi przepisami, meaning we fetch
    // and then update. But let's show loading UI by returning to initial/loading or a custom state.
    // However, the spec didn't specify a "refetching" state, so we'll just show loading or update directly.
    // Usually, replacing the list with a shimmer is best:
    emit(const BrowseLoading());

    try {
      final response = await _repository.browseRecipes(newFilters);
      final recipes = List<Map<String, dynamic>>.from(response['recipes'] ?? []);
      final hasMore = response['has_more'] as bool? ?? false;

      emit(BrowseLoaded(
        recipes: recipes,
        featured: currentState.featured,
        cuisines: currentState.cuisines,
        dietTags: currentState.dietTags,
        filters: newFilters,
        hasMore: hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(BrowseError(e.toString()));
    }
  }
}
