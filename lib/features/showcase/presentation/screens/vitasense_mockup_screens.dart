import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class MockupAiMealsScreen extends StatelessWidget {
  const MockupAiMealsScreen({super.key});

  static const _mealImage =
      'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=900&q=90';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.w, 22.h, 24.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.canPop()
                    ? context.pop()
                    : context.go(AppRoutes.pantry),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chevron_left,
                      color: AppColors.secondary,
                      size: 21.r,
                    ),
                    Text(
                      'Back to Pantry',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meals you can cook',
                          style: TextStyle(
                            fontSize: 31.sp,
                            height: 1.02,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Based on your ingredients and health goals',
                          style: TextStyle(
                            fontSize: 15.5.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _CircleIconButton(icon: Icons.tune),
                ],
              ),
              SizedBox(height: 28.h),
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: AppColors.primary,
                    size: 20.r,
                  ),
                  SizedBox(width: 9.w),
                  Expanded(
                    child: Text(
                      'YOU CAN COOK 4 MEALS WITH WHAT YOU HAVE',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 34.h),
              const Row(
                children: [
                  Expanded(child: _PillFilter(label: 'QUICK', selected: true)),
                  SizedBox(width: 8),
                  Expanded(child: _PillFilter(label: 'HIGH PROTEIN')),
                  SizedBox(width: 8),
                  Expanded(child: _PillFilter(label: 'LOW SUGAR')),
                ],
              ),
              SizedBox(height: 32.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26.r),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                      color: Colors.black.withValues(alpha: 0.04),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 318.h,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(26.r),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: _mealImage,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(26.r),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.84),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 18.h,
                            left: 18.w,
                            child: const _GreenBadge(text: 'BEST MATCH'),
                          ),
                          Positioned(
                            left: 24.w,
                            right: 24.w,
                            bottom: 28.h,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chicken Spinach Bowl',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 29.sp,
                                    height: 1,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'Best for your goals & ingredients',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.86),
                                    fontSize: 15.sp,
                                  ),
                                ),
                                SizedBox(height: 18.h),
                                Row(
                                  children: [
                                    const _MetaIcon(
                                      icon: Icons.schedule,
                                      label: '20 MIN',
                                    ),
                                    SizedBox(width: 25.w),
                                    const _MetaIcon(
                                      icon:
                                          Icons.local_fire_department_outlined,
                                      label: '480 KCAL',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 26.h, 24.w, 26.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'USES WHAT YOU HAVE:',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.6,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 22.h),
                          Wrap(
                            spacing: 10.w,
                            runSpacing: 10.h,
                            children: const [
                              _IngredientToken('Chicken'),
                              _IngredientToken('Spinach'),
                              _IngredientToken('Eggs'),
                            ],
                          ),
                          SizedBox(height: 34.h),
                          SizedBox(
                            width: double.infinity,
                            height: 62.h,
                            child: FilledButton(
                              onPressed: () {},
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.r),
                                ),
                              ),
                              child: Text(
                                'COOK THIS',
                                style: TextStyle(
                                  fontSize: 21.sp,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 23.h),
                          Center(
                            child: Text(
                              'Ready in 20 min with what you already have',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Center(
                            child: Text(
                              'INGREDIENTS WILL BE UPDATED AFTER COOKING',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.3,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MockupHomeScreen extends StatelessWidget {
  const MockupHomeScreen({super.key, this.userName = 'there'});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: SizedBox(
        width: 64.r,
        height: 64.r,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF06192A),
          elevation: 12,
          onPressed: () => context.go(AppRoutes.aiMeals),
          child: Icon(Icons.add, color: Colors.white, size: 40.r),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, $userName',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          "Today's progress",
                          style: TextStyle(
                            fontSize: 27.sp,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 48.h,
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black.withValues(alpha: 0.04),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: const Color(0xFFFACC15),
                          size: 22.r,
                        ),
                        SizedBox(width: 7.w),
                        Text(
                          '5',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 14.w),
                  CircleAvatar(
                    radius: 25.r,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 36.h),
              _ProgressCard(),
              SizedBox(height: 32.h),
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF7FF),
                  borderRadius: BorderRadius.circular(25.r),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44.r,
                          height: 44.r,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Icon(
                            Icons.auto_awesome_outlined,
                            color: AppColors.secondary,
                            size: 25.r,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Low protein today',
                                style: TextStyle(
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                'Hit your goals by adding high-protein options to your meals.',
                                style: TextStyle(
                                  height: 1.55,
                                  fontSize: 15.5.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 22.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: FilledButton(
                        onPressed: () => context.go(AppRoutes.aiMeals),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13.r),
                          ),
                        ),
                        child: Text(
                          'ADD HIGH-PROTEIN MEAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.9,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 22.h),
              Text.rich(
                TextSpan(
                  text: 'FROM YOUR INGREDIENTS: ',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                  children: const [
                    TextSpan(
                      text: 'CHICKEN, EGGS, SPINACH',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 48.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Today's meals",
                      style: TextStyle(
                        fontSize: 25.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    'EDIT',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.no_meals, color: AppColors.textMuted, size: 48.r),
                    SizedBox(height: 12.h),
                    Text(
                      'No meals logged today',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Tap + to add a meal',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProblemFatigueScreen extends StatelessWidget {
  const ProblemFatigueScreen({super.key});

  static const _image =
      'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=900&q=90';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 132.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _CircleIconButton(
                        icon: Icons.chevron_left,
                        onTap: () => context.canPop()
                            ? context.pop()
                            : context.go(AppRoutes.landing),
                      ),
                      const Expanded(child: _StepDots(active: 0)),
                      SizedBox(width: 48.w),
                    ],
                  ),
                  SizedBox(height: 72.h),
                  Text(
                    'Decision fatigue\nat the fridge?',
                    style: TextStyle(
                      fontSize: 40.sp,
                      height: 1.3,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    'Most of us spend 15 minutes a day just deciding what to eat. VitaSense solves this by turning your ingredients into healthy decisions.',
                    style: TextStyle(
                      fontSize: 24.sp,
                      height: 1.55,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 72.h),
                  SizedBox(
                    height: 258.h,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24.r),
                          child: CachedNetworkImage(
                            imageUrl: _image,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 16.w,
                          bottom: -32.h,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 17.w,
                              vertical: 15.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 22,
                                  offset: const Offset(0, 12),
                                  color: Colors.black.withValues(alpha: 0.13),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule,
                                  color: AppColors.secondary,
                                  size: 24.r,
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  'Saves 105 mins / week',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 78.h),
                  Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56.r,
                          height: 56.r,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Icon(
                            Icons.auto_awesome_outlined,
                            color: AppColors.primary,
                            size: 29.r,
                          ),
                        ),
                        SizedBox(width: 18.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Smart Pairing',
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                "We don't just find recipes. We find the right meals for your goals.",
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  height: 1.45,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 32.w,
              right: 32.w,
              bottom: 32.h,
              child: _NavyButton(
                label: 'Continue',
                onPressed: () => context.go(AppRoutes.featureMatcher),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureMatcherScreen extends StatelessWidget {
  const FeatureMatcherScreen({super.key});

  static const _image =
      'https://images.unsplash.com/photo-1618164436241-4473940d1f5c?w=900&q=90';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 66.h, 24.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10.r,
                      height: 10.r,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'CLINICAL AI MATCHER',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 38.h),
              Text(
                'Meals from what\nyou already have.',
                style: TextStyle(
                  fontSize: 40.sp,
                  height: 1.22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 56.h),
              Expanded(
                child: ListView(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(32.r),
                            child: CachedNetworkImage(
                              imageUrl: _image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            top: 24.h,
                            left: 24.w,
                            child: const _WhiteLabel('RECOGNIZED: BASIL'),
                          ),
                          Positioned(
                            top: 24.h,
                            right: 24.w,
                            child: const _WhiteLabel('MATCH: 98%'),
                          ),
                          Positioned(
                            left: 24.w,
                            right: 24.w,
                            bottom: 24.h,
                            child: Container(
                              padding: EdgeInsets.all(18.r),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'HEALTH SUGGESTION',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    'Pesto Grains Bowl',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Optimized for your Heart Health goal',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),
                    const _FeatureLine(
                      icon: Icons.center_focus_strong,
                      color: AppColors.secondary,
                      text: 'Scans your fridge for matches',
                    ),
                    SizedBox(height: 16.h),
                    const _FeatureLine(
                      icon: Icons.room_service_outlined,
                      color: AppColors.primary,
                      text: 'Suggests meals in < 30 secs',
                    ),
                    SizedBox(height: 72.h),
                    _NavyButton(
                      label: 'Next Feature',
                      onPressed: () => context.go(AppRoutes.resultsAnalysis),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultsAnalysisScreen extends StatefulWidget {
  const ResultsAnalysisScreen({super.key});

  @override
  State<ResultsAnalysisScreen> createState() => _ResultsAnalysisScreenState();
}

class _ResultsAnalysisScreenState extends State<ResultsAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF06192A);
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(40.w, 196.h, 40.w, 32.h),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(136.r, 136.r),
                    painter: _AnalysisRingPainter(_controller.value),
                    child: SizedBox(
                      width: 136.r,
                      height: 136.r,
                      child: Center(
                        child: Icon(
                          Icons.psychology_outlined,
                          color: AppColors.primary.withValues(alpha: 0.6),
                          size: 42.r,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 78.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Analyzing your kitchen...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 31.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              const _AnalysisStep('Profile matched with weight goals'),
              SizedBox(height: 24.h),
              const _AnalysisStep('Ingredient cross-referenced (12 total)'),
              SizedBox(height: 24.h),
              const _AnalysisStep('Calculating 84 possible meal combos'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 60.h,
                child: FilledButton(
                  onPressed: () => context.go(AppRoutes.aiMeals),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    disabledBackgroundColor: Colors.white.withValues(
                      alpha: 0.06,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                  child: Text(
                    'Preparing your plan...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.22),
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(26.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 6),
            color: Colors.black.withValues(alpha: 0.04),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 136.r,
            height: 136.r,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 136.r,
                  height: 136.r,
                  child: CircularProgressIndicator(
                    value: 0.82,
                    strokeWidth: 11.r,
                    color: AppColors.primary,
                    backgroundColor: AppColors.borderLight,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '1,420',
                      style: TextStyle(
                        fontSize: 29.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'KCAL LEFT',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 28.w),
          const Expanded(
            child: Column(
              children: [
                _MacroLine(
                  label: 'PROTEIN',
                  value: '42/120G',
                  status: 'LOW',
                  progress: 0.35,
                  color: AppColors.secondary,
                ),
                SizedBox(height: 27),
                _MacroLine(
                  label: 'CARBS',
                  value: '110/180G',
                  progress: 0.61,
                  color: AppColors.primary,
                ),
                SizedBox(height: 27),
                _MacroLine(
                  label: 'FAT',
                  value: '35/65G',
                  progress: 0.54,
                  color: Color(0xFFF59E0B),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroLine extends StatelessWidget {
  const _MacroLine({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
    this.status,
  });

  final String label;
  final String value;
  final String? status;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900),
            ),
            if (status != null) ...[
              SizedBox(width: 8.w),
              Text(
                status!,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.error,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 12.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8.h,
            color: color,
            backgroundColor: AppColors.borderLight,
          ),
        ),
      ],
    );
  }
}


class _PillFilter extends StatelessWidget {
  const _PillFilter({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF06192A) : Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        border: selected ? null : Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        maxLines: 1,
        style: TextStyle(
          color: selected ? Colors.white : AppColors.textPrimary,
          fontSize: 13.5.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _IngredientToken extends StatelessWidget {
  const _IngredientToken(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppColors.primary,
            size: 17.r,
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GreenBadge extends StatelessWidget {
  const _GreenBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.6,
        ),
      ),
    );
  }
}

class _MetaIcon extends StatelessWidget {
  const _MetaIcon({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 17.r),
        SizedBox(width: 7.w),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.7,
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.r,
        height: 48.r,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 4),
              color: Colors.black.withValues(alpha: 0.04),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 24.r),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.active});

  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          width: 32.w,
          height: 6.h,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: active == index ? AppColors.textPrimary : AppColors.border,
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }
}

class _NavyButton extends StatelessWidget {
  const _NavyButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60.h,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF06192A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _WhiteLabel extends StatelessWidget {
  const _WhiteLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _FeatureLine extends StatelessWidget {
  const _FeatureLine({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 17.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24.r),
          SizedBox(width: 22.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisStep extends StatelessWidget {
  const _AnalysisStep(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(Icons.check, color: AppColors.primary, size: 27.r),
          SizedBox(width: 20.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 17.sp),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisRingPainter extends CustomPainter {
  const _AnalysisRingPainter(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    final base = Paint()
      ..color = Colors.white.withValues(alpha: 0.11)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final active = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, base);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + value * math.pi * 2,
      math.pi * 1.45,
      false,
      active,
    );
  }

  @override
  bool shouldRepaint(covariant _AnalysisRingPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
