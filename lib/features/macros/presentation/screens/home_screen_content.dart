import 'package:vitasense/features/water/bloc/water_bloc.dart';
import 'package:vitasense/features/water/bloc/water_event.dart';
import 'package:vitasense/core/widgets/gradient_scaffold.dart';
import 'package:vitasense/core/widgets/app_header.dart';
import 'package:vitasense/features/meals/bloc/daily_log_bloc.dart';
import 'package:vitasense/features/meals/bloc/daily_log_event.dart';
import 'package:vitasense/features/meals/bloc/daily_log_state.dart';
import 'package:vitasense/features/meals/data/meal_model.dart';

import 'package:vitasense/core/router/app_router.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/features/auth/data/models/user_model.dart';
import 'package:vitasense/features/water/presentation/widgets/water_card.dart';

class MockupHomeScreen extends StatefulWidget {
  const MockupHomeScreen({super.key, this.userName = 'there', this.user});
  final String userName;
  final UserModel? user;

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
        child: GradientScaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // ── HEADER ──────────────────────────────────────────────────
              AppHeader(
                title: 'Today\'s Progress',
                subtitle: 'Hello, ${widget.userName}',
                variant: AppHeaderVariant.main,
                backgroundColor: Colors.white,
                textColor: AppColors.textPrimary,
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
                      kcalGoal: widget.user?.dailyCalorieTarget ?? 2000,
                      proteinConsumed: proteinConsumed,
                      proteinGoal: widget.user?.dailyProteinTarget ?? 120,
                      carbsConsumed: carbsConsumed,
                      carbsGoal: widget.user?.dailyCarbsTarget ?? 180,
                      fatConsumed: fatConsumed,
                      fatGoal: widget.user?.dailyFatTarget ?? 65,
                    ),
                  );
                },
              ),

              // ── SCROLLABLE BODY ──────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      // ── WATER CARD ──────────────────────────────────────────────
                      WaterCard(
                        dailyWaterTarget: widget.user?.dailyWaterTarget ?? 2000,
                      ),
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
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

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