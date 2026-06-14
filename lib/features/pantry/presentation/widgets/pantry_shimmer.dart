import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class ShimmerLayout extends StatelessWidget {
  const ShimmerLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(w: 140.w, h: 24.h, r: 6.r),
                    SizedBox(height: 6.h),
                    _box(w: 100.w, h: 14.h, r: 4.r),
                  ],
                ),
              ),
              _box(w: 44.r, h: 44.r, r: 12.r),
            ],
          ),
          SizedBox(height: 16.h),
          // Search skeleton
          _box(w: double.infinity, h: 44.h, r: 12.r),
          SizedBox(height: 12.h),
          // Filter chips skeleton
          Row(
            children: [
              _box(w: 90.w, h: 32.h, r: 20.r),
              SizedBox(width: 8.w),
              _box(w: 110.w, h: 32.h, r: 20.r),
              SizedBox(width: 8.w),
              _box(w: 90.w, h: 32.h, r: 20.r),
            ],
          ),
          SizedBox(height: 20.h),
          // Promo card skeleton
          _box(w: double.infinity, h: 140.h, r: 20.r),
          SizedBox(height: 12.h),
          // Quick actions skeleton
          Row(
            children: [
              Expanded(child: _box(w: double.infinity, h: 80.h, r: 14.r)),
              SizedBox(width: 10.w),
              Expanded(child: _box(w: double.infinity, h: 80.h, r: 14.r)),
            ],
          ),
          SizedBox(height: 20.h),
          // Ingredient cards
          for (int i = 0; i < 3; i++) ...[
            _box(w: double.infinity, h: 72.h, r: 12.r),
            SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }

  Widget _box({required double w, required double h, required double r}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}

