# 0.3.0 [Unreleased]

- Fix system tray icon showing too big.
- Show done icon when completed on macOS.
- Add Settings option in system tray.
- Fix system ui overlay colors and brightness for Android and iOS.
- Fix stretched splash screen icon on Android.
- Fix app not running on Android and iOS.
- Fix app to only have portrait orientation.
- Revamp settings screen UI.
- Add option to use faded colors for themes.
- Dismiss keyboard on background click.
- Fix overflow on auth page due to virtual keyboard.
- Fix decoration color for hyperlinks.
- Add workspace and project selection options in settings screen.
- Add option to show remaining total hours and working days instead of completed.
- Show working extra label only when some progress has made on non-working day.
- Improve UI for today's progress bar.
- Merge workspace and project selection pages in onboarding flow.
- Implement chopper for making api requests.

# 0.2.1 - 2nd March, 2023

- Fix app not opening properly on macOS.

# 0.2.0 - 21st Feb, 2023

- Replace secure storage with encrypted shared preferences.
- Fix window full screen issue when launched.
- Fix target data not resetting after logout.
- Fix theme not resetting properly after logout.
- Fix local notification triggering repeatedly.
- Fix calendar overflow error.
- UI tweaks.
- Show a snackbar when a new update is available.
- Upgrade dependencies.

# 0.1.1 - 12th Feb, 2023

- Fixed Android app not connecting to the server issue.

# 0.1.0 - 4th Feb, 2023

- Initial Release.
- Supports auth via credentials and API key.
- Custom working days selection to adjust for leaves and holidays.
- Set max monthly hours limit.
- Supports tracking per workspace, per project on Toggl Track.
- Auto syncs stats at configurable intervals.
- Beautiful themes to select from.
- Tracks per day average working hours based on already tracked hours.
- Displays today's progress in system tray on desktop.
- Integrates with system tray on desktop for quick controls.
- Notifications support. Shows a notification for daily and monthly achieved goals.