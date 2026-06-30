import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/core/utils/bottom_sheet_utils.dart';
import 'package:vitasense/features/recipes/bloc/recipes_bloc.dart';
import 'package:vitasense/features/recipes/bloc/recipes_event.dart';
import 'package:vitasense/features/recipes/bloc/recipes_state.dart';
import 'package:vitasense/core/widgets/app_header.dart';
import '../widgets/ai_meals/recipe_card.dart';
import '../widgets/ai_meals/filter_bottom_sheet.dart';

class AiMealsScreen extends StatefulWidget {
  const AiMealsScreen({super.key, this.ingredients});

  final List<String>? ingredients;

  @override
  State<AiMealsScreen> createState() => _AiMealsScreenState();
}

class _AiMealsScreenState extends State<AiMealsScreen> {
  bool _isLoadingIngredients = true;
  bool _hasNoIngredients = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.ingredients != null && widget.ingredients!.isNotEmpty) {
        setState(() => _isLoadingIngredients = false);
        context.read<RecipesBloc>().add(LoadRecipes(widget.ingredients!));
      } else {
        _loadIngredients();
      }
    });
  }

  Future<void> _loadIngredients() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      debugPrint('_loadIngredients: userId=$userId');
      
      if (userId == null) {
        if (mounted) setState(() { _isLoadingIngredients = false; _hasNoIngredients = true; });
        return;
      }

      // Krok 1: pobierz pantry
      final pantryRes = await supabase
          .from('pantries')
          .select('id')
          .eq('owner_id', userId)
          .maybeSingle();
      
      debugPrint('_loadIngredients: pantryRes=$pantryRes');

      if (pantryRes == null) {
        if (mounted) setState(() { _isLoadingIngredients = false; _hasNoIngredients = true; });
        return;
      }

      final pantryId = pantryRes['id'] as String;
      debugPrint('_loadIngredients: pantryId=$pantryId');

      // Krok 2: pobierz składniki
      final ingredientsRes = await supabase
          .from('ingredients')
          .select('name')
          .eq('pantry_id', pantryId);

      debugPrint('_loadIngredients: ingredientsRes=$ingredientsRes');

      final names = (ingredientsRes as List)
          .map((i) => i['name']?.toString() ?? '')
          .where((n) => n.isNotEmpty)
          .toList();

      debugPrint('_loadIngredients: names=$names');

      if (!mounted) return;

      if (names.isEmpty) {
        setState(() { _isLoadingIngredients = false; _hasNoIngredients = true; });
        return;
      }

      setState(() => _isLoadingIngredients = false);
      context.read<RecipesBloc>().add(LoadRecipes(names));

    } catch (e, stack) {
      debugPrint('_loadIngredients ERROR: $e\n$stack');
      if (mounted) setState(() { _isLoadingIngredients = false; _hasNoIngredients = true; });
    }
  }

  Future<void> _onRefresh() async {
    if (widget.ingredients != null && widget.ingredients!.isNotEmpty) {
      context.read<RecipesBloc>().add(LoadRecipes(widget.ingredients!));
    } else {
      await _loadIngredients();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'AI Meals',
              variant: AppHeaderVariant.main,
              actions: [
                GestureDetector(
                  onTap: () => context.push(AppRoutes.savedRecipes),
                  child: Container(
                    width: 40.r, height: 40.r,
                    decoration: const BoxDecoration(
                      color: AppColors.borderLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.bookmark_border, color: AppColors.textPrimary, size: 20.r),
                  ),
                ),
                SizedBox(width: 8.w),
                BlocBuilder<RecipesBloc, RecipesState>(
                  builder: (context, state) {
                    final activeFilters = state is RecipesLoaded ? state.activeFilters : <String>{};
                    final selectedCategory = state is RecipesLoaded ? state.selectedCategory : 'ALL';
                    final hasActive = activeFilters.isNotEmpty || selectedCategory != 'ALL';
                    return GestureDetector(
                      onTap: () => showAppBottomSheet(
                        context: context,
                        builder: (_) => BlocProvider.value(
                          value: context.read<RecipesBloc>(),
                          child: const FilterBottomSheet(),
                        ),
                      ),
                      child: Container(
                        width: 40.r, height: 40.r,
                        decoration: BoxDecoration(
                          color: hasActive ? AppColors.primary : AppColors.borderLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.tune_rounded, color: hasActive ? AppColors.textWhite : AppColors.textPrimary, size: 20.r),
                      ),
                    );
                  },
                ),
              ],
            ),
            Expanded(
              child: BlocConsumer<RecipesBloc, RecipesState>(
                listener: (context, state) {
                  if (state is RecipesSubscriptionExpired) {
                    context.push('/subscription'); // Placeholder dla paywall
                  }
                },
                builder: (context, state) {
                  if (_isLoadingIngredients) {
                    return _buildLoadingState();
                  }
                  if (_hasNoIngredients) {
                    return _buildEmptyState();
                  }
                  
                  if (state is RecipesInitial || state is RecipesLoading) {
                    return _buildLoadingState();
                  }
                  if (state is RecipesError) {
                    return _buildErrorState(state.message);
                  }
                  if (state is RecipesLoaded) {
                    if (state.recipes.isEmpty) {
                      return _buildNoResultsState();
                    }
                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: AppColors.primary,
                      child: CustomScrollView(
                        slivers: [
                          if (state.geminiPersonalized)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.successLight,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.auto_awesome, size: 16.r, color: AppColors.successDark),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'Dopasowane do Twojego profilu',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.successDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          SliverPadding(
                            padding: state.geminiPersonalized
                                ? EdgeInsets.fromLTRB(24.w, 0, 24.w, 100.h)
                                : EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 100.h),
                            sliver: SliverGrid(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16.w,
                                mainAxisSpacing: 16.h,
                                childAspectRatio: 0.75,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return RecipeCard(recipe: state.recipes[index]);
                                },
                                childCount: state.recipes.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.kitchen, color: AppColors.textMuted, size: 48.r),
            SizedBox(height: 16.h),
            Text('Brak składników', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            SizedBox(height: 8.h),
            Text(
              'Dodaj składniki do spiżarki, żeby zobaczyć przepisy',
              style: TextStyle(fontSize: 14.sp, height: 1.5, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              height: 56.h,
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.go('/pantry'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                child: Text('Idź do spiżarki', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textWhite)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 100.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.borderLight,
          highlightColor: AppColors.border,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 48.r),
          SizedBox(height: 16.h),
          Text(message, style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary)),
          SizedBox(height: 24.h),
          SizedBox(
            height: 56.h,
            width: 200.w,
            child: FilledButton(
              onPressed: _onRefresh,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              child: Text('Spróbuj ponownie', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textWhite)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: const BoxDecoration(color: AppColors.borderLight, shape: BoxShape.circle),
              child: Icon(Icons.restaurant_menu, size: 36.r, color: AppColors.textMuted),
            ),
            SizedBox(height: 24.h),
            Text('Brak wyników', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            SizedBox(height: 8.h),
            Text(
              'Spróbuj zmienić filtry lub dodać więcej składników.',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              height: 56.h,
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.read<RecipesBloc>().add(const ClearRecipeFilters()),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                child: Text('Wyczyść filtry', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textWhite)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
