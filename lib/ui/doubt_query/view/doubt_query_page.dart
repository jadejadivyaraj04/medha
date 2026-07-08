// lib/ui/doubt_query/view/doubt_query_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/doubt_query_controller.dart';
import '../widgets/voice_doubt_panel.dart';

class DoubtQueryPage extends GetView<DoubtQueryController> {
  const DoubtQueryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SmartAppBar(
        title: 'doubt.title'.tr,
        isBack: true,
        onBack: () => Get.back<void>(),
      ),
      body: SmartColumn(
        children: [
          Expanded(
            child: SmartSingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
              child: VoiceDoubtPanel(
                delegate: controller.voiceDoubt,
                showHero: true,
              ),
            ),
          ),
          SizedBox(height: bottomInset),
        ],
      ),
    );
  }
}
