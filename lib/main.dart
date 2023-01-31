import 'dart:convert';
import 'dart:developer';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:toggl_target/pages/home_store.dart';
import 'package:toggl_target/pages/settings.dart';
import 'package:toggl_target/pages/target_store.dart';
import 'package:toggl_target/resources/keys.dart';
import 'package:toggl_target/utils/extensions.dart';
import 'package:window_manager/window_manager.dart';

import 'pages/home.dart';
import 'pages/setup/auth_page.dart';
import 'resources/colors.dart';
import 'resources/theme.dart';
import 'utils/system_tray_manager.dart';
import 'utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeData();

  final bool isFirstRun =
      !Hive.box(HiveKeys.secrets).containsKey(HiveKeys.firstRun);

  await setupWindowManager(isFirstRun: isFirstRun);

  if (!Hive.box(HiveKeys.secrets).containsKey(HiveKeys.firstRun)) {
    await Hive.box(HiveKeys.secrets).put(HiveKeys.firstRun, false);
  }

  runApp(const MyApp());
}

Future<void> initializeData() async {
  await Hive.initFlutter();

  const secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));

  String? key = await secureStorage.read(key: HiveKeys.key);
  final List<int> encryptionKey;
  if (key == null) {
    log('Generating a new encryption key');
    encryptionKey = Hive.generateSecureKey();
    log('Saving the encryption key');
    await secureStorage.write(
      key: HiveKeys.key,
      value: base64UrlEncode(encryptionKey),
    );
  } else {
    log('Found an existing encryption key');
    encryptionKey = base64Url.decode(key);
  }
  log('Encryption key: $key');

  await Hive.openBox(HiveKeys.secrets,
      encryptionCipher: HiveAesCipher(encryptionKey));

  await Hive.openBox(HiveKeys.target);
  final appSettings = await Hive.openBox(HiveKeys.settings);

  if (!appSettings.containsKey(HiveKeys.primaryColor)) {
    appSettings.put(HiveKeys.primaryColor, AppColors.primaryColor.value);
  }

  // Initialize GetIt registry.
  GetIt.instance.registerSingleton<FlutterSecureStorage>(secureStorage);
  GetIt.instance.registerLazySingleton<TargetStore>(() => TargetStore(),
      dispose: (store) => store.dispose());

  GetIt.instance.registerSingleton<SystemTrayManager>(SystemTrayManager(),
      dispose: (manager) => manager.dispose());
  GetIt.instance.registerLazySingleton(() => HomeStore(),
      dispose: (store) => store.dispose());
  GetIt.instance.registerLazySingleton(() => SettingsStore(),
      dispose: (store) => store.dispose());
}

/// Sets up the window on desktop platforms.
Future<void> setupWindowManager({required bool isFirstRun}) async {
  /// Windows are only supported on desktop platforms.
  if (kIsWeb || !defaultTargetPlatform.isDesktop) return;

  if(isFirstRun) {
    log('Setting up window manager for the first time.');
  }

  await windowManager.ensureInitialized();
  WindowOptions windowOptions = WindowOptions(
    // Preserve window size if it is not the first run.
    size: isFirstRun ? const Size(420, 800) : null,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'Toggl Target',
    minimumSize: const Size(360, 450),
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    windowManager.setSkipTaskbar(false);
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final appSettingsBox = getAppSettingsBox();
    final primaryColor = Color(appSettingsBox.get(HiveKeys.primaryColor));

    final bool isOnboarded = getSecretsBox().containsKey(HiveKeys.onboarded);
    return AdaptiveTheme(
      initial: AdaptiveThemeMode.dark,
      light: ThemeData.light(),
      dark: getTheme(primaryColor),
      builder: (theme, darkTheme) => MaterialApp(
        title: 'Toggl Target',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: theme,
        darkTheme: darkTheme,
        home: isOnboarded ? const HomePage() : const AuthPageWrapper(),
      ),
    );
  }

  @override
  void dispose() {
    Hive.close();
    GetIt.instance.reset(dispose: true);
    super.dispose();
  }
}
