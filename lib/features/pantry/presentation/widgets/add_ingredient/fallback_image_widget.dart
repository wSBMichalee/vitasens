import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FallbackImageWidget extends StatelessWidget {
  const FallbackImageWidget({super.key, required this.emoji, this.size = 56});
  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {

    return Container(
      width: size.r,
      height: size.r,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Text(emoji, style: TextStyle(fontSize: 24.sp)),
    );
  
  }
}
