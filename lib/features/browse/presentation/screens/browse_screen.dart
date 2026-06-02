import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/features/browse/bloc/browse_bloc.dart';
import 'package:vitasense/features/browse/bloc/browse_event.dart';
import 'package:vitasense/features/browse/bloc/browse_state.dart';

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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
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
                    // ─── HEADER ────────────────────────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 24.r),
                            onPressed: () => context.pop(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          SizedBox(width: 16.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Browse Recipes', style: AppTextStyles.headingLarge),
                              Text('Discover new meals', style: AppTextStyles.bodyMedium),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _showFiltersSheet(context, state),
                            child: Container(
                              width: 44.r,
                              height: 44.r,
                              decoration: BoxDecoration(
                                color: Colors.white,
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
                          fillColor: Colors.white,
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
                          _CuisineChip(
                            label: 'All',
                            isSelected: state.filters.selectedCuisines.isEmpty,
                            onTap: () => context.read<BrowseBloc>().add(const ClearFilters()),
                          ),
                          ...state.cuisines.map((c) => _CuisineChip(
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
                                    return _FeaturedCard(recipe: state.featured[index]);
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
                                  _SortChip(
                                    label: 'Popular',
                                    value: 'popular',
                                    currentSort: state.filters.sortBy,
                                  ),
                                  SizedBox(width: 8.w),
                                  _SortChip(
                                    label: 'Newest',
                                    value: 'newest',
                                    currentSort: state.filters.sortBy,
                                  ),
                                  SizedBox(width: 8.w),
                                  _SortChip(
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
                                    return _RecipeGridCard(recipe: state.recipes[index]);
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
          Container(height: 60.h, margin: EdgeInsets.all(20.w), color: Colors.white),
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
                  color: Colors.white,
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

class _CuisineChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CuisineChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimary : Colors.white,
          border: isSelected ? null : Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final String value;
  final String currentSort;

  const _SortChip({required this.label, required this.value, required this.currentSort});

  @override
  Widget build(BuildContext context) {
    final isSelected = currentSort == value;
    return GestureDetector(
      onTap: () => context.read<BrowseBloc>().add(ChangeSortBy(value)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const _FeaturedCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final title = recipe['title'] as String? ?? 'Recipe';
    final image = recipe['image_url'] as String? ?? 'https://picsum.photos/400/300';
    final cookTime = recipe['cook_time']?.toString() ?? '15m';
    final calories = recipe['calories']?.toString() ?? '400 kcal';

    return GestureDetector(
      onTap: () => context.push(AppRoutes.recipeDetails.replaceFirst(':id', recipe['id'] ?? 'none'), extra: recipe),
      child: Container(
        width: 280.w,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: image,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: AppColors.borderLight),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.borderLight,
                  child: const Icon(Icons.image_not_supported, color: AppColors.textMuted),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12.h,
              left: 12.w,
              right: 12.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, color: Colors.white, size: 12.r),
                      SizedBox(width: 4.w),
                      Text(
                        cookTime,
                        style: TextStyle(fontSize: 11.sp, color: Colors.white),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.local_fire_department_outlined, color: Colors.white, size: 12.r),
                      SizedBox(width: 4.w),
                      Text(
                        calories,
                        style: TextStyle(fontSize: 11.sp, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeGridCard extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const _RecipeGridCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final title = recipe['title'] as String? ?? 'Recipe';
    final image = recipe['image_url'] as String? ?? 'https://picsum.photos/400/300';
    final cookTime = recipe['cook_time']?.toString() ?? '15m';
    final calories = recipe['calories']?.toString() ?? '400 kcal';
    final tags = (recipe['diet_tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    return GestureDetector(
      onTap: () => context.push(AppRoutes.recipeDetails.replaceFirst(':id', recipe['id'] ?? 'none'), extra: recipe),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: CachedNetworkImage(
                imageUrl: image,
                height: 120.h,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: AppColors.borderLight),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.borderLight,
                  height: 120.h,
                  child: const Icon(Icons.image_not_supported, color: AppColors.textMuted),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, color: AppColors.textMuted, size: 12.r),
                        SizedBox(width: 4.w),
                        Text(
                          cookTime,
                          style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
                        ),
                        const Spacer(),
                        Icon(Icons.local_fire_department, color: AppColors.primary, size: 12.r),
                        SizedBox(width: 2.w),
                        Text(
                          calories,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    if (tags.isNotEmpty)
                      Wrap(
                        spacing: 4.w,
                        runSpacing: 4.h,
                        children: tags.take(2).map((tag) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
