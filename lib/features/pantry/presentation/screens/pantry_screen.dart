import 'package:flutter/material.dart' hide FilterChip;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/core/widgets/app_header.dart';
import 'package:vitasense/core/widgets/gradient_scaffold.dart';
import 'package:vitasense/features/pantry/bloc/pantry_bloc.dart';
import 'package:vitasense/features/pantry/bloc/pantry_event.dart';
import 'package:vitasense/features/pantry/bloc/pantry_state.dart';
import 'package:vitasense/features/pantry/data/models/ingredient_model.dart';
import 'package:vitasense/features/pantry/data/pantry_repository.dart';
import 'package:vitasense/features/pantry/presentation/screens/add_ingredient_screen.dart';

import '../widgets/pantry_shimmer.dart';
import '../widgets/pantry_filter_chip.dart';
import '../widgets/pantry_quick_action_card.dart';
import '../widgets/pantry_expiry_item.dart';
import '../widgets/pantry_ingredient_card.dart';


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
    return GradientScaffold(
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
      child: const ShimmerLayout(),
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
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text("Pantry", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22.sp)),
          actions: [
            AppHeaderIconButton(
              icon: Icons.add,
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AddIngredientScreen(),
              ).then((_) {
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
                        childAspectRatio: 0.75,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => IngredientCard(ingredient: filtered[index]),
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
          FilterChip(
            label: 'ALL',
            isSelected: state.selectedFilter == 'all',
            onTap: () =>
                context.read<PantryBloc>().add(const FilterPantry('all')),
          ),
          SizedBox(width: 8.w),
          FilterChip(
            label: 'EXPIRING 🔥',
            isSelected: state.selectedFilter == 'expiring',
            onTap: () =>
                context.read<PantryBloc>().add(const FilterPantry('expiring')),
          ),
          SizedBox(width: 8.w),
          FilterChip(
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
          child: QuickActionCard(
            icon: Icons.camera_alt_outlined,
            label: 'SCAN FRIDGE',
            onTap: () => context.push(AppRoutes.scanning),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: QuickActionCard(
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
                Expanded(child: ExpiryItem(ingredient: expiring[i])),
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
                    : () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const AddIngredientScreen(),
                        ).then((_) {
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


// ─── Filter chip ───────────────────────────────────────────────────────────────


// ─── Quick action card (horizontal) ───────────────────────────────────────────


// ─── Expiry item card (with food photo) ───────────────────────────────────────


// ─── Ingredient card ───────────────────────────────────────────────────────────

