import 'dart:developer';

import 'package:toggl_target/utils/migration/migration.dart';

import '../../resources/keys.dart';
import '../utils.dart';
import 'migrations.dart';

class Migrator {
  Migrator._();

  static bool requiresMigration() =>
      getSecretsBox().get(HiveKeys.migrationVersion, defaultValue: 1) <
      kMigrationVersion;

  /// Returns true if migration was successful, false if it failed, and null if
  /// no migration was required.
  static Future<bool?> runMigrationIfRequired() async {
    if (!requiresMigration()) {
      log('No migration required.');
      return null;
    }
    return await runMigration();
  }

  static Future<bool> runMigration() async {
    try {
      log('-----------------------------------------------------------------');
      log('Starting migration...');
      final int currentVersion =
          getSecretsBox().get(HiveKeys.migrationVersion, defaultValue: 1);
      const int targetVersion = kMigrationVersion;

      if (currentVersion > targetVersion) {
        for (int i = currentVersion; i > targetVersion; i--) {
          if (migrationRegistry[i] == null) {
            throw MigrationException('No migration found for version $i');
          }
          await migrationRegistry[i]!.downgrade();
          log('Successfully downgraded to version $i');
        }
      } else {
        for (int i = currentVersion + 1; i <= targetVersion; i++) {
          if (migrationRegistry[i] == null) {
            throw MigrationException('No migration found for version $i');
          }
          await migrationRegistry[i]!.upgrade();
          log('Successfully upgraded to version $i');
        }
      }
      await getSecretsBox().put(HiveKeys.migrationVersion, targetVersion);
      log('Migration successful!');
      log('-----------------------------------------------------------------');
      return true;
    } catch (error, stackTrace) {
      log('Migration failed!');
      log(error.toString());
      log(stackTrace.toString());
      log('-----------------------------------------------------------------');
      throw MigrationException('Unable to run migration: $error');
    }
  }

  static Future<bool?> downgradeFrom(Migration migration) async {
    try {
      log('-----------------------------------------------------------------');
      log('Starting manual downgrade...');
      final int currentVersion =
          getSecretsBox().get(HiveKeys.migrationVersion, defaultValue: 1);
      final int targetVersion = migration.version - 1;

      if (currentVersion == targetVersion) {
        log('No downgrade required.');
        return null;
      }
      if (currentVersion < targetVersion) {
        throw MigrationException('Cannot downgrade to a newer version.');
      }

      for (int i = currentVersion; i > targetVersion; i--) {
        if (migrationRegistry[i] == null) {
          throw MigrationException('No migration found for version $i');
        }
        await migrationRegistry[i]!.downgrade();
        log('Successfully downgraded to version $i');
      }

      await getSecretsBox().put(HiveKeys.migrationVersion, targetVersion);
      log('Manual downgrade successful!');
      log('-----------------------------------------------------------------');
      return true;
    } catch (error, stackTrace) {
      log('Manual downgrade failed!');
      log(error.toString());
      log(stackTrace.toString());
      log('-----------------------------------------------------------------');
      throw MigrationException('Unable to run manual downgrade: $error');
    }
  }

  static Future<bool?> upgradeTo(Migration migration) async {
    try {
      log('-----------------------------------------------------------------');
      log('Starting manual upgrade...');
      final int currentVersion =
          getSecretsBox().get(HiveKeys.migrationVersion, defaultValue: 1);
      final int targetVersion = migration.version;

      if (currentVersion == targetVersion) {
        log('No upgrade required.');
        return null;
      }
      if (currentVersion > targetVersion) {
        throw MigrationException('Cannot upgrade to an older version.');
      }

      for (int i = currentVersion + 1; i <= targetVersion; i++) {
        if (migrationRegistry[i] == null) {
          throw MigrationException('No migration found for version $i');
        }
        await migrationRegistry[i]!.upgrade();
        log('Successfully upgraded to version $i');
      }

      await getSecretsBox().put(HiveKeys.migrationVersion, targetVersion);
      log('Manual upgrade successful!');
      log('-----------------------------------------------------------------');
      return true;
    } catch (error, stackTrace) {
      log('Manual upgrade failed!');
      log(error.toString());
      log(stackTrace.toString());
      log('-----------------------------------------------------------------');
      throw MigrationException('Unable to run manual upgrade: $error');
    }
  }
}

class MigrationException implements Exception {
  final String message;

  MigrationException(this.message);

  @override
  String toString() => message;
}
