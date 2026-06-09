import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/widgets/app_header.dart';
import 'package:vitasense/features/pantry/bloc/pantry_bloc.dart';
import 'package:vitasense/features/pantry/bloc/pantry_event.dart';
import 'package:vitasense/features/pantry/bloc/pantry_state.dart';
import 'package:vitasense/features/pantry/data/pantry_repository.dart';

class AddIngredientScreen extends StatelessWidget {
  const AddIngredientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PantryBloc(repository: PantryRepository()),
      child: const _AddIngredientView(),
    );
  }
}

class _AddIngredientView extends StatefulWidget {
  const _AddIngredientView();

  @override
  State<_AddIngredientView> createState() => _AddIngredientViewState();
}

class _AddIngredientViewState extends State<_AddIngredientView> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedName = '';
  String _displayName = '';
  double _quantity = 400;
  String _unit = 'grams';
  String _selectedExpiry = '3 days';
  DateTime? _customExpiry;
  String? _category;

  static const List<String> _commonItems = [
    'Eggs', 'Chicken', 'Milk', 'Rice', 'Spinach',
    'Tomatoes', 'Onion', 'Garlic', 'Pasta', 'Bread',
    'Cheese', 'Yogurt', 'Butter', 'Olive Oil', 'Potatoes',
    'Carrots', 'Broccoli', 'Salmon', 'Tuna', 'Beef',
    'Apple', 'Banana', 'Orange', 'Lemon', 'Avocado',
    'Mushrooms', 'Peppers', 'Cucumber', 'Lettuce', 'Oats',
    'Greek Yogurt', 'Sweet Potato', 'Zucchini', 'Shrimp', 'Turkey',
  ];

  // Replace with CDN URLs before release
  static const Map<String, String> _ingredientImages = {
    'eggs':         'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=300&q=80',
    'chicken':      'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=300&q=80',
    'milk':         'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=300&q=80',
    'rice':         'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=300&q=80',
    'spinach':      'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=300&q=80',
    'tomatoes':     'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=300&q=80',
    'onion':        'https://images.unsplash.com/photo-1508747703725-719777637510?w=300&q=80',
    'garlic':       'https://images.unsplash.com/photo-1615478503562-ec2d8aa0e24e?w=300&q=80',
    'pasta':        'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=300&q=80',
    'bread':        'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=300&q=80',
    'cheese':       'https://images.unsplash.com/photo-1552767059-ce182ead6c1b?w=300&q=80',
    'yogurt':       'https://images.unsplash.com/photo-1571212515416-fca988282d23?w=300&q=80',
    'butter':       'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=300&q=80',
    'olive oil':    'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=300&q=80',
    'potatoes':     'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=300&q=80',
    'carrots':      'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=300&q=80',
    'broccoli':     'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?w=300&q=80',
    'salmon':       'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=300&q=80',
    'tuna':         'https://images.unsplash.com/photo-1565689157206-0fddef7589a2?w=300&q=80',
    'beef':         'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=300&q=80',
    'apple':        'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=300&q=80',
    'banana':       'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=300&q=80',
    'orange':       'https://images.unsplash.com/photo-1580052614034-c55d20bfee3b?w=300&q=80',
    'lemon':        'https://images.unsplash.com/photo-1590502593747-42a996133562?w=300&q=80',
    'avocado':      'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=300&q=80',
    'mushrooms':    'https://images.unsplash.com/photo-1552825897-bb8d9e0c0f80?w=300&q=80',
    'peppers':      'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=300&q=80',
    'cucumber':     'https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?w=300&q=80',
    'lettuce':      'https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?w=300&q=80',
    'oats':         'https://images.unsplash.com/photo-1614961233913-a5113a4a34ed?w=300&q=80',
    'greek yogurt': 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=300&q=80',
    'sweet potato': 'https://images.unsplash.com/photo-1596097635121-14b63b7a0c19?w=300&q=80',
    'zucchini':     'https://images.unsplash.com/photo-1587411768638-ec71f8e33b78?w=300&q=80',
    'shrimp':       'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=300&q=80',
    'turkey':       'https://images.unsplash.com/photo-1574672280600-4accfa5b6f98?w=300&q=80',
  };

  static const Map<String, String> _displayNames = {
    'eggs':         'Eggs',
    'chicken':      'Chicken Breast',
    'milk':         'Whole Milk',
    'rice':         'White Rice',
    'spinach':      'Fresh Spinach',
    'tomatoes':     'Tomatoes',
    'onion':        'Onion',
    'garlic':       'Garlic',
    'pasta':        'Pasta',
    'bread':        'Bread',
    'cheese':       'Cheese',
    'yogurt':       'Yogurt',
    'butter':       'Butter',
    'olive oil':    'Olive Oil',
    'potatoes':     'Potatoes',
    'carrots':      'Carrots',
    'broccoli':     'Broccoli',
    'salmon':       'Salmon Fillet',
    'tuna':         'Tuna',
    'beef':         'Ground Beef',
    'apple':        'Apple',
    'banana':       'Banana',
    'orange':       'Orange',
    'lemon':        'Lemon',
    'avocado':      'Avocado',
    'mushrooms':    'Mushrooms',
    'peppers':      'Bell Peppers',
    'cucumber':     'Cucumber',
    'lettuce':      'Lettuce',
    'oats':         'Rolled Oats',
    'greek yogurt': 'Greek Yogurt',
    'sweet potato': 'Sweet Potato',
    'zucchini':     'Zucchini',
    'shrimp':       'Shrimp',
    'turkey':       'Turkey Breast',
  };

  static const Map<String, String> _categoryLabels = {
    'protein':    'PROTEIN SOURCE',
    'dairy':      'DAIRY PRODUCT',
    'grains':     'WHOLE GRAIN',
    'grain':      'WHOLE GRAIN',
    'vegetables': 'VEGETABLE',
    'vegetable':  'VEGETABLE',
    'other':      'PANTRY ITEM',
  };

  static const Map<String, String> _categoryUnits = {
    'protein':    'grams',
    'dairy':      'ml',
    'grains':     'grams',
    'grain':      'grams',
    'vegetables': 'grams',
    'vegetable':  'grams',
    'fruits':     'pieces',
    'fruit':      'pieces',
    'fats':       'ml',
    'other':      'grams',
  };

  String? get _imageUrl => _ingredientImages[_selectedName.toLowerCase()];
  String get _categoryLabel =>
      _categoryLabels[_category ?? 'other'] ?? 'PANTRY ITEM';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resolveCategory(String name) {
    final key = name.toLowerCase();
    if (key.contains('chicken') || key.contains('beef') || key.contains('fish') ||
        key.contains('egg') || key.contains('salmon') || key.contains('tuna') ||
        key.contains('shrimp') || key.contains('turkey') || key.contains('pork')) {
      _category = 'protein';
    } else if (key.contains('milk') || key.contains('cheese') || key.contains('yogurt') ||
        key.contains('butter') || key.contains('cream')) {
      _category = 'dairy';
    } else if (key.contains('rice') || key.contains('pasta') || key.contains('bread') ||
        key.contains('oat') || key.contains('flour') || key.contains('grain')) {
      _category = 'grains';
    } else if (key.contains('apple') || key.contains('banana') || key.contains('orange') ||
        key.contains('lemon') || key.contains('avocado') || key.contains('berry') ||
        key.contains('mango') || key.contains('grape') || key.contains('fruit')) {
      _category = 'fruits';
    } else if (key.contains('olive') || key.contains('oil') || key.contains('nut') ||
        key.contains('seed') || key.contains('almond') || key.contains('walnut')) {
      _category = 'fats';
    } else if (key.contains('spinach') || key.contains('broccoli') || key.contains('carrot') ||
        key.contains('tomato') || key.contains('onion') || key.contains('garlic') ||
        key.contains('potato') || key.contains('pepper') || key.contains('cucumber') ||
        key.contains('lettuce') || key.contains('mushroom') || key.contains('zucchini') ||
        key.contains('celery') || key.contains('kale') || key.contains('cabbage')) {
      _category = 'vegetables';
    } else {
      _category = 'other';
    }
    _unit = _categoryUnits[_category] ?? 'grams';
  }

  void _onSearch(String query) {
    setState(() {
      _selectedName = query;
      _displayName = query;
      _resolveCategory(query);
    });
  }

  void _selectCommon(String name) {
    final key = name.toLowerCase();
    final display = _displayNames[key] ?? name;
    _resolveCategory(name);
    setState(() {
      _selectedName = key;
      _displayName = display;
      _searchController.text = display;
    });
  }

  DateTime? _calculateExpiry() {
    final now = DateTime.now();
    switch (_selectedExpiry) {
      case '1 day':
        return now.add(const Duration(days: 1));
      case '3 days':
        return now.add(const Duration(days: 3));
      case '1 week':
        return now.add(const Duration(days: 7));
      case 'Custom':
        return _customExpiry;
      default:
        return now.add(const Duration(days: 3));
    }
  }

  void _addIngredient() {
    context.read<PantryBloc>().add(
          AddIngredient(
            name: _displayName.isNotEmpty ? _displayName : _selectedName,
            quantity: _quantity,
            unit: _unit,
            category: _category,
            expiryDate: _calculateExpiry(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<PantryBloc, PantryState>(
        listener: (context, state) {
          if (state is PantryIngredientAdded) {
            context.pop();
          } else if (state is PantryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 120.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Header ─────────────────────────────────────────
                    AppHeader(
                      title: 'Add ingredient',
                      variant: AppHeaderVariant.modal,
                      onBack: () => context.pop(),
                    ),
                    SizedBox(height: 24.h),

                    // ─── Search bar ──────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWhite,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.textPrimary.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearch,
                        style: TextStyle(
                            fontSize: 15.sp, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search or type ingredient...',
                          hintStyle: TextStyle(
                              color: AppColors.textMuted, fontSize: 15.sp),
                          prefixIcon: Icon(Icons.search,
                              color: AppColors.textMuted, size: 22.r),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 16.h),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // ─── Common items ────────────────────────────────────
                    if (_selectedName.isEmpty) ...[
                      Text(
                        'COMMON ITEMS',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        height: 40.h,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _commonItems.map((name) {
                            return GestureDetector(
                              onTap: () => _selectCommon(name),
                              child: Container(
                                margin: EdgeInsets.only(right: 8.w),
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundWhite,
                                  borderRadius: BorderRadius.circular(20.r),
                                  boxShadow: [BoxShadow(color: AppColors.textPrimary.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                                ),
                                child: Text(name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    // ─── Ingredient card ─────────────────────────────────
                    if (_selectedName.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundWhite,
                          borderRadius: BorderRadius.circular(16.r),
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
                              children: [
                                // Photo / icon
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: SizedBox(
                                    width: 72.r,
                                    height: 72.r,
                                    child: _imageUrl != null
                                        ? CachedNetworkImage(
                                            imageUrl: _imageUrl!,
                                            fit: BoxFit.cover,
                                            placeholder: (ctx, url) =>
                                                Shimmer.fromColors(
                                              baseColor: AppColors.border,
                                              highlightColor:
                                                  AppColors.borderLight,
                                              child: Container(
                                                  color: AppColors.border),
                                            ),
                                            errorWidget: (ctx, url, err) =>
                                                _fallbackIcon(),
                                          )
                                        : _fallbackIcon(),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _displayName.isNotEmpty
                                            ? _displayName
                                            : _selectedName,
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        _categoryLabel,
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.secondary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 16.h),
                            const Divider(color: AppColors.border),
                            SizedBox(height: 16.h),

                            // ─── Quantity stepper ────────────────────────
                            Row(
                              children: [
                                Text(
                                  'Quantity',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                _StepperButton(
                                  icon: Icons.remove,
                                  onTap: () {
                                    if (_quantity > 50) {
                                      setState(() => _quantity -= 50);
                                    }
                                  },
                                ),
                                SizedBox(width: 20.w),
                                Column(
                                  children: [
                                    Text(
                                      _quantity.toInt().toString(),
                                      style: TextStyle(
                                        fontSize: 26.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      _unit.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 20.w),
                                _StepperButton(
                                  icon: Icons.add,
                                  onTap: () =>
                                      setState(() => _quantity += 50),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 28.h),

                      // ─── Expiry selector ─────────────────────────────
                      Text(
                        'EXPIRES IN',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ExpiryChip(
                            label: '1 day',
                            isSelected: _selectedExpiry == '1 day',
                            onTap: () =>
                                setState(() => _selectedExpiry = '1 day'),
                          ),
                          _ExpiryChip(
                            label: '3 days',
                            isSelected: _selectedExpiry == '3 days',
                            onTap: () =>
                                setState(() => _selectedExpiry = '3 days'),
                          ),
                          _ExpiryChip(
                            label: '1 week',
                            isSelected: _selectedExpiry == '1 week',
                            onTap: () =>
                                setState(() => _selectedExpiry = '1 week'),
                          ),
                          _ExpiryChip(
                            label: 'Custom',
                            isSelected: _selectedExpiry == 'Custom',
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now()
                                    .add(const Duration(days: 3)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setState(() {
                                  _selectedExpiry = 'Custom';
                                  _customExpiry = date;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // ─── Bottom CTA ───────────────────────────────────────────
              Positioned(
                left: 20.w,
                right: 20.w,
                bottom: 32.h,
                child: BlocBuilder<PantryBloc, PantryState>(
                  builder: (context, state) {
                    final isLoading = state is PantryAddingIngredient;
                    return SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor:
                              AppColors.backgroundDark.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        onPressed: (_selectedName.isEmpty || isLoading)
                            ? null
                            : _addIngredient,
                        child: isLoading
                            ? SizedBox(
                                width: 22.r,
                                height: 22.r,
                                child: const CircularProgressIndicator(
                                  color: AppColors.textWhite,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Add to pantry',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textWhite,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      color: AppColors.borderLight,
      child: Icon(Icons.set_meal, color: AppColors.textMuted, size: 32.r),
    );
  }
}

// ─── Stepper button ────────────────────────────────────────────────────────────
class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 18.r),
      ),
    );
  }
}

// ─── Expiry chip ───────────────────────────────────────────────────────────────
class _ExpiryChip extends StatelessWidget {
  const _ExpiryChip({
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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 11.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          border: isSelected ? Border.all(
            color: AppColors.secondary,
            width: 2,
          ) : null,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: isSelected ? null : [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.secondary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
