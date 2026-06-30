import 'package:vitasense/core/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/core/widgets/app_header.dart';
import 'package:vitasense/features/browse/bloc/browse_bloc.dart';
import 'package:vitasense/features/browse/bloc/browse_event.dart';
import 'package:vitasense/features/browse/bloc/browse_state.dart';
import '../widgets/cuisine_chip.dart';
import '../widgets/sort_chip.dart';
import '../widgets/featured_card.dart';
import '../widgets/recipe_grid_card.dart';
import 'package:vitasense/core/utils/bottom_sheet_utils.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BrowseBloc()..add(const LoadBrowse()),
      child: const _BrowseView(),
    );
  }
}

class _BrowseView extends StatefulWidget {
  const _BrowseView();

  @override
  State<_BrowseView> createState() => _BrowseViewState();
}

class _BrowseViewState extends State<_BrowseView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<BrowseBloc>().add(const LoadMoreRecipes());
    }
  }

  void _showFiltersSheet(BuildContext context, BrowseLoaded state) {
    showAppBottomSheet(
      context: context,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Diet Filters', style: AppTextStyles.headingMedium),
                      TextButton(
                        onPressed: () {
                          this.context.read<BrowseBloc>().add(const ClearFilters());
                          Navigator.pop(sheetContext);
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.dietTags.length,
                      itemBuilder: (context, index) {
                        final tag = state.dietTags[index];
                        final isSelected = state.filters.selectedDietTags.contains(tag);
                        return CheckboxListTile(
                          title: Text(tag, style: AppTextStyles.bodyMedium),
                          value: isSelected,
                          activeColor: AppColors.primary,
                          onChanged: (value) {
                            setState(() {
                              this.context.read<BrowseBloc>().add(FilterByDietTag(tag));
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BrowseBloc, BrowseState>(
      listener: (context, state) {
        if (state is BrowseError) {
          SnackbarUtils.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<BrowseBloc, BrowseState>(
            builder: (context, state) {
              if (state is BrowseInitial || state is BrowseLoading) {
                return _buildShimmerLoading();
              }
              
              if (state is BrowseLoaded) {
                final hasActiveFilters = state.filters.selectedDietTags.isNotEmpty;
                final isSearching = state.filters.searchQuery.isNotEmpty;

                return Column(
                  children: [
                    // ── AppHeader: wariant nested, filtry jako action ──────────────────
                    AppHeader(
                      title: 'Przeglądaj',
                      subtitle: 'Odkrywaj nowe przepisy',
                      variant: AppHeaderVariant.nested,
                      onBack: () => context.pop(),
                      actions: [
                        GestureDetector(
                          onTap: () => _showFiltersSheet(context, state),
                          child: Container(
                            width: 44.r,
                            height: 44.r,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundWhite,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(Icons.tune, color: AppColors.textPrimary, size: 22.r),
                                if (hasActiveFilters)
                                  Positioned(
                                    top: 10.h,
                                    right: 10.w,
                                    child: Container(
                                      width: 8.r,
                                      height: 8.r,
                                      decoration: const BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ─── SEARCH BAR ────────────────────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (q) => context.read<BrowseBloc>().add(SearchRecipes(q)),
                        decoration: InputDecoration(
                          hintText: 'Search recipes...',
                          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14.sp),
                          prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 20.r),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: AppColors.textMuted, size: 20.r),
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<BrowseBloc>().add(const SearchRecipes(''));
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.backgroundWhite,
                          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // ─── CUISINE CHIPS ─────────────────────────────────────────────────
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        children: [
                          CuisineChip(
                            label: 'All',
                            isSelected: state.filters.selectedCuisines.isEmpty,
                            onTap: () => context.read<BrowseBloc>().add(const ClearFilters()),
                          ),
                          ...state.cuisines.map((c) => CuisineChip(
                                label: c,
                                isSelected: state.filters.selectedCuisines.contains(c),
                                onTap: () => context.read<BrowseBloc>().add(FilterByCuisine(c)),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // ─── SCROLLABLE CONTENT ──────────────────────────────────────────
                    Expanded(
                      child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          // ─── FEATURED SECTION ─────────────────────────────────────
                          if (!isSearching && state.featured.isNotEmpty) ...[
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: Text(
                                  'FEATURED',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: 200.h,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                                  itemCount: state.featured.length,
                                  itemBuilder: (context, index) {
                                    return FeaturedCard(recipe: state.featured[index]);
                                  },
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                          ],

                          // ─── SORT ROW ─────────────────────────────────────────────
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Row(
                                children: [
                                  Text(
                                    'SORT BY',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  SortChip(
                                    label: 'Popular',
                                    value: 'popular',
                                    currentSort: state.filters.sortBy,
                                  ),
                                  SizedBox(width: 8.w),
                                  SortChip(
                                    label: 'Newest',
                                    value: 'newest',
                                    currentSort: state.filters.sortBy,
                                  ),
                                  SizedBox(width: 8.w),
                                  SortChip(
                                    label: 'Quickest',
                                    value: 'quickest',
                                    currentSort: state.filters.sortBy,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(child: SizedBox(height: 16.h)),

                          // ─── RECIPES GRID ─────────────────────────────────────────
                          if (state.recipes.isEmpty)
                            const SliverFillRemaining(
                              child: Center(
                                child: Text(
                                  'No recipes found matching criteria.',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              sliver: SliverGrid(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 12.w,
                                  mainAxisSpacing: 12.h,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return RecipeGridCard(recipe: state.recipes[index]);
                                  },
                                  childCount: state.recipes.length,
                                ),
                              ),
                            ),

                          // ─── LOAD MORE INDICATOR ──────────────────────────────────
                          if (state.isLoadingMore)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(24.r),
                                child: const Center(
                                  child: CircularProgressIndicator(color: AppColors.primary),
                                ),
                              ),
                            )
                          else
                            SliverToBoxAdapter(child: SizedBox(height: 48.h)),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: AppColors.borderLight,
      highlightColor: AppColors.border,
      child: Column(
        children: [
          Container(height: 60.h, margin: EdgeInsets.all(20.w), color: AppColors.backgroundWhite),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(20.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
              ),
              itemCount: 6,
              itemBuilder: (_, __) => Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}








