import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryGridWidget extends StatelessWidget {
  const CategoryGridWidget({
    super.key,
    required this.onCategoryTap,
    this.onManualSelect,
  });
  final ValueChanged<String> onCategoryTap;
  final void Function(Map<String, String> category)? onManualSelect;

  static const List<Map<String, String>> categories = [
    {'name': 'Owoce', 'emoji': '🍎', 'query': 'fruit', 'color': '0xFFFFEBEE'},
    {'name': 'Warzywa', 'emoji': '🥦', 'query': 'vegetables', 'color': '0xFFE8F5E9'},
    {'name': 'Nabiał', 'emoji': '🥛', 'query': 'dairy', 'color': '0xFFE3F2FD'},
    {'name': 'Mięso', 'emoji': '🥩', 'query': 'meat', 'color': '0xFFFFEbee'},
    {'name': 'Zboża', 'emoji': '🌾', 'query': 'cereal', 'color': '0xFFFFF8E1'},
    {'name': 'Słodycze', 'emoji': '🍫', 'query': 'chocolate', 'color': '0xFFF3E5F5'},
    {'name': 'Napoje', 'emoji': '🥤', 'query': 'drinks', 'color': '0xFFE0F7FA'},
    {'name': 'Ryby', 'emoji': '🐟', 'query': 'fish', 'color': '0xFFE3F2FD'},
    {'name': 'Pieczywo', 'emoji': '🍞', 'query': 'bread', 'color': '0xFFFFF3E0'},
  ];

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KATEGORIE',
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2),
          ),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.0,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return GestureDetector(
                onTap: () {
                  if (onManualSelect != null) {
                    onManualSelect!(cat);
                  } else {
                    onCategoryTap(cat['query']!);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(int.parse(cat['color']!)),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(cat['emoji']!, style: TextStyle(fontSize: 32.sp)),
                      SizedBox(height: 8.h),
                      Text(cat['name']!, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  
  }
}
