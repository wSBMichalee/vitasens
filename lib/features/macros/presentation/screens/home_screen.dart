import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── HEADER ───────────────────────────────────────────────────
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back, Alex",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        "Today's progress",
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      border: Border.all(color: AppColors.warning),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      children: [
                        Text("✨", style: TextStyle(fontSize: 14.sp)),
                        SizedBox(width: 4.w),
                        Text(
                          "5",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: AppColors.border,
                    child: Icon(Icons.person, color: AppColors.textSecondary, size: 20.r),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // ─── MACRO CARD ────────────────────────────────────────────────
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100.w,
                      height: 100.h,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          const CircularProgressIndicator(
                            value: 0.71,
                            strokeWidth: 8,
                            color: AppColors.primary,
                            backgroundColor: Color(0xFFF3F4F6),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "1,420",
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                "KCAL LEFT",
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: Column(
                        children: [
                          const _MacroRow(
                            label: "PROTEIN",
                            value: "42",
                            total: "120G",
                            progress: 42 / 120,
                            color: AppColors.secondary,
                            isLow: true,
                          ),
                          SizedBox(height: 16.h),
                          const _MacroRow(
                            label: "CARBS",
                            value: "110",
                            total: "180G",
                            progress: 110 / 180,
                            color: AppColors.primary,
                            isLow: false,
                          ),
                          SizedBox(height: 16.h),
                          const _MacroRow(
                            label: "FAT",
                            value: "35",
                            total: "65G",
                            progress: 35 / 65,
                            color: AppColors.warning,
                            isLow: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // ─── AI INSIGHT CARD ──────────────────────────────────────────
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48.w,
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            color: AppColors.secondary,
                            size: 24.r,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Low protein today",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Hit your goals by adding high-protein options to your meals.",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      height: 44.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        onPressed: () => context.go(AppRoutes.aiMeals),
                        child: Text(
                          "ADD HIGH-PROTEIN MEAL",
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // ─── INGREDIENTS FOOTNOTE ─────────────────────────────────────
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "FROM YOUR INGREDIENTS: ",
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    TextSpan(
                      text: "CHICKEN, EGGS, SPINACH",
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),

              // ─── TODAY'S MEALS HEADER ─────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's meals",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "EDIT",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // ─── MEAL ITEMS ───────────────────────────────────────────────
              GestureDetector(
                onTap: () => context.go(AppRoutes.aiMeals),
                child: const _MealCard(
                  mealType: "BREAKFAST",
                  mealName: "Greek Berry Bowl",
                  color: AppColors.border,
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () => context.go(AppRoutes.aiMeals),
                child: const _MealCard(
                  mealType: "LUNCH",
                  mealName: "Quinoa & Grill Salad",
                  color: AppColors.border,
                ),
              ),
              SizedBox(height: 80.h), // Przestrzeń na FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.scanning),
        backgroundColor: AppColors.textPrimary,
        elevation: 4,
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: Colors.white, size: 28.r),
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final String value;
  final String total;
  final double progress;
  final Color color;
  final bool isLow;

  const _MacroRow({
    required this.label,
    required this.value,
    required this.total,
    required this.progress,
    required this.color,
    required this.isLow,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            Row(
              children: [
                Text(
                  "$value/",
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  total,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (isLow) ...[
                  SizedBox(width: 4.w),
                  Text(
                    "LOW",
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        SizedBox(height: 6.h),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: const Color(0xFFF3F4F6),
          color: color,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3.r),
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  final String mealType;
  final String mealName;
  final Color color;

  const _MealCard({
    required this.mealType,
    required this.mealName,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Icon(Icons.fastfood, color: Colors.grey),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealType,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mealName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Color(0xFFD1D5DB),
          ),
        ],
      ),
    );
  }
}
