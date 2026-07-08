// lib/ui/adherence_history/widgets/adherence_shimmer.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

class AdherenceShimmer extends StatelessWidget {
  const AdherenceShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SmartColumn(
      spacing: 12.h,
      children: [
        Shimmer.fromColors(
          baseColor: const Color(0xFFD8E2DD),
          highlightColor: const Color(0xFFF4F8F6),
          child: Container(
            width: double.infinity,
            height: 120.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
        Shimmer.fromColors(
          baseColor: const Color(0xFFD8E2DD),
          highlightColor: const Color(0xFFF4F8F6),
          child: Container(
            width: double.infinity,
            height: 220.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
        ...List.generate(4, (_) {
          return Shimmer.fromColors(
            baseColor: const Color(0xFFD8E2DD),
            highlightColor: const Color(0xFFF4F8F6),
            child: Container(
              width: double.infinity,
              height: 64.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          );
        }),
      ],
    );
  }
}
