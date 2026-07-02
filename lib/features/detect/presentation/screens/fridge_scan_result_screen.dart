import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_routes.dart';
import 'package:vitasense/core/theme/app_colors.dart';

import 'package:vitasense/l10n/app_localizations.dart';
import 'package:vitasense/features/pantry/data/pantry_repository.dart';

part '../widgets/fridge_scan/fridge_product_card.dart';
part '../widgets/fridge_scan/fridge_storage_selector.dart';

class FridgeScanResultScreen extends StatefulWidget {
  final List<dynamic> products;
  final String mode; // 'fridge' | 'receipt'

  const FridgeScanResultScreen({
    super.key,
    required this.products,
    required this.mode,
  });

  @override
  State<FridgeScanResultScreen> createState() => _FridgeScanResultScreenState();
}

class _FridgeScanResultScreenState extends State<FridgeScanResultScreen> {
  late Set<int> _selected;
  bool _isAdding = false;
  String _globalStorageLocation = 'fridge';

  // Category emoji map
  static const _categoryEmoji = {
    'dairy': '🥛',
    'meat': '🥩',
    'vegetables': '🥦',
    'fruits': '🍎',
    'grains': '🌾',
    'drinks': '🥤',
    'condiments': '🧂',
    'other': '🍽️',
  };

  @override
  void initState() {
    super.initState();
    // All selected by default
    _selected = Set.from(
      List.generate(widget.products.length, (i) => i),
    );
  }

  Map<String, List<MapEntry<int, dynamic>>> _groupByCategory() {
    final grouped = <String, List<MapEntry<int, dynamic>>>{};
    for (var i = 0; i < widget.products.length; i++) {
      final product = widget.products[i] as Map<String, dynamic>;
      final category = (product['category'] ?? 'other').toString();
      grouped.putIfAbsent(category, () => []).add(MapEntry(i, product));
    }
    return grouped;
  }

  Future<void> _addSelected() async {
    if (_selected.isEmpty) return;
    setState(() => _isAdding = true);

    final repo = PantryRepository();
    int added = 0;

    for (final idx in _selected) {
      final product = widget.products[idx] as Map<String, dynamic>;
      final name = product['name']?.toString() ?? 'Unknown';
      final qty = (product['estimatedQuantity'] ?? 1) as num;
      final unit = product['unit']?.toString() ?? 'pcs';
      final category = product['category']?.toString() ?? 'other';
      final expiryDays = (product['estimatedExpiryDays'] ?? 7) as num;
      final expiryDate = DateTime.now().add(Duration(days: expiryDays.toInt()));

      try {
        await repo.addIngredient(
          pantryId: 'default',
          name: name,
          quantity: qty.toDouble(),
          unit: unit,
          category: category,
          expiryDate: expiryDate,
          storageLocation: _globalStorageLocation,
        );
        added++;
      } catch (_) {}
    }

    if (mounted) {
      setState(() => _isAdding = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $added products to pantry ✓'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go(AppRoutes.pantry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReceipt = widget.mode == 'receipt';
    final grouped = _groupByCategory();
    final categories = grouped.keys.toList()..sort();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── SCROLLABLE CONTENT ───────────────────────────────────────────────
          CustomScrollView(
            slivers: [
              // ── APP BAR ────────────────────────────────────────────────────
              SliverAppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                pinned: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 20.r, color: AppColors.textPrimary),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  isReceipt ? 'Receipt Items' : 'Detected Products',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (_selected.length == widget.products.length) {
                          _selected.clear();
                        } else {
                          _selected = Set.from(
                            List.generate(widget.products.length, (i) => i),
                          );
                        }
                      });
                    },
                    child: Text(
                      _selected.length == widget.products.length
                          ? 'Deselect All'
                          : 'Select All',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(1.h),
                  child: const Divider(height: 1, color: AppColors.borderLight),
                ),
              ),

              // ── STORAGE SELECTOR ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                  child: FridgeStorageSelector(
                    selected: _globalStorageLocation,
                    onChanged: (val) => setState(() => _globalStorageLocation = val),
                  ),
                ),
              ),

              // ── SUMMARY CHIP ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '${widget.products.length} items detected',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '${_selected.length} selected',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── PRODUCT GROUPS ─────────────────────────────────────────────
              ...categories.map((category) {
                final items = grouped[category]!;
                final emoji = _categoryEmoji[category] ?? '🍽️';
                final categoryLabel =
                    category[0].toUpperCase() + category.substring(1);

                return SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category header
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Row(
                            children: [
                              Text(emoji,
                                  style: TextStyle(fontSize: 16.sp)),
                              SizedBox(width: 6.w),
                              Text(
                                categoryLabel,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Items
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.backgroundWhite,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: items.asMap().entries.map((entry) {
                              final itemIdx = entry.key;
                              final mapEntry = entry.value;
                              final globalIdx = mapEntry.key;
                              final product =
                                  mapEntry.value as Map<String, dynamic>;
                              final isLast = itemIdx == items.length - 1;

                              return FridgeProductCard(
                                product: product,
                                isSelected: _selected.contains(globalIdx),
                                isLast: isLast,
                                onToggle: () {
                                  setState(() {
                                    if (_selected.contains(globalIdx)) {
                                      _selected.remove(globalIdx);
                                    } else {
                                      _selected.add(globalIdx);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 8.h),
                      ],
                    ),
                  ),
                );
              }),

              SliverToBoxAdapter(child: SizedBox(height: 120.h)),
            ],
          ),

          // ── STICKY BOTTOM BAR ──────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 36.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: FilledButton(
                  onPressed: _selected.isEmpty || _isAdding
                      ? null
                      : _addSelected,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.borderLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: _isAdding
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Add ${_selected.length} items to Pantry',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
