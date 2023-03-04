import 'dart:developer';

abstract class Migration {
  const Migration();

  abstract final int version;

  Future<void> upgrade();

  Future<void> downgrade();
}

class EmptyMigration extends Migration {
  const EmptyMigration(this.version);

  @override
  final int version;

  @override
  Future<void> upgrade() async {
    log('No upgrade for version $version');
  }

  @override
  Future<void> downgrade() async {
    log('No downgrade for version $version');
  }
}
