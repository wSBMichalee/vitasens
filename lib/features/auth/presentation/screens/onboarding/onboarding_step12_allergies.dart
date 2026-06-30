import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/auth/presentation/screens/onboarding/onboarding_shared_widgets.dart';

class Step12 extends StatefulWidget {
  final List<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback? onNext;

  const Step12({super.key, required this.selected, required this.onToggle, required this.onNext});

  @override
  State<Step12> createState() => Step12State();
}

class Step12State extends State<Step12> {
  String _searchQuery = '';

  final _allOptions = [
    ("✋", "None"), ("🌾", "Gluten"), ("🥛", "Milk/Dairy"), ("🥚", "Eggs"),
    ("🐟", "Fish"), ("🦐", "Shellfish"), ("🥜", "Peanuts"), ("🌰", "Tree Nuts"),
    ("🫘", "Soy"), ("🫙", "Sesame"), ("🥬", "Celery"), ("🌿", "Mustard"),
    ("🍷", "Sulphites"), ("🫘", "Lupin"), ("🦑", "Molluscs"), ("🍓", "Strawberries"),
    ("🍊", "Citrus"), ("🥝", "Kiwi"), ("🍑", "Peach"), ("🍎", "Apple"),
    ("🍌", "Banana"), ("🥭", "Mango"), ("🥑", "Avocado"), ("🍅", "Tomato"),
    ("🍫", "Chocolate"), ("🌽", "Corn"), ("🍞", "Yeast"), ("🪵", "Cinnamon"),
    ("🥩", "Pork"), ("🐄", "Beef")
  ];

  @override
  Widget build(BuildContext context) {
    final filteredOptions = _allOptions.where((e) {
      if (_searchQuery.isEmpty) return true;
      return e.$2.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Heading("Any food allergies?"),
              SizedBox(height: 8.h),
              const Subtitle("Select all that apply — we'll never suggest these."),
              SizedBox(height: 16.h),
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search allergens...',
                  prefixIcon: Icon(Icons.search, color: const Color(0xFF8A8A8E), size: 20.r),
                  filled: true,
                  fillColor: const Color(0xFFF2F2F7),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: GridView.count(
              padding: EdgeInsets.only(bottom: 16.h),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.0,
              children: filteredOptions.map((e) {
                final isSel = widget.selected.contains(e.$2);
                return GestureDetector(
                  onTap: () => widget.onToggle(e.$2),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.primary : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(e.$1, style: TextStyle(fontSize: 36.sp)),
                        SizedBox(height: 8.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text(
                            e.$2,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: isSel ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList().animate(interval: 60.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
          child: CtaButton(onPressed: widget.onNext, label: "Continue"),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }
}