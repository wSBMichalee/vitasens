import 'package:equatable/equatable.dart';

abstract class BrowseEvent extends Equatable {
  const BrowseEvent();

  @override
  List<Object?> get props => [];
}

class LoadBrowse extends BrowseEvent {
  const LoadBrowse();
}

class SearchRecipes extends BrowseEvent {
  final String query;

  const SearchRecipes(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterByCuisine extends BrowseEvent {
  final String cuisine;

  const FilterByCuisine(this.cuisine);

  @override
  List<Object?> get props => [cuisine];
}

class FilterByDietTag extends BrowseEvent {
  final String tag;

  const FilterByDietTag(this.tag);

  @override
  List<Object?> get props => [tag];
}

class ChangeSortBy extends BrowseEvent {
  final String sortBy;

  const ChangeSortBy(this.sortBy);

  @override
  List<Object?> get props => [sortBy];
}

class LoadMoreRecipes extends BrowseEvent {
  const LoadMoreRecipes();
}

class ClearFilters extends BrowseEvent {
  const ClearFilters();
}
