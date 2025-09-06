import 'package:ai_notes_taker/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:ai_notes_taker/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:ai_notes_taker/ui/views/auth/user_form_view.dart';
import 'package:ai_notes_taker/ui/views/home/home_view.dart';
import 'package:ai_notes_taker/ui/views/startup/startup_view.dart';
import 'package:ai_notes_taker/ui/views/subscription/subscription_view.dart';
import 'package:ai_notes_taker/ui/views/voice/reminders_list.dart';
import 'package:ai_notes_taker/ui/views/voice/voice_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

import '../services/api_service.dart';
import '../services/app_auth_service.dart';
import '../services/app_preferences_service.dart';
import '../services/app_shared_pref_service.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';
import '../services/connectivity_service.dart';
import '../services/data_service.dart';
import '../services/offline_service.dart';
import '../ui/views/auth/auth_screen.dart';
import '../ui/views/voice/voice_new_view.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    MaterialRoute(page: VoiceView),
    MaterialRoute(page: RemindersListScreen),
    MaterialRoute(page: AuthScreen),
    MaterialRoute(page: VoiceNewView),
    MaterialRoute(page: UserFormView),
    MaterialRoute(page: SubscriptionView),
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
    LazySingleton(classType: DatabaseHelper),
    LazySingleton(classType: SyncService),
    LazySingleton(classType: ConnectivityService),
    LazySingleton(classType: DataService),
    LazySingleton(classType: OfflineService),
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
