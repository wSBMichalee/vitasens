import 'package:vitasense/features/macros/bloc/macros_bloc.dart';
import 'package:vitasense/features/macros/bloc/macros_event.dart';
import 'package:vitasense/features/macros/bloc/macros_state.dart';
import 'package:vitasense/features/macros/data/macros_repository.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_routes.dart';
import 'package:vitasense/features/water/bloc/water_bloc.dart';
import 'package:vitasense/features/water/bloc/water_event.dart';
import 'package:vitasense/core/widgets/gradient_scaffold.dart';
import 'package:vitasense/core/widgets/app_header.dart';
import 'package:vitasense/features/meals/bloc/daily_log_bloc.dart';
import 'package:vitasense/features/meals/bloc/daily_log_event.dart';
import 'package:vitasense/features/meals/bloc/daily_log_state.dart';

import 'package:vitasense/core/router/app_router.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/features/auth/data/models/user_model.dart';
import 'package:vitasense/features/water/presentation/widgets/water_card.dart';
import '../widgets/home/progress_card.dart';
import '../widgets/home/week_strip.dart';
import '../widgets/home/meal_section.dart';

class MockupHomeScreen extends StatefulWidget {
  const MockupHomeScreen({super.key, this.userName = 'there', this.user});
  final String userName;
  final UserModel? user;

  @override
  State<MockupHomeScreen> createState() => _MockupHomeScreenState();
}

class _MockupHomeScreenState extends State<MockupHomeScreen> {
  DateTime _selectedDate = DateTime.now();

  late MacrosBloc _macrosBloc;
  late WaterBloc _waterBloc;
  late DailyLogBloc _dailyLogBloc;

  @override
  void initState() {
    super.initState();
    _macrosBloc = MacrosBloc(repository: MacrosRepository());
    _waterBloc = WaterBloc();
    _dailyLogBloc = DailyLogBloc();

    final today = DateTime.now();
    final dateStr = today.toIso8601String().split('T')[0];
    _macrosBloc.add(LoadDailyMacros(dateStr));
    _waterBloc.add(LoadWater(today));
    _dailyLogBloc.add(LoadDailyLog(today));
  }

  @override
  void dispose() {
    _macrosBloc.close();
    _waterBloc.close();
    _dailyLogBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfSelected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final isPast = startOfSelected.isBefore(startOfToday);
    final isFuture = startOfSelected.isAfter(startOfToday);
    final isEditable = !isPast && !isFuture;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _macrosBloc),
        BlocProvider.value(value: _waterBloc),
        BlocProvider.value(value: _dailyLogBloc),
      ],
      child: GradientScaffold(
        floatingActionButton: isEditable
          ? SpeedDial(
              icon: Icons.add,
              activeIcon: Icons.add,
              iconTheme: const IconThemeData(color: Colors.white, size: 28),
              backgroundColor: AppColors.primary,
              shape: const CircleBorder(),
              elevation: 4,
              animationDuration: const Duration(milliseconds: 200),
              animationAngle: 3.14159 / 4,
              overlayColor: Colors.black,
              overlayOpacity: 0.15,
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.menu_book, color: Colors.white),
                  backgroundColor: AppColors.primary,
                  label: 'Scan Recipe',
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  labelBackgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  onTap: () => context.go(AppRoutes.extract),
                ),
                SpeedDialChild(
                  child: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  backgroundColor: AppColors.primary,
                  label: 'Scan Food',
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  labelBackgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  onTap: () => context.go(AppRoutes.scanning),
                ),
                SpeedDialChild(
                  child: const Icon(Icons.restaurant_menu, color: Colors.white),
                  backgroundColor: AppColors.primary,
                  label: 'Log Meal',
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  labelBackgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  onTap: () => context.go(AppRoutes.aiMeals),
                ),
              ],
            )
          : null,
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
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.progress),
                    child: BlocBuilder<MacrosBloc, MacrosState>(
                      builder: (context, state) {
                        final streak = state is MacrosLoaded ? state.streakDays : 0;
                        return Container(
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
                              Text('$streak', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                            ],
                          ),
                        );
                      },
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
              WeekStrip(
                selectedDate: _selectedDate,
                onDateSelected: (date) {
                  setState(() => _selectedDate = date);
                  final dateStr = date.toIso8601String().split('T')[0];
                  _dailyLogBloc.add(LoadDailyLog(date));
                  _macrosBloc.add(LoadDailyMacros(dateStr));
                  _waterBloc.add(LoadWater(date));
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
                    child: ProgressCard(
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
                        isEditable: isEditable,
                        selectedDate: _selectedDate,
                      ),
                      SizedBox(height: 20.h),

                      // ── AI INSIGHT CARD ───────────────────────────────────
                      if (isEditable) ...[
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
                      ],

                      // ── TODAY'S MEALS header ──────────────────────────────
                      Row(
                        children: [
                          Expanded(child: Text('Today\'s Meals', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
                          if (isEditable)
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
                              MealSection(title: 'Breakfast', mealTime: 'breakfast', isEditable: isEditable, meals: loaded?.breakfast ?? [], onDelete: (id) => _dailyLogBloc.add(DeleteMeal(id, _selectedDate))),
                              SizedBox(height: 8.h),
                              MealSection(title: 'Lunch', mealTime: 'lunch', isEditable: isEditable, meals: loaded?.lunch ?? [], onDelete: (id) => _dailyLogBloc.add(DeleteMeal(id, _selectedDate))),
                              SizedBox(height: 8.h),
                              MealSection(title: 'Dinner', mealTime: 'dinner', isEditable: isEditable, meals: loaded?.dinner ?? [], onDelete: (id) => _dailyLogBloc.add(DeleteMeal(id, _selectedDate))),
                              SizedBox(height: 8.h),
                              MealSection(title: 'Snacks', mealTime: 'snack', isEditable: isEditable, meals: loaded?.snack ?? [], onDelete: (id) => _dailyLogBloc.add(DeleteMeal(id, _selectedDate))),
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
    );
  }
}













