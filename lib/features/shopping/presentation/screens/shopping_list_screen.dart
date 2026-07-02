import 'package:vitasense/core/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/features/shopping/bloc/shopping_bloc.dart';
import 'package:vitasense/features/shopping/bloc/shopping_event.dart';
import 'package:vitasense/features/shopping/bloc/shopping_state.dart';
import 'package:vitasense/features/shopping/data/models/shopping_item_model.dart';
import '../widgets/shopping_item_card.dart';
import 'package:vitasense/core/utils/bottom_sheet_utils.dart';
import 'package:vitasense/features/pantry/bloc/pantry_bloc.dart';
import 'package:vitasense/features/pantry/bloc/pantry_event.dart';
import 'package:vitasense/core/widgets/app_header.dart';

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

class _ShoppingListViewState extends State<_ShoppingListView> with SingleTickerProviderStateMixin {
  final TextEditingController _quickAddController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      if (_tabController.index == 1) {
        context.read<ShoppingBloc>().add(const LoadShoppingHistory());
      } else {
        context.read<ShoppingBloc>().add(const LoadShoppingList());
      }
    }
  }

  @override
  void dispose() {
    _quickAddController.dispose();
    _tabController.dispose();
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

  String _monthName(int month) {
    const months = ['sty', 'lut', 'mar', 'kwi', 'maj', 'cze', 'lip', 'sie', 'wrz', 'paź', 'lis', 'gru'];
    return months[month - 1];
  }

  Map<String, List<ShoppingItemModel>> _groupByDate(List<ShoppingItemModel> items) {
    final groups = <String, List<ShoppingItemModel>>{};
    for (final item in items) {
      final date = item.purchasedAt ?? item.createdAt ?? DateTime.now();
      String label;
      final now = DateTime.now();
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        label = 'Dzisiaj';
      } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
        label = 'Wczoraj';
      } else {
        label = '${date.day} ${_monthName(date.month)} ${date.year}';
      }
      groups.putIfAbsent(label, () => []).add(item);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShoppingBloc, ShoppingState>(
      listener: (context, state) {
        if (state is ShoppingError) {
          SnackbarUtils.showError(context, state.message);
        } else if (state is ShoppingMovedToPantry) {
          context.read<PantryBloc>().add(const LoadPantry());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppHeader(
                    title: 'Shopping List',
                    subtitle: 'Manage your groceries',
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.add, color: AppColors.textPrimary),
                        onPressed: () => _showAddItemSheet(context),
                      ),
                    ],
                  ),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.primary,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Lista zakupów'),
                      Tab(text: 'Historia'),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(), // Disable swipe to avoid Bloc mismatches during transition
                      children: [
                        _buildActiveListTab(),
                        _buildHistoryTab(),
                      ],
                    ),
                  ),
                ],
              ),
              if (_tabController.index == 0)
                Positioned(
                  bottom: 22.h,
                  right: 16.w,
                  child: FloatingActionButton(
                    onPressed: () => _showAddItemSheet(context),
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveListTab() {
    return BlocBuilder<ShoppingBloc, ShoppingState>(
      buildWhen: (previous, current) => current is ShoppingLoaded || current is ShoppingLoading || current is ShoppingError,
      builder: (context, state) {
        if (state is ShoppingInitial || state is ShoppingLoading) {
          return _buildShimmerList();
        }
        if (state is ShoppingError) {
          return _buildErrorState();
        }
        if (state is ShoppingLoaded) {
          return Column(
            children: [
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
                          fillColor: AppColors.background,
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
              if (state.items.isEmpty)
                Expanded(
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
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 80.h),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      return ShoppingItemCard(item: state.items[index]);
                    },
                  ),
                ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildHistoryTab() {
    return BlocBuilder<ShoppingBloc, ShoppingState>(
      buildWhen: (previous, current) => current is ShoppingHistoryLoaded || current is ShoppingLoading || current is ShoppingError,
      builder: (context, state) {
        if (state is ShoppingInitial || state is ShoppingLoading) {
          return _buildShimmerList();
        }
        if (state is ShoppingError) {
          return _buildErrorState();
        }
        if (state is ShoppingHistoryLoaded) {
          if (state.history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64.r, color: AppColors.border),
                  SizedBox(height: 16.h),
                  Text(
                    'Brak historii zakupów',
                    style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          final groups = _groupByDate(state.history);
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h).copyWith(bottom: 80.h),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final dateLabel = groups.keys.elementAt(index);
              final items = groups[dateLabel]!;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
                    child: Text(
                      '$dateLabel • ${items.length} produktów',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  ...items.map((item) => Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundWhite,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textPrimary.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40.r,
                          height: 40.r,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: Text(
                              getCategoryEmoji(item.name, item.category),
                              style: TextStyle(fontSize: 20.sp),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(Icons.check_circle, color: AppColors.primary, size: 20.r),
                            SizedBox(height: 4.h),
                            Text(
                              'kupiono',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
                ],
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 40.r),
          SizedBox(height: 12.h),
          Text('Failed to load.', style: AppTextStyles.bodyMedium),
          SizedBox(height: 16.h),
          SizedBox(
            height: 50.h,
            child: FilledButton(
              onPressed: () {
                if (_tabController.index == 0) {
                  context.read<ShoppingBloc>().add(const LoadShoppingList());
                } else {
                  context.read<ShoppingBloc>().add(const LoadShoppingHistory());
                }
              },
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
