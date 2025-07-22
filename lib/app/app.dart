import 'package:ai_notes_taker/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:ai_notes_taker/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:ai_notes_taker/ui/views/home/home_view.dart';
import 'package:ai_notes_taker/ui/views/startup/startup_view.dart';
import 'package:ai_notes_taker/ui/views/voice/reminders_list.dart';
import 'package:ai_notes_taker/ui/views/voice/voice_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

import '../services/api_service.dart';
import '../services/app_auth_service.dart';
import '../services/app_preferences_service.dart';
import '../services/app_shared_pref_service.dart';
import '../ui/views/auth/auth_screen.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    MaterialRoute(page: VoiceView),
    MaterialRoute(page: RemindersListScreen),
    // @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: ApiService),
    LazySingleton(classType: AppAuthService),
    LazySingleton(classType: AppPreferencesService),
    LazySingleton(classType: AppSharedPrefService),
    // @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
)
class App {}
