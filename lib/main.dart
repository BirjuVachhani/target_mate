import 'dart:convert';
import 'dart:developer';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:toggl_target/pages/target_store.dart';
import 'package:toggl_target/resources/keys.dart';

import 'pages/home.dart';
import 'pages/setup/auth_page.dart';
import 'resources/colors.dart';
import 'resources/theme.dart';
import 'utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialize();
  runApp(const MyApp());
}

Future<void> initialize() async {
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

  final Box encryptedBox = await Hive.openBox(HiveKeys.secrets,
      encryptionCipher: HiveAesCipher(encryptionKey));
  encryptedBox.containsKey(HiveKeys.apiKey);

  await Hive.openBox(HiveKeys.target);
  final appSettings = await Hive.openBox(HiveKeys.settings);

  if (!appSettings.containsKey(HiveKeys.primaryColor)) {
    appSettings.put(HiveKeys.primaryColor, AppColors.primaryColor.value);
  }

  GetIt.instance.registerSingleton<FlutterSecureStorage>(secureStorage);
  GetIt.instance.registerSingleton<TargetStore>(
    TargetStore(),
    dispose: (store) => store.dispose(),
  );
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
