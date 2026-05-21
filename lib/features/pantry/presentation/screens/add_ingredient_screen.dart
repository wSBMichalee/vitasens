import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/features/pantry/bloc/pantry_bloc.dart';
import 'package:vitasense/features/pantry/bloc/pantry_event.dart';
import 'package:vitasense/features/pantry/bloc/pantry_state.dart';
import 'package:vitasense/features/pantry/data/pantry_repository.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class AddIngredientScreen extends StatelessWidget {
  const AddIngredientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PantryBloc(
        repository: PantryRepository(),
      ),
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
  double _quantity = 400;
  final String _unit = 'grams';
  String _selectedExpiry = '3 days';
  DateTime? _customExpiry;
  String? _category;

  final List<String> _commonItems = ["Eggs", "Chicken", "Milk", "Rice", "Spinach"];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSuggestions(String query) {
    setState(() {
      _selectedName = query;
      if (_selectedName.toLowerCase().contains('chicken')) {
        _category = 'protein';
      } else {
        _category = 'other';
      }
    });
  }

  void _selectIngredient(String name) {
    setState(() {
      _selectedName = name;
      _searchController.text = name;
      if (name.toLowerCase() == 'chicken' || name.toLowerCase() == 'eggs') {
        _category = 'protein';
      } else if (name.toLowerCase() == 'milk') {
        _category = 'dairy';
      } else if (name.toLowerCase() == 'rice') {
        _category = 'grains';
      } else if (name.toLowerCase() == 'spinach') {
        _category = 'vegetables';
      } else {
        _category = 'other';
      }
    });
  }

  void _decreaseQty() {
    if (_quantity > 50) {
      setState(() => _quantity -= 50);
    }
  }

  void _increaseQty() {
    setState(() => _quantity += 50);
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
        name: _selectedName,
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
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── HEADER ──────────────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Add ingredient",
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // ─── SEARCH BAR ──────────────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterSuggestions,
                        decoration: InputDecoration(
                          hintText: "Search or type ingredient...",
                          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 15.sp),
                          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // ─── COMMON ITEMS ────────────────────────────────────────────
                    if (_selectedName.isEmpty) ...[
                      Text(
                        "COMMON ITEMS",
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 8,
                        runSpacing: 12,
                        children: _commonItems.map((name) {
                          return GestureDetector(
                            onTap: () => _selectIngredient(name),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    // ─── SELECTED INGREDIENT CARD ────────────────────────────────
                    if (_selectedName.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 64.w,
                                  height: 64.h,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(
                                    Icons.set_meal,
                                    color: AppColors.textMuted,
                                    size: 32.r,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedName,
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "PROTEIN SOURCE",
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
                            
                            // ─── QUANTITY SELECTOR ─────────────────────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Quantity",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: _decreaseQty,
                                      child: Container(
                                        width: 40.w,
                                        height: 40.h,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F4F6),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.border),
                                        ),
                                        child: Icon(Icons.remove, color: AppColors.textPrimary, size: 18.r),
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Column(
                                      children: [
                                        Text(
                                          _quantity.toInt().toString(),
                                          style: TextStyle(
                                            fontSize: 24.sp,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          _unit.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 16.w),
                                    GestureDetector(
                                      onTap: _increaseQty,
                                      child: Container(
                                        width: 40.w,
                                        height: 40.h,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F4F6),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.border),
                                        ),
                                        child: Icon(Icons.add, color: AppColors.textPrimary, size: 18.r),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32.h),

                      // ─── EXPIRY SELECTOR ───────────────────────────────────────
                      Text(
                        "EXPIRES IN",
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ExpiryChip(
                            label: "1 day",
                            isSelected: _selectedExpiry == '1 day',
                            onTap: () => setState(() => _selectedExpiry = '1 day'),
                          ),
                          _ExpiryChip(
                            label: "3 days",
                            isSelected: _selectedExpiry == '3 days',
                            onTap: () => setState(() => _selectedExpiry = '3 days'),
                          ),
                          _ExpiryChip(
                            label: "1 week",
                            isSelected: _selectedExpiry == '1 week',
                            onTap: () => setState(() => _selectedExpiry = '1 week'),
                          ),
                          _ExpiryChip(
                            label: "Custom",
                            isSelected: _selectedExpiry == 'Custom',
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(const Duration(days: 3)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
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

              // ─── BOTTOM BUTTON ─────────────────────────────────────────────
              Positioned(
                left: 20,
                right: 20,
                bottom: 32,
                child: BlocBuilder<PantryBloc, PantryState>(
                  builder: (context, state) {
                    final isLoading = state is PantryAddingIngredient;
                    return SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          disabledBackgroundColor: AppColors.textMuted,
                        ),
                        onPressed: (_selectedName.isEmpty || isLoading)
                            ? null
                            : _addIngredient,
                        child: isLoading
                            ? SizedBox(
                                width: 24.w,
                                height: 24.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Add to pantry",
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
}

class _ExpiryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExpiryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: isSelected ? AppColors.secondary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
