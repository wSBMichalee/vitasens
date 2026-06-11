import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/core/widgets/app_header.dart';
import 'package:vitasense/features/pantry/bloc/pantry_bloc.dart';
import 'package:vitasense/features/pantry/bloc/pantry_event.dart';
import 'package:vitasense/features/pantry/bloc/pantry_state.dart';
import 'package:vitasense/features/pantry/data/models/ingredient_model.dart';
import 'package:vitasense/features/pantry/data/pantry_repository.dart';

class PantryScreen extends StatelessWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PantryBloc(
        repository: PantryRepository(),
      )..add(const LoadPantry()),
      child: const _PantryView(),
    );
  }
}

// ─── StatefulWidget for search controller ─────────────────────────────────────
class _PantryView extends StatefulWidget {
  const _PantryView();

  @override
  State<_PantryView> createState() => _PantryViewState();
}

class _PantryViewState extends State<_PantryView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<IngredientModel> _applyFilters(PantryLoaded state) {
    List<IngredientModel> result;
    switch (state.selectedFilter) {
      case 'expiring':
        result = state.expiringSoon;
      case 'low_stock':
        result =
            state.ingredients.where((i) => i.quantity <= i.minimumQuantity).toList();
      default:
        result = state.ingredients;
    }
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((i) => i.name.toLowerCase().contains(q)).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<PantryBloc, PantryState>(
          listener: (context, state) {
            if (state is PantryError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is PantryInitial || state is PantryLoading) {
              return _buildShimmer();
            }
            if (state is PantryError) {
              return _buildError(context, state.message);
            }
            if (state is PantryLoaded) {
              return _buildLoaded(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // ─── Shimmer ──────────────────────────────────────────────────────────────
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.borderLight,
      highlightColor: AppColors.border,
      child: const _ShimmerLayout(),
    );
  }

  // ─── Error ────────────────────────────────────────────────────────────────
  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: const TextStyle(color: AppColors.error)),
          SizedBox(height: 16.h),
          SizedBox(
            height: 50.h,
            child: FilledButton(
              onPressed: () =>
                  context.read<PantryBloc>().add(const RefreshPantry()),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r)),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Loaded ───────────────────────────────────────────────────────────────
  Widget _buildLoaded(BuildContext context, PantryLoaded state) {
    final filtered = _applyFilters(state);
    final count = state.ingredients.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── AppHeader: wariant main, przycisk + jako action ───────────────
        AppHeader(
          title: 'Pantry',
          subtitle: '$count ingredient${count == 1 ? '' : 's'} available',
          variant: AppHeaderVariant.main,
          backgroundColor: AppColors.primary,
          textColor: AppColors.textWhite,
          actions: [
            AppHeaderIconButton(
              icon: Icons.add,
              onPressed: () => context.push(AppRoutes.addIngredient).then((_) {
                if (context.mounted) {
                  context.read<PantryBloc>().add(const RefreshPantry());
                }
              }),
            ),
          ],
        ),

        // ── Scrollable body ───────────────────────────────────────────────
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async =>
                context.read<PantryBloc>().add(const RefreshPantry()),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(),
                        SizedBox(height: 12.h),
                        _buildFilterChips(context, state),
                        SizedBox(height: 20.h),
                        _buildPromoCard(context, state),
                        SizedBox(height: 12.h),
                        _buildQuickActions(context),
                        if (state.expiringSoon.isNotEmpty) ...[
                          SizedBox(height: 20.h),
                          _buildExpiryBanner(state),
                        ],
                        SizedBox(height: 20.h),
                        Text(
                          _sectionTitle(state.selectedFilter),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontFamily: AppTextStyles.labelLarge.fontFamily,
                          ),
                        ),
                        SizedBox(height: 12.h),
                      ],
                    ),
                  ),
                ),

                // ─── Ingredient list / empty state ───────────────────────
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(context, state),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 40.h),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _IngredientCard(ingredient: filtered[index]),
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Search bar ───────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          SizedBox(width: 12.w),
          Icon(Icons.search, color: AppColors.textMuted, size: 20.r),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search ingredients...',
                hintStyle:
                    TextStyle(fontSize: 14.sp, color: AppColors.textMuted),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: Icon(Icons.close, color: AppColors.textMuted, size: 18.r),
              ),
            )
          else
            SizedBox(width: 12.w),
        ],
      ),
    );
  }

  // ─── Filter chips ─────────────────────────────────────────────────────────
  Widget _buildFilterChips(BuildContext context, PantryLoaded state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'ALL',
            isSelected: state.selectedFilter == 'all',
            onTap: () =>
                context.read<PantryBloc>().add(const FilterPantry('all')),
          ),
          SizedBox(width: 8.w),
          _FilterChip(
            label: 'EXPIRING 🔥',
            isSelected: state.selectedFilter == 'expiring',
            onTap: () =>
                context.read<PantryBloc>().add(const FilterPantry('expiring')),
          ),
          SizedBox(width: 8.w),
          _FilterChip(
            label: 'LOW STOCK',
            isSelected: state.selectedFilter == 'low_stock',
            onTap: () =>
                context.read<PantryBloc>().add(const FilterPantry('low_stock')),
          ),
        ],
      ),
    );
  }

  // ─── Promo card (white) ───────────────────────────────────────────────────
  Widget _buildPromoCard(BuildContext context, PantryLoaded state) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: AppColors.indigoLight,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(Icons.auto_awesome,
                    color: AppColors.secondary, size: 24.r),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cook from your\ningredients',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Turn what you have into healthy, goal-aligned meals instantly.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: FilledButton(
              onPressed: () => context.go(AppRoutes.aiMeals),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(
                'GENERATE MEALS',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textWhite,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Quick actions ────────────────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.camera_alt_outlined,
            label: 'SCAN FRIDGE',
            onTap: () => context.push(AppRoutes.scanning),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.receipt_long_outlined,
            label: 'SCAN RECEIPT',
            onTap: () => context.push(AppRoutes.scanning),
          ),
        ),
      ],
    );
  }

  // ─── Expiry banner ────────────────────────────────────────────────────────
  Widget _buildExpiryBanner(PantryLoaded state) {
    final expiring = state.expiringSoon;
    final others = expiring.length - 1;
    final subtitle = others > 0
        ? '${expiring.first.name} and $others other${others > 1 ? 's' : ''} expire soon'
        : '${expiring.first.name} expires soon';

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        border: Border.all(color: AppColors.warningBorder),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28.r,
                height: 28.r,
                decoration: const BoxDecoration(
                  color: AppColors.warning,
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(Icons.schedule, color: AppColors.textWhite, size: 14.r),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Use before they go bad',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                          fontSize: 12.sp, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              for (int i = 0; i < expiring.take(2).length; i++) ...[
                if (i > 0) SizedBox(width: 8.w),
                Expanded(child: _ExpiryItem(ingredient: expiring[i])),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ─── Empty state ──────────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context, PantryLoaded state) {
    final isFiltered =
        state.selectedFilter != 'all' || _searchQuery.isNotEmpty;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: const BoxDecoration(
                color: AppColors.borderLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.kitchen_outlined,
                  size: 36.r, color: AppColors.textMuted),
            ),
            SizedBox(height: 20.h),
            Text(
              isFiltered ? 'No ingredients found' : 'Your pantry is empty',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              isFiltered
                  ? 'Try a different search or filter'
                  : 'Add your first ingredient to get started',
              style:
                  TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              height: 56.h,
              width: double.infinity,
              child: FilledButton(
                onPressed: isFiltered
                    ? () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                        context
                            .read<PantryBloc>()
                            .add(const FilterPantry('all'));
                      }
                    : () => context.push(AppRoutes.addIngredient).then((_) {
                          if (context.mounted) {
                            context.read<PantryBloc>().add(const RefreshPantry());
                          }
                        }),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r)),
                ),
                child: Text(
                  isFiltered ? 'Clear filters' : 'Add ingredient',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _sectionTitle(String filter) {
    switch (filter) {
      case 'expiring':
        return 'Expiring soon';
      case 'low_stock':
        return 'Low stock items';
      default:
        return 'All ingredients';
    }
  }
}

// ─── Shimmer skeleton ──────────────────────────────────────────────────────────
class _ShimmerLayout extends StatelessWidget {
  const _ShimmerLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(w: 140.w, h: 24.h, r: 6.r),
                    SizedBox(height: 6.h),
                    _box(w: 100.w, h: 14.h, r: 4.r),
                  ],
                ),
              ),
              _box(w: 44.r, h: 44.r, r: 12.r),
            ],
          ),
          SizedBox(height: 16.h),
          // Search skeleton
          _box(w: double.infinity, h: 44.h, r: 12.r),
          SizedBox(height: 12.h),
          // Filter chips skeleton
          Row(
            children: [
              _box(w: 90.w, h: 32.h, r: 20.r),
              SizedBox(width: 8.w),
              _box(w: 110.w, h: 32.h, r: 20.r),
              SizedBox(width: 8.w),
              _box(w: 90.w, h: 32.h, r: 20.r),
            ],
          ),
          SizedBox(height: 20.h),
          // Promo card skeleton
          _box(w: double.infinity, h: 140.h, r: 20.r),
          SizedBox(height: 12.h),
          // Quick actions skeleton
          Row(
            children: [
              Expanded(child: _box(w: double.infinity, h: 80.h, r: 14.r)),
              SizedBox(width: 10.w),
              Expanded(child: _box(w: double.infinity, h: 80.h, r: 14.r)),
            ],
          ),
          SizedBox(height: 20.h),
          // Ingredient cards
          for (int i = 0; i < 3; i++) ...[
            _box(w: double.infinity, h: 72.h, r: 12.r),
            SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }

  Widget _box({required double w, required double h, required double r}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}

// ─── Filter chip ───────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimary : AppColors.backgroundWhite,
          border: Border.all(
            color: isSelected ? AppColors.textPrimary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ─── Quick action card (horizontal) ───────────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lines = label.split(' ');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 20.r, color: AppColors.textPrimary),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: lines
                  .map((l) => Text(
                        l,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Expiry item card (with food photo) ───────────────────────────────────────
class _ExpiryItem extends StatelessWidget {
  const _ExpiryItem({required this.ingredient});

  final IngredientModel ingredient;

  static const Map<String, String> _categoryImages = {
    'protein':    'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=200&q=80',
    'vegetables': 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=200&q=80',
    'vegetable':  'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=200&q=80',
    'dairy':      'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=200&q=80',
    'grains':     'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=200&q=80',
    'grain':      'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=200&q=80',
  };

  @override
  Widget build(BuildContext context) {
    final days = ingredient.expiryDate?.difference(DateTime.now()).inDays ?? 0;
    final imageUrl = _categoryImages[ingredient.category.toLowerCase()];

    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: SizedBox(
              width: 44.r,
              height: 44.r,
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: AppColors.border,
                        highlightColor: AppColors.borderLight,
                        child: Container(color: AppColors.border),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.warningLight,
                        child: Icon(Icons.eco, color: AppColors.warning, size: 20.r),
                      ),
                    )
                  : Container(
                      color: AppColors.warningLight,
                      child: Icon(Icons.eco, color: AppColors.warning, size: 20.r),
                    ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.name,
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  days <= 0 ? 'Today' : days == 1 ? 'Tomorrow' : '$days days',
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.warningDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ingredient card ───────────────────────────────────────────────────────────
class _IngredientCard extends StatelessWidget {
  const _IngredientCard({required this.ingredient});

  final IngredientModel ingredient;

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'protein':
        return Icons.set_meal;
      case 'vegetables':
      case 'vegetable':
        return Icons.eco;
      case 'dairy':
        return Icons.water_drop;
      case 'grains':
      case 'grain':
        return Icons.grain;
      default:
        return Icons.kitchen;
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFF5F5F5),
      alignment: Alignment.center,
      child: Icon(
        _iconForCategory(ingredient.category),
        size: 36.r,
        color: AppColors.textSecondary.withValues(alpha: 0.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = ingredient.expiryDate?.difference(DateTime.now()).inDays;

    return Dismissible(
      key: Key(ingredient.id),
      direction: DismissDirection.up,
      onDismissed: (_) =>
          context.read<PantryBloc>().add(DeleteIngredient(ingredient.id)),
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.delete_outline, color: AppColors.textWhite, size: 28.r),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 55,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                    child: ingredient.imageUrl != null && ingredient.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: ingredient.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _buildPlaceholder(),
                            errorWidget: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                ),
                Expanded(
                  flex: 45,
                  child: Padding(
                    padding: EdgeInsets.all(10.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ingredient.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${ingredient.quantity} ${ingredient.unit}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        if (days != null)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: days <= 0
                                  ? AppColors.error
                                  : days <= 3
                                      ? AppColors.warning
                                      : AppColors.success,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              days <= 0 ? 'Expired' : '${days}d left',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
        ),
      ),
    );
  }
}
