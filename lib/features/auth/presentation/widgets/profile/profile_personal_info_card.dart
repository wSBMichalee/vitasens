import 'package:flutter/material.dart';
import 'package:vitasense/features/auth/data/auth_repository.dart';
import 'profile_shimmer.dart';
import 'profile_goals_card.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/features/auth/bloc/auth_bloc.dart';
import 'package:vitasense/features/auth/bloc/auth_event.dart';
import 'package:vitasense/features/auth/data/models/user_model.dart';

class PersonalInfoCard extends StatelessWidget {
  const PersonalInfoCard({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return ProfileShimmerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Personal Info', style: AppTextStyles.headingSmall),
            ],
          ),
          SizedBox(height: 16.h),
          TagsRow(
            icon: Icons.no_food_outlined,
            iconBg: Colors.red.withValues(alpha: 0.1),
            iconColor: Colors.red,
            label: 'Allergies',
            tags: user.allergies ?? [],
            onTap: () => _showEditTagsSheet(context, 'allergies', user),
          ),
          Divider(color: AppColors.border, height: 20.h),
          TagsRow(
            icon: Icons.medical_services_outlined,
            iconBg: Colors.blue.withValues(alpha: 0.1),
            iconColor: Colors.blue,
            label: 'Health Conditions',
            tags: user.healthConditions ?? [],
            onTap: () => _showEditTagsSheet(context, 'health_conditions', user),
          ),
          Divider(color: AppColors.border, height: 20.h),
          TagsRow(
            icon: Icons.restaurant_outlined,
            iconBg: Colors.orange.withValues(alpha: 0.1),
            iconColor: Colors.orange,
            label: 'Dietary Preferences',
            tags: user.dietaryPreferences ?? [],
            onTap: () => _showEditTagsSheet(context, 'dietary_preferences', user),
          ),
        ],
      ),
    );
  }

  void _showEditTagsSheet(BuildContext context, String type, UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditTagsSheet(type: type, user: user),
    ).then((_) {
      if (context.mounted) {
        context.read<AuthBloc>().add(const AppStarted());
      }
    });
  }
}

class TagsRow extends StatelessWidget {
  const TagsRow({super.key, 
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.tags,
    this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final List<String> tags;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: tags.isNotEmpty ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10.r)),
            child: Icon(icon, color: iconColor, size: 18.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                if (tags.isNotEmpty) SizedBox(height: 8.h),
                if (tags.isNotEmpty)
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: tags.map((t) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: Text(t, style: TextStyle(fontSize: 12.sp, color: AppColors.primaryDark, fontWeight: FontWeight.w500)),
                    )).toList(),
                  )
                else
                  Text('Not set', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
          if (onTap != null) Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18.r),
        ],
      ),
    );
  }
}

class EditTagsSheet extends StatefulWidget {
  const EditTagsSheet({super.key, required this.type, required this.user});
  final String type;
  final UserModel user;

  @override
  State<EditTagsSheet> createState() => EditTagsSheetState();
}

class EditTagsSheetState extends State<EditTagsSheet> {
  final TextEditingController _controller = TextEditingController();
  late List<String> _tags;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.type == 'allergies') {
      _tags = List.from(widget.user.allergies ?? []);
    } else if (widget.type == 'health_conditions') _tags = List.from(widget.user.healthConditions ?? []);
    else _tags = List.from(widget.user.dietaryPreferences ?? []);
  }

  void _addTag() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !_tags.contains(text)) {
      setState(() {
        _tags.add(text);
        _controller.clear();
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await AuthRepository().updateProfile({widget.type: _tags});
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Edit';
    if (widget.type == 'allergies') title = 'Edit Allergies';
    if (widget.type == 'health_conditions') title = 'Edit Health Conditions';
    if (widget.type == 'dietary_preferences') title = 'Edit Dietary Preferences';

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w, height: 4.h,
                decoration: BoxDecoration(color: AppColors.borderMedium, borderRadius: BorderRadius.circular(2.r)),
              ),
            ),
            SizedBox(height: 24.h),
            Text(title, style: AppTextStyles.headingSmall),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Add new tag...',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: _addTag,
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12.r)),
                    child: Icon(Icons.add, color: Colors.white, size: 24.r),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _tags.map((t) => Chip(
                label: Text(t, style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w500)),
                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.5),
                deleteIconColor: AppColors.primaryDark,
                onDeleted: () => setState(() => _tags.remove(t)),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.r)),
              )).toList(),
            ),
            SizedBox(height: 24.h),
            SaveButton(saving: _saving, onPressed: _save),
          ],
        ),
      ),
    );
  }
}

