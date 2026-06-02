import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/voice/bloc/voice_bloc.dart';
import 'package:vitasense/features/voice/bloc/voice_event.dart';
import 'package:vitasense/features/voice/bloc/voice_state.dart';

class VoiceLogScreen extends StatelessWidget {
  const VoiceLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VoiceBloc(),
      child: const _VoiceLogView(),
    );
  }
}

class _VoiceLogView extends StatefulWidget {
  const _VoiceLogView();

  @override
  State<_VoiceLogView> createState() => _VoiceLogViewState();
}

class _VoiceLogViewState extends State<_VoiceLogView> {
  String _selectedMealTime = 'breakfast';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VoiceBloc, VoiceState>(
      listener: (context, state) {
        if (state is VoiceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: const TextStyle(color: Colors.white)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: SafeArea(
            child: Column(
              children: [
                // ─── HEADER ──────────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.only(top: 16.h, left: 20.w, right: 20.w),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 36.r,
                          height: 36.r,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, color: Colors.white, size: 20.r),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Voice Log',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      const Spacer(),
                      SizedBox(width: 36.r), // Balans
                    ],
                  ),
                ),

                // ─── MAIN CONTENT ────────────────────────────────────────────
                Expanded(
                  child: _buildStateContent(context, state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStateContent(BuildContext context, VoiceState state) {
    if (state is VoiceInitial || state is VoiceError) {
      return _buildInitialState(context);
    }
    if (state is VoiceListening) {
      return _buildListeningState(context);
    }
    if (state is VoiceProcessing) {
      return _buildProcessingState(state);
    }
    if (state is VoiceResult) {
      return _buildResultState(context, state);
    }
    if (state is VoiceLogged) {
      return _buildLoggedState(context);
    }
    return _buildInitialState(context);
  }

  // ─── STAN: VoiceInitial ──────────────────────────────────────────────────────
  Widget _buildInitialState(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120.r,
                  height: 120.r,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.mic_outlined, color: Colors.white, size: 56.r),
                ),
                SizedBox(height: 32.h),
                Text('Tap to start', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                SizedBox(height: 8.h),
                Text(
                  "Say what you ate, e.g.:\n'I had 2 scrambled eggs\nand toast for breakfast'",
                  style: TextStyle(fontSize: 14.sp, color: Colors.white.withValues(alpha: 0.6)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48.h),
                Column(
                  children: [
                    const _ExampleChip("🍳 'Two scrambled eggs'"),
                    SizedBox(height: 8.h),
                    const _ExampleChip("🍕 'A slice of pizza'"),
                    SizedBox(height: 8.h),
                    const _ExampleChip("🥗 'Caesar salad for lunch'"),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 48.h),
          child: GestureDetector(
            onTap: () => context.read<VoiceBloc>().add(const StartListening()),
            child: Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(Icons.mic, color: Colors.white, size: 36.r),
            ),
          ),
        ),
      ],
    );
  }

  // ─── STAN: VoiceListening ────────────────────────────────────────────────────
  Widget _buildListeningState(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 160.r,
                      height: 160.r,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 1000.ms)
                        .fadeOut(duration: 1000.ms),
                    Container(
                      width: 130.r,
                      height: 130.r,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                    )
                        .animate(delay: 200.ms, onPlay: (controller) => controller.repeat())
                        .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 1000.ms)
                        .fadeOut(duration: 1000.ms),
                    Container(
                      width: 100.r,
                      height: 100.r,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.mic, color: Colors.white, size: 44.r),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),
                Text('Listening...', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600, color: Colors.white))
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .fadeIn(duration: 500.ms)
                    .then()
                    .fadeOut(duration: 500.ms),
                SizedBox(height: 8.h),
                Text('Speak now', style: TextStyle(fontSize: 14.sp, color: Colors.white.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 48.h),
          child: GestureDetector(
            onTap: () => context.read<VoiceBloc>().add(const StopListening()),
            child: Container(
              width: 80.r,
              height: 80.r,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.stop, color: Colors.white, size: 36.r),
            ),
          ),
        ),
      ],
    );
  }

  // ─── STAN: VoiceProcessing ───────────────────────────────────────────────────
  Widget _buildProcessingState(VoiceProcessing state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
          SizedBox(height: 24.h),
          Text('Processing...', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.white)),
          SizedBox(height: 12.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              state.transcribedText,
              style: TextStyle(fontSize: 14.sp, color: Colors.white.withValues(alpha: 0.8), fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ─── STAN: VoiceResult ───────────────────────────────────────────────────────
  Widget _buildResultState(BuildContext context, VoiceResult state) {
    final parsedMeal = state.parsedMeal;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // TRANSCRIBED TEXT
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.record_voice_over, color: Colors.white.withValues(alpha: 0.6), size: 16.r),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          state.transcribedText,
                          style: TextStyle(fontSize: 13.sp, color: Colors.white.withValues(alpha: 0.7), fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),

                // PARSED MEAL CARD
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Detected Meal', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      SizedBox(height: 4.h),
                      Text('${parsedMeal['foodName'] ?? 'Unknown'}', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          _MacroBox("Calories", "${parsedMeal['calories'] ?? 0}", "kcal", AppColors.primary),
                          SizedBox(width: 8.w),
                          _MacroBox("Protein", "${parsedMeal['protein'] ?? 0}g", "protein", AppColors.proteinColor),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          _MacroBox("Carbs", "${parsedMeal['carbs'] ?? 0}g", "carbs", AppColors.carbsColor),
                          SizedBox(width: 8.w),
                          _MacroBox("Fat", "${parsedMeal['fat'] ?? 0}g", "fat", AppColors.fatColor),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Text('MEAL TIME', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          _MealTimeChip("Breakfast", "breakfast", _selectedMealTime == 'breakfast', (v) => setState(() => _selectedMealTime = v)),
                          _MealTimeChip("Lunch", "lunch", _selectedMealTime == 'lunch', (v) => setState(() => _selectedMealTime = v)),
                          _MealTimeChip("Dinner", "dinner", _selectedMealTime == 'dinner', (v) => setState(() => _selectedMealTime = v)),
                          _MealTimeChip("Snack", "snack", _selectedMealTime == 'snack', (v) => setState(() => _selectedMealTime = v)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // BOTTOM BUTTONS
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w).copyWith(bottom: 32.h, top: 16.h),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: FilledButton(
                  onPressed: () {
                    context.read<VoiceBloc>().add(LogMeal({
                          ...parsedMeal,
                          'mealTime': _selectedMealTime,
                        }));
                  },
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  child: Text('Log This Meal', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: OutlinedButton(
                  onPressed: () => context.read<VoiceBloc>().add(const ClearVoice()),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── STAN: VoiceLogged ───────────────────────────────────────────────────────
  Widget _buildLoggedState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: Colors.white, size: 40.r),
          )
              .animate()
              .scale(begin: const Offset(0, 0), end: const Offset(1, 1), curve: Curves.elasticOut, duration: 600.ms),
          SizedBox(height: 24.h),
          Text('Logged! 🎉', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700, color: Colors.white)),
          SizedBox(height: 8.h),
          Text(
            "Your meal has been added to today's log",
            style: TextStyle(fontSize: 14.sp, color: Colors.white.withValues(alpha: 0.6)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          FilledButton(
            onPressed: () => context.go(AppRoutes.home),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Done'),
          ),
          SizedBox(height: 8.h),
          TextButton(
            onPressed: () => context.read<VoiceBloc>().add(const ClearVoice()),
            child: Text('Log Another', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
          ),
        ],
      ),
    );
  }
}

// ─── HELPER WIDGETS ────────────────────────────────────────────────────────────

class _ExampleChip extends StatelessWidget {
  final String label;

  const _ExampleChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(label, style: TextStyle(fontSize: 13.sp, color: Colors.white.withValues(alpha: 0.8))),
    );
  }
}

class _MacroBox extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _MacroBox(this.label, this.value, this.unit, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _MealTimeChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final ValueChanged<String> onSelected;

  const _MealTimeChip(this.label, this.value, this.isSelected, this.onSelected);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.borderLight,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
