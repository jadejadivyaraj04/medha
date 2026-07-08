// lib/ui/home/widgets/home_shimmer.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFD8E2DD),
      highlightColor: const Color(0xFFF4F8F6),
      child: SmartColumn(
        spacing: 16.h,
        children: [
          Container(
            width: double.infinity,
            height: 180.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          Container(
            width: double.infinity,
            height: 56.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ],
      ),
    );
  }
}
