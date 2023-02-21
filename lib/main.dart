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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeData();

  final bool isFirstRun =
      !Hive.box(HiveBoxes.secrets).containsKey(HiveKeys.firstRun);

  await setupWindowManager(isFirstRun: isFirstRun);

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

  final Size initialSize = getWindowSize();
  final Offset? position = getWindowPosition();

  await windowManager.ensureInitialized();

  windowManager.setMinimumSize(initialSize);
  windowManager.setSize(initialSize);
  if (position != null) windowManager.setPosition(position);
  if (!defaultTargetPlatform.isMacOS) windowManager.setAsFrameless();

  final windowOptions = WindowOptions(
    title: 'Toggl Target',
    size: initialSize,
    backgroundColor: Colors.transparent,
    fullScreen: false,
    skipTaskbar: false,
    minimumSize: const Size(360, 520),
  );
  //
  windowManager.waitUntilReadyToShow(windowOptions, () {
    windowManager.show();
    windowManager.focus();

    windowManager.addListener(WindowResizeListener());
  });

  doWhenWindowReady(() => appWindow.show());
}

Size getWindowSize() {
  final double width =
      Hive.box(HiveBoxes.window).get(HiveKeys.width, defaultValue: 420.0);
  final double height =
      Hive.box(HiveBoxes.window).get(HiveKeys.height, defaultValue: 800.0);

  return Size(width, height);
}

Offset? getWindowPosition() {
  final double? top = Hive.box(HiveBoxes.window).get(HiveKeys.top);
  final double? left = Hive.box(HiveBoxes.window).get(HiveKeys.left);
  return top != null && left != null ? Offset(left, top) : null;
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
    Hive.box(HiveBoxes.window).put(HiveKeys.width, size.width);
    Hive.box(HiveBoxes.window).put(HiveKeys.height, size.height);
  }

  @override
  void onWindowMoved() async {
    final pos = await windowManager.getPosition();
    Hive.box(HiveBoxes.window).put(HiveKeys.left, pos.dx);
    Hive.box(HiveBoxes.window).put(HiveKeys.top, pos.dy);
  }
}
