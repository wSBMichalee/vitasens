import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vitasense/core/router/app_routes.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});
  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool _loading = false;
  final _confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 24.r),
          onPressed: () => context.pop(),
        ),
        title: Text('Delete Account', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.error)),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(12.r)),
              child: Row(
                children: [
                  Icon(Icons.warning_outlined, color: AppColors.error, size: 24.r),
                  SizedBox(width: 12.w),
                  Expanded(child: Text('This action is permanent and cannot be undone. All your data will be deleted.', style: TextStyle(fontSize: 13.sp, color: AppColors.error))),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text('Type DELETE to confirm:', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            SizedBox(height: 8.h),
            TextField(
              controller: _confirmController,
              decoration: InputDecoration(
                hintText: 'DELETE',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                onPressed: _loading ? null : () async {
                  if (_confirmController.text.trim() != 'DELETE') {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Type DELETE to confirm')));
                    return;
                  }
                  setState(() => _loading = true);
                  try {
                    final userId = Supabase.instance.client.auth.currentUser?.id;
                    if (userId != null) {
                      await Supabase.instance.client.from('profiles').delete().eq('id', userId);
                    }
                    await Supabase.instance.client.auth.signOut();
                    if (context.mounted) context.go(AppRoutes.login);
                  } catch (e) {
                    setState(() => _loading = false);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                child: _loading ? const CircularProgressIndicator(color: Colors.white) : Text('Delete My Account', style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
