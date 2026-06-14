import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/pantry/data/models/ingredient_model.dart';
import 'pantry_emoji_helper.dart';

class ExpiryItem extends StatelessWidget {
  const ExpiryItem({super.key, required this.ingredient});

  final IngredientModel ingredient;



  @override
  Widget build(BuildContext context) {
    final days = ingredient.expiryDate?.difference(DateTime.now()).inDays ?? 0;
    final nameEmoji = emojiForName(ingredient.name);
    final emoji = nameEmoji.isNotEmpty ? nameEmoji : emojiForCategory(ingredient.category);
    final bgColor = colorForCategory(ingredient.category);

    Widget placeholder() => Container(
      color: bgColor,
      alignment: Alignment.center,
      child: Text(emoji, style: TextStyle(fontSize: 22.r)),
    );

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
              child: (ingredient.imageUrl != null && ingredient.imageUrl!.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: ingredient.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: AppColors.border,
                        highlightColor: AppColors.borderLight,
                        child: Container(color: AppColors.border),
                      ),
                      errorWidget: (_, __, ___) => placeholder(),
                    )
                  : placeholder(),
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

