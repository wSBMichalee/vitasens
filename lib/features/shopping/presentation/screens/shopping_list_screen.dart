import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/core/widgets/app_header.dart';
import 'package:vitasense/features/shopping/bloc/shopping_bloc.dart';
import 'package:vitasense/features/shopping/bloc/shopping_event.dart';
import 'package:vitasense/features/shopping/bloc/shopping_state.dart';
import '../widgets/move_to_pantry_button.dart';
import '../widgets/shopping_item_card.dart';
import '../widgets/purchased_item_card.dart';
import 'package:vitasense/core/utils/bottom_sheet_utils.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShoppingBloc()..add(const LoadShoppingList()),
      child: const _ShoppingListView(),
    );
  }
}

class _ShoppingListView extends StatefulWidget {
  const _ShoppingListView();

  @override
  State<_ShoppingListView> createState() => _ShoppingListViewState();
}

class _ShoppingListViewState extends State<_ShoppingListView> {
  final TextEditingController _quickAddController = TextEditingController();

  @override
  void dispose() {
    _quickAddController.dispose();
    super.dispose();
  }

  void _showAddItemSheet(BuildContext context) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    String selectedUnit = 'piece';
    final units = ['piece', 'g', 'kg', 'ml', 'l', 'pack'];

    showAppBottomSheet(
      context: context,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20.w,
                24.h,
                20.w,
                MediaQuery.of(sheetContext).viewInsets.bottom + 24.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Item', style: AppTextStyles.headingMedium),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Item name',
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
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: quantityController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Quantity',
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
                      SizedBox(width: 12.w),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedUnit,
                              isExpanded: true,
                              items: units.map((unit) {
                                return DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => selectedUnit = val);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () {
                        final name = nameController.text.trim();
                        final qty = double.tryParse(quantityController.text.trim()) ?? 1.0;
                        if (name.isNotEmpty) {
                          this.context.read<ShoppingBloc>().add(
                                AddShoppingItem(name, qty, selectedUnit),
                              );
                          Navigator.pop(sheetContext);
                        }
                      },
                      child: Text(
                        'Add to List',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
    return BlocListener<ShoppingBloc, ShoppingState>(
      listener: (context, state) {
        if (state is ShoppingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () => _showAddItemSheet(context),
          child: Icon(Icons.add, color: AppColors.textWhite, size: 28.r),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── AppHeader: wariant nested, + jako action ─────────────────────
              BlocBuilder<ShoppingBloc, ShoppingState>(
                builder: (context, state) {
                  final subtitle = state is ShoppingLoaded
                      ? '${state.items.length} produktów do kupienia'
                      : 'Wczytywanie...';
                  return AppHeader(
                    title: 'Lista zakupów',
                    subtitle: subtitle,
                    variant: AppHeaderVariant.nested,
                    backgroundColor: AppColors.primary,
                    textColor: AppColors.textWhite,
                    onBack: () => context.pop(),
                    actions: [
                      AppHeaderIconButton(
                        icon: Icons.add,
                        onPressed: () => _showAddItemSheet(context),
                      ),
                    ],
                  );
                },
              ),

              // ─── QUICK ADD BAR ───────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _quickAddController,
                        decoration: InputDecoration(
                          hintText: 'Quick add item...',
                          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14.sp),
                          prefixIcon: Icon(Icons.add_shopping_cart, color: AppColors.textMuted, size: 20.r),
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
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            context.read<ShoppingBloc>().add(
                                  AddShoppingItem(value.trim(), 1, 'piece'),
                                );
                            _quickAddController.clear();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // ─── CONTENT ───────────────────────────────────────────────────
              Expanded(
                child: BlocBuilder<ShoppingBloc, ShoppingState>(
                  builder: (context, state) {
                    if (state is ShoppingInitial || state is ShoppingLoading) {
                      return _buildShimmerList();
                    }
                    if (state is ShoppingError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, color: AppColors.error, size: 40.r),
                            SizedBox(height: 12.h),
                            Text('Failed to load shopping list.', style: AppTextStyles.bodyMedium),
                            SizedBox(height: 16.h),
                            SizedBox(
                              height: 50.h,
                              child: FilledButton(
                                onPressed: () => context.read<ShoppingBloc>().add(const LoadShoppingList()),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
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
                    if (state is ShoppingLoaded) {
                      return CustomScrollView(
                        slivers: [
                          // Move to pantry button (if purchased items exist)
                          if (state.purchasedItems.isNotEmpty)
                            SliverToBoxAdapter(
                              child: MoveToPantryButton(purchasedCount: state.purchasedItems.length),
                            ),
                          
                          // TO BUY list header
                          if (state.items.isNotEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 8.h, bottom: 8.h),
                                child: Text(
                                  'TO BUY',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          
                          // TO BUY list items
                          if (state.items.isEmpty && state.purchasedItems.isEmpty)
                            SliverFillRemaining(
                              child: Center(
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
                                        child: Icon(Icons.shopping_cart_outlined,
                                            size: 36.r, color: AppColors.textMuted),
                                      ),
                                      SizedBox(height: 24.h),
                                      Text(
                                        'Your list is empty',
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        'Add items you need to buy or get AI generated meals to auto-fill your list.',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: AppColors.textSecondary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 24.h),
                                      SizedBox(
                                        height: 50.h,
                                        width: double.infinity,
                                        child: FilledButton.icon(
                                          onPressed: () => _showAddItemSheet(context),
                                          icon: Icon(Icons.add, size: 20.r),
                                          label: Text(
                                            'Add Item',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textWhite,
                                            ),
                                          ),
                                          style: FilledButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16.r),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => ShoppingItemCard(item: state.items[index]),
                                childCount: state.items.length,
                              ),
                            ),
                            
                          // PURCHASED list header
                          if (state.purchasedItems.isNotEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 24.h, bottom: 8.h),
                                child: Row(
                                  children: [
                                    Text(
                                      'PURCHASED',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () => context.read<ShoppingBloc>().add(const ClearPurchasedItems()),
                                      child: Text(
                                        'CLEAR ALL',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                          // PURCHASED list items
                          if (state.purchasedItems.isNotEmpty)
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => PurchasedItemCard(item: state.purchasedItems[index]),
                                childCount: state.purchasedItems.length,
                              ),
                            ),
                            
                          // Padding on bottom for FAB
                          SliverToBoxAdapter(child: SizedBox(height: 80.h)),
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: AppColors.borderLight,
      highlightColor: AppColors.border,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            height: 60.h,
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(12.r),
            ),
          );
        },
      ),
    );
  }
}






