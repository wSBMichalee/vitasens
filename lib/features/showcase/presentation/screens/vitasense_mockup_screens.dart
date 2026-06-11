import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/features/meals/bloc/daily_log_bloc.dart';
import 'package:vitasense/features/meals/bloc/daily_log_event.dart';
import 'package:vitasense/features/meals/bloc/daily_log_state.dart';
import 'package:vitasense/features/meals/data/meal_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/widgets/app_header.dart';
import 'package:vitasense/features/water/bloc/water_bloc.dart';
import 'package:vitasense/features/water/bloc/water_event.dart';
import 'package:vitasense/features/water/presentation/widgets/water_card.dart';

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

class MockupHomeScreen extends StatefulWidget {
  const MockupHomeScreen({super.key, this.userName = 'there'});
  final String userName;

  @override
  State<MockupHomeScreen> createState() => _MockupHomeScreenState();
}

class _MockupHomeScreenState extends State<MockupHomeScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WaterBloc>(
      create: (context) => WaterBloc()..add(LoadWater()),
      child: BlocProvider<DailyLogBloc>(
        create: (_) => DailyLogBloc()..add(LoadDailyLog(_selectedDate)),
        child: Scaffold(
          backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER ──────────────────────────────────────────────────
              AppHeader(
                title: 'Today\'s Progress',
                subtitle: 'Hello, ${widget.userName}',
                variant: AppHeaderVariant.main,
                backgroundColor: AppColors.primary,
                textColor: AppColors.textWhite,
                actions: [
                  Container(
                    height: 36.r,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundWhite,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department_rounded, color: const Color(0xFFFACC15), size: 16.r),
                        SizedBox(width: 4.w),
                        Text('5', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.profile),
                    child: CircleAvatar(
                      radius: 18.r,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 16.r,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
                          style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── WEEK STRIP (styl Fitollo) ───────────────────────────────
              _WeekStrip(
                selectedDate: _selectedDate,
                onDateSelected: (date) {
                  setState(() => _selectedDate = date);
                  context.read<DailyLogBloc>().add(LoadDailyLog(date));
                },
              ),



              // ── PROGRESS RING CARD ──────────────────────────────────────
              BlocBuilder<DailyLogBloc, DailyLogState>(
                builder: (context, state) {
                  final kcalConsumed = state is DailyLogLoaded ? state.totalCalories : 0;
                  final proteinConsumed = state is DailyLogLoaded ? state.totalProtein.round() : 0;
                  final carbsConsumed = state is DailyLogLoaded ? state.totalCarbs.round() : 0;
                  final fatConsumed = state is DailyLogLoaded ? state.totalFat.round() : 0;
                  return Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                    child: _ProgressCard(
                      kcalConsumed: kcalConsumed,
                      kcalGoal: 2500,
                      proteinConsumed: proteinConsumed,
                      proteinGoal: 120,
                      carbsConsumed: carbsConsumed,
                      carbsGoal: 180,
                      fatConsumed: fatConsumed,
                      fatGoal: 65,
                    ),
                  );
                },
              ),

              // ── SCROLLABLE BODY ──────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── WATER CARD ──────────────────────────────────────────────
                      const WaterCard(),
                      SizedBox(height: 20.h),

                      // ── AI INSIGHT CARD ───────────────────────────────────
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40.r, height: 40.r,
                              decoration: BoxDecoration(color: AppColors.backgroundWhite, borderRadius: BorderRadius.circular(10.r)),
                              child: Icon(Icons.auto_awesome_outlined, color: AppColors.primary, size: 20.r),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Low protein today', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                  Text('Add a high-protein meal to reach your daily goal.', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary, height: 1.4)),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: () => context.go(AppRoutes.aiMeals),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20.r)),
                                child: Text('Add', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // ── TODAY'S MEALS header ──────────────────────────────
                      Row(
                        children: [
                          Expanded(child: Text('Today\'s Meals', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
                          GestureDetector(
                            onTap: () {},
                            child: Text('EDIT', style: TextStyle(color: AppColors.primary, fontSize: 12.sp, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      // ── MEAL SECTIONS (styl Fitollo) ──────────────────────
                      BlocBuilder<DailyLogBloc, DailyLogState>(
                        builder: (context, state) {
                          final loaded = state is DailyLogLoaded ? state : null;
                          return Column(
                            children: [
                              _MealSection(title: 'Breakfast', mealTime: 'breakfast', meals: loaded?.breakfast ?? [], onDelete: (id) => context.read<DailyLogBloc>().add(DeleteMeal(id, _selectedDate))),
                              SizedBox(height: 8.h),
                              _MealSection(title: 'Lunch', mealTime: 'lunch', meals: loaded?.lunch ?? [], onDelete: (id) => context.read<DailyLogBloc>().add(DeleteMeal(id, _selectedDate))),
                              SizedBox(height: 8.h),
                              _MealSection(title: 'Dinner', mealTime: 'dinner', meals: loaded?.dinner ?? [], onDelete: (id) => context.read<DailyLogBloc>().add(DeleteMeal(id, _selectedDate))),
                              SizedBox(height: 8.h),
                              _MealSection(title: 'Snacks', mealTime: 'snack', meals: loaded?.snack ?? [], onDelete: (id) => context.read<DailyLogBloc>().add(DeleteMeal(id, _selectedDate))),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

/// Karta postępu: duże kalorie na górze, makra jako poziomy rząd 3 kolumn.
/// Nie ma hardkodowanych danych produkcyjnych — wartości są parametrami.
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    this.kcalConsumed = 1080,
    this.kcalGoal = 2500,
    this.proteinConsumed = 42,
    this.proteinGoal = 120,
    this.carbsConsumed = 110,
    this.carbsGoal = 180,
    this.fatConsumed = 35,
    this.fatGoal = 65,
  });

  final int kcalConsumed;
  final int kcalGoal;
  final int proteinConsumed;
  final int proteinGoal;
  final int carbsConsumed;
  final int carbsGoal;
  final int fatConsumed;
  final int fatGoal;

  @override
  Widget build(BuildContext context) {
    final double kcalProgress =
        (kcalConsumed / kcalGoal).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 6),
            color: Colors.black.withValues(alpha: 0.04),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── KALORIE — hierarchia priorytet 1 ──────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$kcalConsumed',
                    style: TextStyle(
                      fontSize: 48.sp,
                      height: 1.0,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'of $kcalGoal kcal goal',
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.5,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Mini kołowy wskaźnik kalorii
              SizedBox(
                width: 64.r,
                height: 64.r,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: kcalProgress,
                      strokeWidth: 7.r,
                      color: AppColors.primary,
                      backgroundColor: AppColors.borderLight,
                      strokeCap: StrokeCap.round,
                    ),
                    Text(
                      '${(kcalProgress * 100).round()}%',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // ── LINIA PODZIAŁU ──────────────────────────────────────────────
          const Divider(
            color: AppColors.borderLight,
            thickness: 1,
            height: 1,
          ),

          SizedBox(height: 24.h),

          // ── MAKRA — poziomy rząd 3 kolumn (bez overflow) ───────────────
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _MacroColumn(
                    label: 'PROTEIN',
                    consumed: proteinConsumed,
                    goal: proteinGoal,
                    color: AppColors.proteinColor,
                    isLow: proteinConsumed / proteinGoal < 0.5,
                  ),
                ),
                const VerticalDivider(
                  color: AppColors.borderLight,
                  thickness: 1,
                  width: 1,
                ),
                Expanded(
                  child: _MacroColumn(
                    label: 'CARBS',
                    consumed: carbsConsumed,
                    goal: carbsGoal,
                    color: AppColors.carbsColor,
                  ),
                ),
                const VerticalDivider(
                  color: AppColors.borderLight,
                  thickness: 1,
                  width: 1,
                ),
                Expanded(
                  child: _MacroColumn(
                    label: 'FAT',
                    consumed: fatConsumed,
                    goal: fatGoal,
                    color: AppColors.fatColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kolumna makroskładnika — label + wartość + progress bar.
/// Używana w poziomym rzędzie 3 kolumn → brak overflow.
class _MacroColumn extends StatelessWidget {
  const _MacroColumn({
    required this.label,
    required this.consumed,
    required this.goal,
    required this.color,
    this.isLow = false,
  });

  final String label;
  final int consumed;
  final int goal;
  final Color color;
  final bool isLow;

  @override
  Widget build(BuildContext context) {
    final double progress = (consumed / goal).clamp(0.0, 1.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etykieta + status LOW
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              if (isLow) ...[  
                SizedBox(width: 4.w),
                Text(
                  '↓',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 6.h),
          // Wartość
          Text(
            '${consumed}g',
            style: TextStyle(
              fontSize: 20.sp,
              height: 1.1,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'of ${goal}g',
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.5,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10.h),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6.h,
              color: color,
              backgroundColor: AppColors.borderLight,
            ),
          ),
        ],
      ),
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

/// Pasek tygodnia w stylu Fitollo — litera + numer, aktywny podkreślony
class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.selectedDate, required this.onDateSelected});
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      color: AppColors.backgroundWhite,
      padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final day = days[i];
              final isSelected = day.day == selectedDate.day && day.month == selectedDate.month;
              final isToday = day.day == today.day && day.month == today.month;
              return GestureDetector(
                onTap: () => onDateSelected(day),
                child: SizedBox(
                  width: 40.r,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dayLabels[i],
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.textMuted,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : (isToday ? AppColors.textPrimary : AppColors.textSecondary),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2.h,
                        width: isSelected ? 24.w : 0,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              );
            }),
          ),
          const Divider(color: AppColors.borderLight, height: 1, thickness: 1),
        ],
      ),
    );
  }
}

/// Górny pasek makr w stylu Fitollo — kcal / białko / tłuszcze / węgle z progress line
class _MacroSummaryBar extends StatelessWidget {
  const _MacroSummaryBar({
    required this.kcalConsumed, required this.kcalGoal,
    required this.proteinConsumed, required this.proteinGoal,
    required this.fatConsumed, required this.fatGoal,
    required this.carbsConsumed, required this.carbsGoal,
  });

  final int kcalConsumed, kcalGoal;
  final int proteinConsumed, proteinGoal;
  final int fatConsumed, fatGoal;
  final int carbsConsumed, carbsGoal;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundWhite,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      child: Row(
        children: [
          _MacroBarItem(label: 'Protein', consumed: proteinConsumed, goal: proteinGoal, unit: 'g', color: AppColors.proteinColor),
          _MacroBarItem(label: 'Fat', consumed: fatConsumed, goal: fatGoal, unit: 'g', color: AppColors.fatColor),
          _MacroBarItem(label: 'Carbs', consumed: carbsConsumed, goal: carbsGoal, unit: 'g', color: AppColors.carbsColor, isLast: true),
        ],
      ),
    );
  }
}

class _MacroBarItem extends StatelessWidget {
  const _MacroBarItem({
    required this.label, required this.consumed, required this.goal,
    required this.unit, required this.color, this.isLast = false,
  });

  final String label, unit;
  final int consumed, goal;
  final Color color;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final progress = (consumed / goal).clamp(0.0, 1.0);
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: isLast ? 0 : 12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              unit == 'kcal' ? '$consumed kcal' : '$consumed/$goal$unit',
              style: TextStyle(fontSize: unit == 'kcal' ? 10.sp : 11.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            SizedBox(height: 2.h),
            Text(label, style: TextStyle(fontSize: 10.sp, color: AppColors.textMuted)),
            SizedBox(height: 4.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(2.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3.h,
                backgroundColor: AppColors.borderLight,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sekcja posiłku w stylu Fitollo (Breakfast/Lunch/Dinner/Snacks)
class _MealSection extends StatefulWidget {
  const _MealSection({
    required this.title,
    required this.mealTime,
    required this.meals,
    required this.onDelete,
  });

  final String title;
  final String mealTime;
  final List<MealModel> meals;
  final void Function(String mealId) onDelete;

  @override
  State<_MealSection> createState() => _MealSectionState();
}

class _MealSectionState extends State<_MealSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final totalKcal = widget.meals.fold(0, (sum, m) => sum + m.calories);
    final totalP = widget.meals.fold(0.0, (sum, m) => sum + m.proteinG);
    final totalC = widget.meals.fold(0.0, (sum, m) => sum + m.carbsG);
    final totalF = widget.meals.fold(0.0, (sum, m) => sum + m.fatG);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: AppColors.textPrimary.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Header sekcji
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 12.w, 14.h),
              child: Row(
                children: [
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                    size: 20.r,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        Text(
                          '$totalKcal kcal  •  P: ${totalP.round()}g  C: ${totalC.round()}g  F: ${totalF.round()}g',
                          style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.aiMeals),
                    child: Container(
                      width: 32.r, height: 32.r,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(Icons.add, color: AppColors.primary, size: 20.r),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Empty state gdy brak posiłków
          if (_expanded && widget.meals.isEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Text('No meals added', style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted)),
                ),
              ),
            ),
          // Lista posiłków
          if (_expanded && widget.meals.isNotEmpty)
            ...widget.meals.map((meal) => Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(meal.foodName, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        Text('${meal.calories} kcal  •  P: ${meal.proteinG.round()}g  C: ${meal.carbsG.round()}g  F: ${meal.fatG.round()}g',
                          style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => widget.onDelete(meal.id),
                    child: Icon(Icons.delete_outline, color: AppColors.textMuted, size: 18.r),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }
}
