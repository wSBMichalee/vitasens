import 'macro_column.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';


class ProgressCard extends StatefulWidget {
  const ProgressCard({super.key, 
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
  State<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard> with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final Animation<double> _mainAnimation;
  
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _mainAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutCubic,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Sequence for 3 diminishing pulses
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.05).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.02).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.02, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
    ]).animate(_pulseController);

    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.kcalConsumed >= widget.kcalGoal && widget.kcalGoal > 0) {
          _pulseController.forward(from: 0.0);
        }
      }
    });

    _mainController.forward();
  }

  @override
  void didUpdateWidget(ProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.kcalConsumed != widget.kcalConsumed ||
        oldWidget.kcalGoal != widget.kcalGoal ||
        oldWidget.proteinConsumed != widget.proteinConsumed ||
        oldWidget.carbsConsumed != widget.carbsConsumed ||
        oldWidget.fatConsumed != widget.fatConsumed) {
      _pulseController.stop();
      _mainController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.5) {
      return Color.lerp(AppColors.error, Colors.orange, progress * 2) ?? Colors.orange;
    } else {
      return Color.lerp(Colors.orange, AppColors.primary, (progress - 0.5) * 2) ?? AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _pulseController]),
      builder: (context, child) {
        final double animValue = _mainAnimation.value;
        final int animatedKcal = (widget.kcalConsumed * animValue).round();
        
        final double targetProgress = (widget.kcalConsumed / widget.kcalGoal).clamp(0.0, 1.0);
        final double currentProgress = targetProgress * animValue;
        
        final Color ringColor = _getProgressColor(currentProgress);

        return Container(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                offset: const Offset(0, 4),
                color: Colors.black.withOpacity(0.06),
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
                        '$animatedKcal',
                        style: TextStyle(
                          fontSize: 48.sp,
                          height: 1.0,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'of ${widget.kcalGoal} kcal goal',
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
                  Transform.scale(
                    scale: _pulseAnimation.value,
                    child: SizedBox(
                      width: 72.r,
                      height: 72.r,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: currentProgress,
                            strokeWidth: 8.r,
                            color: ringColor,
                            backgroundColor: AppColors.borderLight,
                            strokeCap: StrokeCap.round,
                          ),
                          Text(
                            '${(currentProgress * 100).round()}%',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: ringColor,
                            ),
                          ),
                        ],
                      ),
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
                      child: MacroColumn(
                        label: 'PROTEIN',
                        consumed: widget.proteinConsumed,
                        goal: widget.proteinGoal,
                        color: AppColors.proteinColor,
                        isLow: widget.proteinConsumed / widget.proteinGoal < 0.5,
                        animationValue: animValue,
                      ),
                    ),
                    const VerticalDivider(
                      color: AppColors.borderLight,
                      thickness: 1,
                      width: 1,
                    ),
                    Expanded(
                      child: MacroColumn(
                        label: 'CARBS',
                        consumed: widget.carbsConsumed,
                        goal: widget.carbsGoal,
                        color: AppColors.carbsColor,
                        animationValue: animValue,
                      ),
                    ),
                    const VerticalDivider(
                      color: AppColors.borderLight,
                      thickness: 1,
                      width: 1,
                    ),
                    Expanded(
                      child: MacroColumn(
                        label: 'FAT',
                        consumed: widget.fatConsumed,
                        goal: widget.fatGoal,
                        color: AppColors.fatColor,
                        animationValue: animValue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}