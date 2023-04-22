import 'dart:developer';

import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../main.dart';
import '../resources/keys.dart';
import '../ui/custom_scaffold.dart';
import '../utils/extensions.dart';
import '../utils/migration/migrator.dart';
import '../utils/utils.dart';
import 'home.dart';
import 'setup/auth_page.dart';

class MigrationPage extends StatefulWidget {
  const MigrationPage({super.key});

  @override
  State<MigrationPage> createState() => _MigrationPageState();
}

class _MigrationPageState extends State<MigrationPage> {
  bool migrating = false;

  String? error;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      migrate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      onWillPop: () async => false,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: 400,
            child: Builder(builder: (context) {
              if (error != null) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 100,
                      color: context.theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'An error occurred while migrating your data. Please restarting your app',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.theme.colorScheme.error,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      error ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.theme.textColor.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.tonalIcon(
                      onPressed: migrating ? null : migrate,
                      style: FilledButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        backgroundColor: Colors.redAccent.withOpacity(0.1),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again!'),
                    ),
                    const SizedBox(height: 56),
                    const FractionallySizedBox(
                      widthFactor: 0.8,
                      child: Text(
                        'If nothing works, Reset your app. You will have to log in again!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: migrating ? null : migrate,
                      child: const Text('Reset app'),
                    ),
                  ],
                );
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SpinKitPouringHourGlassRefined(
                    size: 100,
                    color: context.theme.colorScheme.primary.withOpacity(0.25),
                    duration: const Duration(milliseconds: 2000),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hold on, migrating your app...',
                    style: TextStyle(
                      color: context.theme.textColor.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Future<void> migrate() async {
    final navigator = Navigator.of(context);
    try {
      await Future.delayed(const Duration(seconds: 1));
      await Migrator.runMigrationIfRequired();

      // Reset GetIt registry. (stores, etc.)
      await GetIt.instance.reset(dispose: true);
      await initializeData();

      final bool isOnboarded = getSecretsBox().containsKey(HiveKeys.onboarded);

      if (isOnboarded) {
        navigator.pushAndRemoveUntil(
          CupertinoPageRoute(builder: (_) => const HomePageWrapper()),
          (route) => false,
        );
      } else {
        navigator.pushAndRemoveUntil(
          CupertinoPageRoute(builder: (_) => const AuthPageWrapper()),
          (route) => false,
        );
      }

      migrating = false;
      setState(() {});
    } catch (e, stacktrace) {
      log(e.toString());
      log(stacktrace.toString());
      error = e.toString();
      migrating = false;
      setState(() {});
    }
  }

  Future<void> reset() async {
    final navigator = Navigator.of(context);
    try {
      // Delete saved data.
      await Hive.deleteBoxFromDisk(HiveBoxes.secrets);
      await Hive.deleteBoxFromDisk(HiveBoxes.settings);
      await Hive.deleteBoxFromDisk(HiveBoxes.target);
      await Hive.deleteBoxFromDisk(HiveBoxes.notifications);

      // Delete data from secure storage. (Encryption key)
      await GetIt.instance.get<EncryptedSharedPreferences>().clear();

      // Navigate to auth page.
      navigator.pushAndRemoveUntil(
        CupertinoPageRoute(builder: (_) => const AuthPageWrapper()),
        (route) => false,
      );

      // Reset GetIt registry. (stores, etc.)
      await GetIt.instance.reset(dispose: true);

      // Reinitialize data. Encryption key, Hive, GetIt, etc.
      await initializeData();

      migrating = false;
      setState(() {});
    } catch (e) {
      error = e.toString();
      migrating = false;
      setState(() {});
    }
  }
}
