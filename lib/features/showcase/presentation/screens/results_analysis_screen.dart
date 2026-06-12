import 'package:vitasense/core/router/app_router.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';

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