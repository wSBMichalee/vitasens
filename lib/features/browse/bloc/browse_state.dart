import 'package:equatable/equatable.dart';
import 'package:vitasense/features/browse/data/models/browse_filters_model.dart';

abstract class BrowseState extends Equatable {
  const BrowseState();

  @override
  List<Object?> get props => [];
}

class BrowseInitial extends BrowseState {
  const BrowseInitial();
}

class BrowseLoading extends BrowseState {
  const BrowseLoading();
}

class BrowseLoaded extends BrowseState {
  final List<Map<String, dynamic>> recipes;
  final List<Map<String, dynamic>> featured;
  final List<String> cuisines;
  final List<String> dietTags;
  final BrowseFiltersModel filters;
  final bool hasMore;
  final bool isLoadingMore;

  const BrowseLoaded({
    required this.recipes,
    required this.featured,
    required this.cuisines,
    required this.dietTags,
    required this.filters,
    required this.hasMore,
    required this.isLoadingMore,
  });

  BrowseLoaded copyWith({
    List<Map<String, dynamic>>? recipes,
    List<Map<String, dynamic>>? featured,
    List<String>? cuisines,
    List<String>? dietTags,
    BrowseFiltersModel? filters,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return BrowseLoaded(
      recipes: recipes ?? this.recipes,
      featured: featured ?? this.featured,
      cuisines: cuisines ?? this.cuisines,
      dietTags: dietTags ?? this.dietTags,
      filters: filters ?? this.filters,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        recipes,
        featured,
        cuisines,
        dietTags,
        filters,
        hasMore,
        isLoadingMore,
      ];
}

class BrowseError extends BrowseState {
  final String message;

  const BrowseError(this.message);

  @override
  List<Object?> get props => [message];
}
