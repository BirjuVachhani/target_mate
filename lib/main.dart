import 'dart:convert';
import 'dart:developer';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  // Secrets box
  await Hive.openBox(HiveKeys.secrets,
      encryptionCipher: HiveAesCipher(encryptionKey));

  // window settings box
  await Hive.openBox(HiveKeys.window);

  // target box
  await Hive.openBox(HiveKeys.target);

  // app settings box.
  final appSettings = await Hive.openBox(HiveKeys.settings);

  if (!appSettings.containsKey(HiveKeys.primaryColor)) {
    appSettings.put(HiveKeys.primaryColor, AppColors.primaryColor.value);
  }

  // Initialize GetIt registry.
  GetIt.instance.registerSingleton<FlutterSecureStorage>(secureStorage);
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

  final double width =
      Hive.box(HiveKeys.window).get(HiveKeys.width, defaultValue: 420.0);
  final double height =
      Hive.box(HiveKeys.window).get(HiveKeys.height, defaultValue: 800.0);

  await windowManager.ensureInitialized();
  WindowOptions windowOptions = WindowOptions(
    // Preserve window size if it is not the first run.
    size: Size(width, height),
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'Toggl Target',
    minimumSize: const Size(360, 520),
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    windowManager.setSkipTaskbar(false);

    // This will save window size on resize.
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

class WindowResizeListener extends WindowListener {
  @override
  void onWindowResized() async {
    final Size size = await windowManager.getSize();
    Hive.box(HiveKeys.window).put(HiveKeys.width, size.width);
    Hive.box(HiveKeys.window).put(HiveKeys.height, size.height);
  }
}
