// lib/ui/medicines/widgets/medicine_list_shimmer.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

class MedicineListShimmer extends StatelessWidget {
  const MedicineListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SmartColumn(
      spacing: 12.h,
      children: List.generate(5, (_) => const _MedicineCardShimmer()),
    );
  }
}

class _MedicineCardShimmer extends StatelessWidget {
  const _MedicineCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFD8E2DD),
      highlightColor: const Color(0xFFF4F8F6),
      child: Container(
        width: double.infinity,
        height: 108.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }
}
