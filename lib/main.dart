import 'dart:convert';
import 'dart:developer';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:toggl_target/resources/keys.dart';
import 'package:toggl_target/utils/extensions.dart';
import 'package:window_manager/window_manager.dart';

import 'pages/home.dart';
import 'pages/setup/auth_page.dart';
import 'resources/colors.dart';
import 'resources/theme.dart';
import 'utils/system_tray_manager.dart';
import 'utils/utils.dart';
import 'utils/window_resize_listener.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  await initializeData();

  final bool isFirstRun =
      !Hive.box(HiveBoxes.secrets).containsKey(HiveKeys.firstRun);

  await setupWindowManager(isFirstRun: isFirstRun);

  // Save first run status.
  if (!Hive.box(HiveBoxes.secrets).containsKey(HiveKeys.firstRun)) {
    await Hive.box(HiveBoxes.secrets).put(HiveKeys.firstRun, false);
  }

  runApp(const MyApp());
}

Future<void> initializeData() async {
  await Hive.initFlutter();

  final EncryptedSharedPreferences encryptedPrefs =
      EncryptedSharedPreferences();

  String key = await encryptedPrefs.getString(HiveKeys.key);
  final List<int> encryptionKey;
  if (key.isEmpty) {
    log('Generating a new encryption key');
    encryptionKey = Hive.generateSecureKey();
    log('Saving the encryption key');
    await encryptedPrefs.setString(
        HiveKeys.key, base64UrlEncode(encryptionKey));
  } else {
    log('Found an existing encryption key');
    encryptionKey = base64Url.decode(key);
  }
  log('Encryption key: $key');

  // Secrets box
  await Hive.openBox(HiveBoxes.secrets,
      encryptionCipher: HiveAesCipher(encryptionKey));

  // window settings box
  await Hive.openBox(HiveBoxes.window);

  // target box
  await Hive.openBox(HiveBoxes.target);

  // notifications box
  await Hive.openBox(HiveBoxes.notifications);

  // app settings box.
  final appSettings = await Hive.openBox(HiveBoxes.settings);

  if (!appSettings.containsKey(HiveKeys.primaryColor)) {
    appSettings.put(HiveKeys.primaryColor, AppColors.primaryColor.value);
  }

  // Initialize GetIt registry.
  GetIt.instance.registerSingleton<EncryptedSharedPreferences>(encryptedPrefs);
  GetIt.instance.registerSingleton<SystemTrayManager>(SystemTrayManager(),
      dispose: (manager) => manager.dispose());
}

/// Sets up the window on desktop platforms.
Future<void> setupWindowManager({required bool isFirstRun}) async {
  /// Windows are only supported on desktop platforms.
  if (kIsWeb || !defaultTargetPlatform.isDesktop) return;

  if (isFirstRun) {
    log('Setting up window manager for the first time.');
  }

  final Size initialSize = getSavedWindowSize();
  final Offset? position = getSavedWindowPosition();

  windowManager.setMinimumSize(initialSize);
  windowManager.setSize(initialSize);

  // For Windows and Linux.
  if (!defaultTargetPlatform.isMacOS) windowManager.setAsFrameless();

  doWhenWindowReady(() {
    appWindow.minSize = const Size(360, 520);
    appWindow.size = initialSize;
    if (position != null) {
      appWindow.position = position;
    } else {
      // Center the window for the first time.
      appWindow.alignment = Alignment.center;
    }
    appWindow.show();
    windowManager.focus();
    windowManager.addListener(WindowResizeListener());
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
    final useMaterial3 =
        appSettingsBox.get(HiveKeys.useMaterial3, defaultValue: false);

    final bool isOnboarded = getSecretsBox().containsKey(HiveKeys.onboarded);
    return AdaptiveTheme(
      initial: AdaptiveThemeMode.dark,
      light: getLightTheme(primaryColor, useMaterial3: useMaterial3),
      dark: getDarkTheme(primaryColor, useMaterial3: useMaterial3),
      builder: (theme, darkTheme) => MaterialApp(
        title: 'Toggl Target',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: theme,
        darkTheme: darkTheme,
        home: isOnboarded ? const HomePageWrapper() : const AuthPageWrapper(),
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
