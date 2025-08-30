// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, implementation_imports, depend_on_referenced_packages

import 'package:stacked_services/src/bottom_sheet/bottom_sheet_service.dart';
import 'package:stacked_services/src/dialog/dialog_service.dart';
import 'package:stacked_services/src/navigation/navigation_service.dart';
import 'package:stacked_shared/stacked_shared.dart';

import '../services/api_service.dart';
import '../services/app_auth_service.dart';
import '../services/app_preferences_service.dart';
import '../services/app_shared_pref_service.dart';
import '../services/connectivity_service.dart';
import '../services/data_service.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';

final locator = StackedLocator.instance;

Future<void> setupLocator({
  String? environment,
  EnvironmentFilter? environmentFilter,
}) async {
// Register environments
  locator.registerEnvironment(
      environment: environment, environmentFilter: environmentFilter);

// Register dependencies
  locator.registerLazySingleton(() => BottomSheetService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => ApiService());
  locator.registerLazySingleton(() => AppAuthService());
  locator.registerLazySingleton(() => AppPreferencesService());
  locator.registerLazySingleton(() => AppSharedPrefService());
  locator.registerLazySingleton(() => DatabaseHelper());
  locator.registerLazySingleton(() => SyncService());
  locator.registerLazySingleton(() => ConnectivityService());
  locator.registerLazySingleton(() => DataService());
}
