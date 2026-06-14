import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'fallback_image_widget.dart';
import '../../../data/models/product_item.dart';

class SearchResultsList extends StatelessWidget {
  const SearchResultsList({super.key, required this.items, required this.onItemTap});
  final List<ProductItem> items;
  final ValueChanged<ProductItem> onItemTap;

  @override
  Widget build(BuildContext context) {

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => onItemTap(item),
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: item.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.imageUrl,
                          width: 56.r,
                          height: 56.r,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: Colors.grey.shade200, width: 56.r, height: 56.r),
                          errorWidget: (_, __, ___) => FallbackImageWidget(emoji: item.categoryEmoji),
                        )
                      : FallbackImageWidget(emoji: item.categoryEmoji),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.brandName != null ? '${item.brandName} ${item.name}' : item.name,
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        item.categoryLabel,
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                      ),
                      if (item.description.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          item.description,
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  child: Icon(Icons.add, color: AppColors.primary, size: 20.r),
                ),
              ],
            ),
          ),
        );
      },
    );
  
  }
}
