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
import 'package:vitasense/l10n/app_localizations.dart';

part '../widgets/tabs/shopping_active_tab.dart';
part '../widgets/tabs/shopping_history_tab.dart';

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
                  Text(AppLocalizations.of(context)!.addItem, style: AppTextStyles.headingMedium),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.itemName,
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
                            labelText: AppLocalizations.of(context)!.quantity,
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
                        AppLocalizations.of(context)!.addToList,
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
                    title: AppLocalizations.of(context)!.shoppingList,
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
                    tabs: [
                      Tab(text: AppLocalizations.of(context)!.shoppingList),
                      Tab(text: AppLocalizations.of(context)!.history),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(), // Disable swipe to avoid Bloc mismatches during transition
                      children: [
                        BlocBuilder<ShoppingBloc, ShoppingState>(
                          buildWhen: (previous, current) => current is ShoppingLoaded || current is ShoppingLoading || current is ShoppingError,
                          builder: (context, state) {
                            if (state is ShoppingInitial || state is ShoppingLoading) {
                              return _buildShimmerList();
                            }
                            if (state is ShoppingError) {
                              return _buildErrorState();
                            }
                            if (state is ShoppingLoaded) {
                              return ShoppingActiveTab(
                                items: state.items,
                                quickAddController: _quickAddController,
                                onQuickAdd: (value) {
                                  if (value.trim().isNotEmpty) {
                                    context.read<ShoppingBloc>().add(
                                          AddShoppingItem(value.trim(), 1, 'piece'),
                                        );
                                    _quickAddController.clear();
                                  }
                                },
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                        BlocBuilder<ShoppingBloc, ShoppingState>(
                          buildWhen: (previous, current) => current is ShoppingHistoryLoaded || current is ShoppingLoading || current is ShoppingError,
                          builder: (context, state) {
                            if (state is ShoppingInitial || state is ShoppingLoading) {
                              return _buildShimmerList();
                            }
                            if (state is ShoppingError) {
                              return _buildErrorState();
                            }
                            if (state is ShoppingHistoryLoaded) {
                              return ShoppingHistoryTab(
                                history: state.history,
                              );
                            }
                            return const SizedBox();
                          },
                        ),
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

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 40.r),
          SizedBox(height: 12.h),
          Text(AppLocalizations.of(context)!.failedToLoad, style: AppTextStyles.bodyMedium),
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
                AppLocalizations.of(context)!.tryAgain,
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
