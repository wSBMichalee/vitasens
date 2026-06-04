import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
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
  ];

  // Replace with CDN URLs before release
  static const Map<String, String> _ingredientImages = {
    'eggs':    'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=300&q=80',
    'chicken': 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=300&q=80',
    'milk':    'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=300&q=80',
    'rice':    'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=300&q=80',
    'spinach': 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=300&q=80',
  };

  static const Map<String, String> _displayNames = {
    'eggs':    'Eggs',
    'chicken': 'Chicken Breast',
    'milk':    'Whole Milk',
    'rice':    'White Rice',
    'spinach': 'Fresh Spinach',
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
    'protein': 'grams',
    'dairy':   'ml',
    'grains':  'grams',
    'grain':   'grams',
    'vegetables': 'grams',
    'vegetable': 'grams',
    'other':   'grams',
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
    if (key.contains('chicken') || key.contains('beef') ||
        key.contains('fish') || key.contains('egg')) {
      _category = 'protein';
    } else if (key.contains('milk') || key.contains('cheese') ||
        key.contains('yogurt')) {
      _category = 'dairy';
    } else if (key.contains('rice') || key.contains('pasta') ||
        key.contains('bread') || key.contains('oat')) {
      _category = 'grains';
    } else if (key.contains('spinach') || key.contains('broccoli') ||
        key.contains('carrot') || key.contains('tomato')) {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add ingredient',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontFamily: AppTextStyles.headingLarge.fontFamily,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // ─── Search bar ──────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWhite,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.border),
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
                      Wrap(
                        spacing: 8,
                        runSpacing: 10,
                        children: _commonItems.map((name) {
                          return GestureDetector(
                            onTap: () => _selectCommon(name),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 9.h),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundWhite,
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    // ─── Ingredient card ─────────────────────────────────
                    if (_selectedName.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundWhite,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(16.r),
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
                          backgroundColor: AppColors.backgroundDark,
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
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Add to pantry',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
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
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
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
