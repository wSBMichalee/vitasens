import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class Step22 extends StatefulWidget {
  final VoidCallback onNext;
  final bool isLoading;

  const Step22({super.key, required this.onNext, required this.isLoading});

  @override
  State<Step22> createState() => Step22State();
}

class Step22State extends State<Step22> {
  String _selectedPlan = 'yearly';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
      child: SafeArea(
        child: Column(
          children: [

            Text(
              "Start your 3-day FREE trial to continue.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w800, color: Colors.black, height: 1.2),
            ),
            SizedBox(height: 32.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTimelineStep(
                      icon: Icons.lock_open,
                      color: AppColors.primary,
                      title: "Today",
                      subtitle: "Unlock all features — meals, pantry matching, and AI suggestions.",
                      isLast: false,
                    ),
                    _buildTimelineStep(
                      icon: Icons.notifications,
                      color: Colors.orange,
                      title: "In 2 Days — Reminder",
                      subtitle: "We'll remind you before your trial ends.",
                      isLast: false,
                    ),
                    _buildTimelineStep(
                      icon: Icons.workspace_premium,
                      color: Colors.black,
                      title: "In 3 Days — Billing Starts",
                      subtitle: "You'll be charged unless you cancel anytime before.",
                      isLast: true,
                    ),
                    SizedBox(height: 32.h),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPlan = 'monthly'),
                            child: Container(
                              height: 130.h,
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
                              decoration: BoxDecoration(
                                color: _selectedPlan == 'monthly' ? const Color(0xFF2ECC71) : const Color(0xFFF2F2F7),
                                border: _selectedPlan == 'monthly' ? Border.all(color: const Color(0xFF2ECC71), width: 2) : Border.all(color: Colors.transparent, width: 2),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_selectedPlan == 'monthly')
                                    Icon(Icons.check_circle, color: Colors.white, size: 20.r),
                                  Text("Monthly", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: _selectedPlan == 'monthly' ? Colors.white : Colors.black)),
                                  SizedBox(height: 8.h),
                                  Text("\$9.99/mo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: _selectedPlan == 'monthly' ? Colors.white : Colors.black)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPlan = 'yearly'),
                            child: Stack(
                              children: [
                                Container(
                                  height: 130.h,
                                  width: double.infinity,
                                  padding: EdgeInsets.only(top: 36.h, left: 8.w, right: 8.w, bottom: 16.h),
                                  decoration: BoxDecoration(
                                    color: _selectedPlan == 'yearly' ? const Color(0xFF2ECC71) : const Color(0xFFF2F2F7),
                                    border: _selectedPlan == 'yearly' ? Border.all(color: const Color(0xFF2ECC71), width: 2) : Border.all(color: Colors.transparent, width: 2),
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_selectedPlan == 'yearly')
                                        Icon(Icons.check_circle, color: Colors.white, size: 20.r),
                                      Text("Yearly", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: _selectedPlan == 'yearly' ? Colors.white : Colors.black)),
                                      SizedBox(height: 8.h),
                                      Text("\$29.99", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: _selectedPlan == 'yearly' ? Colors.white : Colors.black)),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2ECC71),
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(12.r), topRight: Radius.circular(12.r)),
                                    ),
                                    child: Text(
                                      "3 DAYS FREE",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, color: const Color(0xFF8A8A8E), size: 16.r),
                        SizedBox(width: 8.w),
                        Text("No Payment Due Now", style: TextStyle(color: const Color(0xFF8A8A8E), fontSize: 14.sp)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: FilledButton(
                onPressed: widget.isLoading ? null : widget.onNext,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  disabledBackgroundColor: const Color(0xFF2ECC71).withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
                ),
                child: widget.isLoading
                    ? SizedBox(width: 24.r, height: 24.r, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text(
                        _selectedPlan == 'yearly' ? 'Start My 3-Day Free Trial' : 'Start Monthly Plan',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              _selectedPlan == 'yearly'
                  ? "3 days free, then \$29.99/year. Auto-renews unless cancelled."
                  : "\$9.99/month. Auto-renews unless cancelled.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF8A8A8E)),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Terms", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF8A8A8E))),
                Text(" · ", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF8A8A8E))),
                Text("Privacy", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF8A8A8E))),
                Text(" · ", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF8A8A8E))),
                Text("Restore", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF8A8A8E))),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildTimelineStep({required IconData icon, required Color color, required String title, required String subtitle, required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 20.r),
              ),
              if (!isLast) Expanded(child: Container(width: 2.w, color: const Color(0xFFE5E5EA))),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black)),
                  SizedBox(height: 4.h),
                  Text(subtitle, style: TextStyle(fontSize: 14.sp, color: const Color(0xFF8A8A8E), height: 1.3)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}