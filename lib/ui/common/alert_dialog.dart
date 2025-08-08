import 'package:flutter/material.dart';

import '../../shared/app_colors.dart';
import '../../ui/common/ui_helpers.dart';

class AlertDialogApp extends StatelessWidget {
  final String message;
  final VoidCallback? onOkTap;
  final VoidCallback? onVerifyTap;

  const AlertDialogApp({
    super.key,
    required this.message,
    this.onOkTap,
    this.onVerifyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: AppColors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            verticalSpaceSmall,
            Text(
              message,
              style: TextStyle(fontSize: 14, color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
            verticalSpaceMedium,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onOkTap,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Text(
                      "Okay",
                      style: TextStyle(fontSize: 14, color: AppColors.white),
                    ),
                  ),
                ),
                if (message.contains("not verified")) ...[
                  horizontalSpaceMedium,
                  GestureDetector(
                    onTap: onVerifyTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      child: Text("Verify now!",
                          style:
                              TextStyle(fontSize: 14, color: AppColors.white)),
                    ),
                  ),
                ],
              ],
            ),
            verticalSpaceSmall,
          ],
        ),
      ),
    );
  }
}
