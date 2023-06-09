import 'dart:developer';

final DistributionChannel distributionChannel =
    DistributionChannel.fromEnvironment();

/// Describes the distribution channel of the app since the app can be
/// distributed from different sources. e.g. App Store, Play Store, Github.
enum DistributionChannel {
  appStore,
  playStore,
  github;

  bool get isAppStore => this == DistributionChannel.appStore;

  bool get isPlayStore => this == DistributionChannel.playStore;

  bool get isGithub => this == DistributionChannel.github;

  /// Returns true if the app is distributed from either App Store or Play Store.
  bool get isFromStore => isAppStore || isPlayStore;

  const DistributionChannel();

  factory DistributionChannel.fromEnvironment() {
    const String channel = String.fromEnvironment('DISTRIBUTION_CHANNEL');
    switch (channel) {
      case 'appstore':
        return DistributionChannel.appStore;
      case 'playstore':
        return DistributionChannel.playStore;
      case 'github':
        return DistributionChannel.github;
      default:
        log('Invalid distribution channel, falling back to github');
        return DistributionChannel.github;
    }
  }
}
