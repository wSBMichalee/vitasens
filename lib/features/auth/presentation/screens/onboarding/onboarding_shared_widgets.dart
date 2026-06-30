import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class Heading extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  const Heading(this.text, {super.key, this.textAlign = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.w800,
        color: Colors.black,
        letterSpacing: -0.5,
      ),
    );
  }
}

class Subtitle extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  const Subtitle(this.text, {super.key, this.textAlign = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: 15.sp,
        color: const Color(0xFF8A8A8E),
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class CtaButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;

  const CtaButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
  });

  @override
  State<CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<CtaButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: FilledButton(
          onPressed: widget.isLoading ? null : () {
            HapticFeedback.lightImpact();
            if (widget.onPressed != null) widget.onPressed!();
          },
          onFocusChange: (hasFocus) {
            if (hasFocus) _pressController.forward();
            else _pressController.reverse();
          },
          onHover: (isHovered) {
            if (isHovered) _pressController.forward();
            else _pressController.reverse();
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28.r),
            ),
          ).copyWith(
            overlayColor: WidgetStateProperty.all(Colors.transparent),
          ),
          child: GestureDetector(
            onTapDown: (_) => _pressController.forward(),
            onTapUp: (_) => _pressController.reverse(),
            onTapCancel: () => _pressController.reverse(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              alignment: Alignment.center,
              child: widget.isLoading
                  ? SizedBox(
                      width: 24.r,
                      height: 24.r,
                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      widget.label,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class OptionCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const OptionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  State<OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<OptionCard> with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) {
          _pressController.reverse();
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        onTapCancel: () => _pressController.reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: widget.selected ? AppColors.primary : const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: widget.selected ? [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ] : [],
          ),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    widget.icon,
                    key: ValueKey(widget.selected),
                    color: widget.selected ? Colors.white : Colors.black,
                    size: 20.r,
                  ),
                ),
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: widget.selected ? Colors.white : Colors.black,
                      ),
                      child: Text(widget.title),
                    ),
                    if (widget.subtitle != null) ...[
                      SizedBox(height: 4.h),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: widget.selected ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF8A8A8E),
                        ),
                        child: Text(widget.subtitle!),
                      ),
                    ],
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

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const InfoRow({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40.r, height: 40.r,
          decoration: const BoxDecoration(color: Color(0xFFF2F2F7), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.black, size: 20.r),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black)),
              SizedBox(height: 4.h),
              Text(subtitle, style: TextStyle(fontSize: 15.sp, color: const Color(0xFF8A8A8E))),
            ],
          ),
        ),
      ],
    );
  }
}

class UnitTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  const UnitTab({super.key, required this.title, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isSelected ? AppColors.primary : Colors.transparent, width: 2)),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.primary : const Color(0xFF8A8A8E),
          ),
        ),
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final String name;
  final String text;
  const ReviewCard({super.key, required this.name, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(14.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black)),
              SizedBox(width: 8.w),
              ...List.generate(5, (_) => Icon(Icons.star, color: Colors.amber, size: 14.r)),
            ],
          ),
          SizedBox(height: 8.h),
          Text(text, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF8A8A8E))),
        ],
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const SummaryRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: Text(label, style: TextStyle(fontSize: 15.sp, color: const Color(0xFF8A8A8E)))),
        Expanded(flex: 3, child: Text(value, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.black), textAlign: TextAlign.right)),
      ],
    );
  }
}

class AnimatedListItem extends StatelessWidget {
  final String text;
  final int delay;
  const AnimatedListItem({super.key, required this.text, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeIn,
        builder: (context, val, child) {
          return Opacity(opacity: val, child: Text(text, style: TextStyle(fontSize: 15.sp, color: Colors.black, fontWeight: FontWeight.w600)));
        },
      ).animate(delay: delay.ms),
    );
  }
}