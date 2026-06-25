import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/pantry/bloc/pantry_bloc.dart';
import 'package:vitasense/features/pantry/bloc/pantry_state.dart';

import 'expiry_chip.dart';
import 'fallback_image_widget.dart';

class DetailsStep extends StatelessWidget {
  final String? selectedImageUrl;
  final String selectedEmoji;
  final String selectedName;
  final String selectedCategoryLabel;
  final VoidCallback onEditName;
  final String unit;
  final double quantity;
  final VoidCallback onDecreaseQuantity;
  final VoidCallback onIncreaseQuantity;
  final ValueChanged<String?> onUnitChanged;
  final String selectedExpiry;
  final VoidCallback onAddIngredient;
  final Future<void> Function(String) onExpiryTap;

  const DetailsStep({
    super.key,
    this.selectedImageUrl,
    required this.selectedEmoji,
    required this.selectedName,
    required this.selectedCategoryLabel,
    required this.onEditName,
    required this.unit,
    required this.quantity,
    required this.onDecreaseQuantity,
    required this.onIncreaseQuantity,
    required this.onUnitChanged,
    required this.selectedExpiry,
    required this.onAddIngredient,
    required this.onExpiryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected item card
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: selectedImageUrl != null && selectedImageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: selectedImageUrl!,
                          width: 56.r,
                          height: 56.r,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: Colors.grey.shade200, width: 56.r, height: 56.r),
                          errorWidget: (_, __, ___) => FallbackImageWidget(emoji: selectedEmoji),
                        )
                      : FallbackImageWidget(emoji: selectedEmoji),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedName,
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        selectedCategoryLabel.toUpperCase(),
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onEditName,
                  child: Icon(Icons.edit, color: Colors.grey.shade400, size: 20.r),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),

          // Quantity Section
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onDecreaseQuantity,
                  child: Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                    ),
                    child: const Icon(Icons.remove, color: Colors.black),
                  ),
                ),
                SizedBox(width: 32.w),
                Column(
                  children: [
                    Text(
                      unit == 'szt' ? quantity.toInt().toString() : quantity.toInt().toString(),
                      style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: unit,
                          isDense: true,
                          icon: Icon(Icons.keyboard_arrow_down, size: 16.r),
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black),
                          items: ['g', 'kg', 'ml', 'l', 'szt'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: onUnitChanged,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 32.w),
                GestureDetector(
                  onTap: onIncreaseQuantity,
                  child: Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                    ),
                    child: const Icon(Icons.add, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),

          // Expiry Section
          Text(
            'EXPIRES IN',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              ExpiryChip(
                label: '1 day',
                isSelected: selectedExpiry == '1 day',
                onTap: () => onExpiryTap('1 day'),
              ),
              ExpiryChip(
                label: '3 days',
                isSelected: selectedExpiry == '3 days',
                onTap: () => onExpiryTap('3 days'),
              ),
              ExpiryChip(
                label: '1 week',
                isSelected: selectedExpiry == '1 week',
                onTap: () => onExpiryTap('1 week'),
              ),
              ExpiryChip(
                label: '1 month',
                isSelected: selectedExpiry == '1 month',
                onTap: () => onExpiryTap('1 month'),
              ),
              ExpiryChip(
                label: 'Custom',
                isSelected: selectedExpiry == 'Custom',
                onTap: () => onExpiryTap('Custom'),
              ),
            ],
          ),
          
          SizedBox(height: 40.h),

          // Add Button
          BlocBuilder<PantryBloc, PantryState>(
            builder: (context, state) {
              final isLoading = state is PantryAddingIngredient;
              return SizedBox(
                width: double.infinity,
                height: 56.h,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  ),
                  onPressed: (quantity > 0 && !isLoading) ? onAddIngredient : null,
                  child: isLoading
                      ? SizedBox(width: 24.r, height: 24.r, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          'Add to Pantry',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              );
            },
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}
