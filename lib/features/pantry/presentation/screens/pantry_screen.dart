import 'package:flutter/material.dart' hide FilterChip;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
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
import '../widgets/pantry_ingredient_card.dart';
import '../widgets/pantry_error_view.dart';
import '../widgets/pantry_promo_card.dart';
import '../widgets/pantry_quick_actions.dart';
import '../widgets/pantry_expiry_banner.dart';
import '../widgets/pantry_search_bar.dart';
import '../widgets/pantry_filter_chips.dart';
import '../widgets/pantry_empty_state.dart';



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
              return PantryErrorView(message: state.message, onRetry: () => context.read<PantryBloc>().add(const RefreshPantry()));
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
  

  // ─── Loaded ───────────────────────────────────────────────────────────────
  Widget _buildLoaded(BuildContext context, PantryLoaded state) {
    final filtered = _applyFilters(state);
    

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
                        PantrySearchBar(
  controller: _searchController,
  searchQuery: _searchQuery,
  onChanged: (v) => setState(() => _searchQuery = v),
  onClear: () {
    _searchController.clear();
    setState(() => _searchQuery = '');
  },
),
                        SizedBox(height: 12.h),
                        PantryFilterChips(
  selectedFilter: state.selectedFilter,
  onFilterSelected: (filter) => context.read<PantryBloc>().add(FilterPantry(filter)),
),
                        SizedBox(height: 20.h),
                        const PantryPromoCard(),
                        SizedBox(height: 12.h),
                        const PantryQuickActions(),
                        if (state.expiringSoon.isNotEmpty) ...[
                          SizedBox(height: 20.h),
                          PantryExpiryBanner(expiring: state.expiringSoon),
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
                    child: PantryEmptyState(
  isFiltered: state.selectedFilter != 'all' || _searchQuery.isNotEmpty,
  onActionPressed: (state.selectedFilter != 'all' || _searchQuery.isNotEmpty)
      ? () {
          _searchController.clear();
          setState(() => _searchQuery = '');
          context.read<PantryBloc>().add(const FilterPantry('all'));
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
),
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
  

  // ─── Filter chips ─────────────────────────────────────────────────────────
  

  // ─── Promo card (white) ───────────────────────────────────────────────────
  

  // ─── Quick actions ────────────────────────────────────────────────────────
  

  // ─── Expiry banner ────────────────────────────────────────────────────────
  

  // ─── Empty state ──────────────────────────────────────────────────────────
  

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

