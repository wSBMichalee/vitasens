import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/pantry/data/models/ingredient_model.dart';

class ExpiryItem extends StatelessWidget {
  const ExpiryItem({super.key, required this.ingredient});

  final IngredientModel ingredient;

  static const Map<String, String> _categoryImages = {
    'protein':    'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=200&q=80',
    'vegetables': 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=200&q=80',
    'vegetable':  'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=200&q=80',
    'dairy':      'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=200&q=80',
    'grains':     'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=200&q=80',
    'grain':      'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=200&q=80',
  };

  @override
  Widget build(BuildContext context) {
    final days = ingredient.expiryDate?.difference(DateTime.now()).inDays ?? 0;
    final imageUrl = _categoryImages[ingredient.category.toLowerCase()];

    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: SizedBox(
              width: 44.r,
              height: 44.r,
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: AppColors.border,
                        highlightColor: AppColors.borderLight,
                        child: Container(color: AppColors.border),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.warningLight,
                        child: Icon(Icons.eco, color: AppColors.warning, size: 20.r),
                      ),
                    )
                  : Container(
                      color: AppColors.warningLight,
                      child: Icon(Icons.eco, color: AppColors.warning, size: 20.r),
                    ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.name,
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  days <= 0 ? 'Today' : days == 1 ? 'Tomorrow' : '$days days',
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.warningDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

