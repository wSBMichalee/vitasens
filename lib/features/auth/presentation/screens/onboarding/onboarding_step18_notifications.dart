import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/features/auth/presentation/screens/onboarding/onboarding_shared_widgets.dart';

class Step18 extends StatelessWidget {
  final VoidCallback onNext;
  const Step18({super.key, required this.onNext});

  Future<void> _requestNotification() async {
    await Permission.notification.request();
    onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text("🔔", style: TextStyle(fontSize: 72.sp)),
          SizedBox(height: 32.h),
          const Heading("Don't miss your meals.", textAlign: TextAlign.center),
          SizedBox(height: 16.h),
          const Subtitle("We'll remind you when it's time to eat and help you stay on track.", textAlign: TextAlign.center),
          const Spacer(),
          CtaButton(onPressed: _requestNotification, label: "Allow Notifications"),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: onNext,
            child: Text("Not now", style: TextStyle(fontSize: 16.sp, color: const Color(0xFF8A8A8E))),
          )
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}