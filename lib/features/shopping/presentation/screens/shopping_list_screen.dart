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
import 'package:vitasense/features/shopping/data/models/shopping_item_model.dart';

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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
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
                            Text('Failed to load shopping list.', style: AppTextStyles.bodyMedium),
                            SizedBox(height: 8.h),
                            ElevatedButton(
                              onPressed: () => context.read<ShoppingBloc>().add(const LoadShoppingList()),
                              child: const Text('Retry'),
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
                              child: _MoveToPantryButton(purchasedCount: state.purchasedItems.length),
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
                            const SliverFillRemaining(
                              child: Center(
                                child: Text('Your shopping list is empty', style: TextStyle(color: AppColors.textSecondary)),
                              ),
                            )
                          else
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _ShoppingItemCard(item: state.items[index]),
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
                                (context, index) => _PurchasedItemCard(item: state.purchasedItems[index]),
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

class _MoveToPantryButton extends StatelessWidget {
  final int purchasedCount;

  const _MoveToPantryButton({required this.purchasedCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.kitchen, color: AppColors.primary, size: 20.r),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Move purchased to pantry',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '$purchasedCount items ready',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => context.read<ShoppingBloc>().add(const MoveAllToPantry()),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
            ),
            child: const Text('MOVE'),
          ),
        ],
      ),
    );
  }
}

class _ShoppingItemCard extends StatelessWidget {
  final ShoppingItemModel item;

  const _ShoppingItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        context.read<ShoppingBloc>().add(DeleteShoppingItem(item.id));
      },
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: Icon(Icons.delete, color: AppColors.textWhite, size: 24.r),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => context.read<ShoppingBloc>().add(MarkItemPurchased(item.id)),
              child: Container(
                width: 24.r,
                height: 24.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 2),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 1)} ${item.unit}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.drag_handle, color: AppColors.textMuted, size: 20.r),
          ],
        ),
      ),
    );
  }
}

class _PurchasedItemCard extends StatelessWidget {
  final ShoppingItemModel item;

  const _PurchasedItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        context.read<ShoppingBloc>().add(DeleteShoppingItem(item.id));
      },
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: Icon(Icons.delete, color: AppColors.textWhite, size: 24.r),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 24.r,
              height: 24.r,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: Icon(Icons.check, color: AppColors.textWhite, size: 16.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 1)} ${item.unit}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textMuted,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.drag_handle, color: AppColors.textMuted, size: 20.r),
          ],
        ),
      ),
    );
  }
}
