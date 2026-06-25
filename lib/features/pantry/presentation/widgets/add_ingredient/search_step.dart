import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/pantry/data/models/product_item.dart';
import 'category_grid_widget.dart';
import 'loading_shimmer_list.dart';
import 'search_results_list.dart';

class SearchStep extends StatelessWidget {
  final bool manualEntryMode;
  final VoidCallback onEnableManualEntry;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final bool isLoading;
  final String? errorMessage;
  final List<ProductItem> searchResults;
  final ValueChanged<ProductItem> onItemTap;
  final ValueChanged<String> onCategoryGridTap;
  final Widget manualEntryStepWidget;

  const SearchStep({
    super.key,
    required this.manualEntryMode,
    required this.onEnableManualEntry,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.isLoading,
    this.errorMessage,
    required this.searchResults,
    required this.onItemTap,
    required this.onCategoryGridTap,
    required this.manualEntryStepWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (manualEntryMode) {
      return manualEntryStepWidget;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: TextButton.icon(
              onPressed: onEnableManualEntry,
              icon: Icon(Icons.edit_outlined, size: 16.r, color: AppColors.primary),
              label: Text(
                'Nie znalazłeś produktu? Dodaj ręcznie',
                style: TextStyle(fontSize: 13.sp, color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        // Search bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              style: TextStyle(fontSize: 15.sp, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search ingredient...',
                hintStyle: TextStyle(fontSize: 15.sp, color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 22.r),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        
        Padding(
          padding: EdgeInsets.only(left: 20.w, bottom: 12.h),
          child: GestureDetector(
            onTap: onClearSearch,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_ios, size: 14.r, color: AppColors.primary),
                SizedBox(width: 4.w),
                Text(
                  'Kategorie',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Search state: Grid / Loading / Error / Results
        if (searchController.text.trim().length < 2)
          CategoryGridWidget(onCategoryTap: onCategoryGridTap)
        else if (isLoading)
          const LoadingShimmerList()
        else if (errorMessage != null)
          Padding(
            padding: EdgeInsets.all(24.r),
            child: Center(
              child: Text(errorMessage!, style: TextStyle(color: AppColors.error, fontSize: 14.sp)),
            ),
          )
        else if (searchResults.isEmpty && !isLoading)
          Padding(
            padding: EdgeInsets.all(24.r),
            child: Center(
              child: Text("Brak wyników dla '${searchController.text}'", style: TextStyle(color: Colors.grey.shade500, fontSize: 15.sp)),
            ),
          )
        else
          SearchResultsList(
            items: searchResults,
            onItemTap: onItemTap,
          ),
      ],
    );
  }
}
