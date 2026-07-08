// lib/ui/shell/view/main_shell_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../home/view/home_page.dart';
import '../../medicines/view/medicines_page.dart';
import '../../profile/view/profile_page.dart';
import '../../reminders/view/reminders_page.dart';
import '../controller/shell_controller.dart';
import '../widgets/rag_indexing_banner.dart';
import '../widgets/scan_fab.dart';
import '../widgets/shell_bottom_bar.dart';

class MainShellPage extends GetView<ShellController> {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.background,
        body: SmartColumn(
          children: [
            const RagIndexingBanner(),
            Expanded(
              child: IndexedStack(
                index: controller.currentIndex.value,
                children: const [
                  HomePage(),
                  MedicinesPage(),
                  RemindersPage(),
                  ProfilePage(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: ScanFab(onTap: controller.openScan),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: const ShellBottomBar(),
      ),
    );
  }
}
