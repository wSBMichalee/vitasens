class BrowseFiltersModel {
  final List<String> selectedCuisines;
  final List<String> selectedDietTags;
  final String searchQuery;
  final String sortBy;
  final int page;
  final int pageSize;

  const BrowseFiltersModel({
    this.selectedCuisines = const [],
    this.selectedDietTags = const [],
    this.searchQuery = '',
    this.sortBy = 'popular',
    this.page = 0,
    this.pageSize = 20,
  });

  BrowseFiltersModel copyWith({
    List<String>? selectedCuisines,
    List<String>? selectedDietTags,
    String? searchQuery,
    String? sortBy,
    int? page,
    int? pageSize,
  }) {
    return BrowseFiltersModel(
      selectedCuisines: selectedCuisines ?? this.selectedCuisines,
      selectedDietTags: selectedDietTags ?? this.selectedDietTags,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  Map<String, dynamic> toQueryParams() {
    return {
      'cuisines': selectedCuisines,
      'diet_tags': selectedDietTags,
      'search': searchQuery,
      'sort_by': sortBy,
      'page': page,
      'page_size': pageSize,
    };
  }
}
