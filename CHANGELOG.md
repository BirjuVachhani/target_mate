# 0.6.6 - 4th September, 2023

- Remove donation link.
- Fix inline code-block styling in markdown viewer.
- Remove Rive and its usages.

# 0.6.5 - 31st August, 2023

- Fix handling of duration conversion when value is zero.

# 0.6.4 - 26th August, 2023

- Fix button size in update dialog.
- Fix window not movable when update dialog is showing.
- Improve update dialog configuration.
- Add `Extra` section in settings screen.

# 0.6.3 - 8th June, 2023

- Only show working extra badge when working extra and timer is actually running.
- Show Expected Finish Time when timer is running.
- Show proper error when incorrect max hours are provided.
- Fix number formatting for working hours and max hours.

# 0.6.2 - 23rd May, 2023

- Fix today's progress showing incorrect time initially while loading.
- Add nice loading indicator for today's progress bar.

# 0.6.1 - 28th April, 2023

- Improved day progress indicator.
- Fix day progress indicator text showing with incorrect color.

# 0.6.0 - 23rd April, 2023

- Add support for light theme.
- Improved fonts and colors.
- Fix email input field for login not taking more than 32 characters.
- Improved formats for displaying durations.
- Fix swipe to go back gesture on iOS.
- Improved UI for time entries.

# 0.5.1 - 12th April, 2023

- Disable auto backup for Android.
- Fix system tray icon not changing properly.
- Fix system tray icon not adapting to status bar color on macOS.
- Show overtime info for daily goals.

# 0.5.0 - 2nd April, 2023

- Dynamic icons for macOS app. Dock icon changes based on whether the timer is running or not.
- Fix progressbar showing completed icon when it is not completed.
- Show app icon as system tray icon on windows.
- Use standard system buttons for windows.
- Fix windows system buttons to be consistent across all screens.
- Fix: Goals showing zero or negative for extra days when monthly goal is achieved.
- Fix day total duration showing 0 when in seconds only.
- Show left keyword in labels when show remaining option is enabled.
- Show overtime hours when goal is achieved and show remaining is true.
- Update system tray icon on windows.
- Fix login issue when profile is missing data.

# 0.4.0 - 24th March, 2023

- Rebranded to "Target Mate".
- Fix migration detection when the app is run for the first time.
- Change default theme to blue.
- Fix logo color on auth screen.

# 0.3.1 - 12th March, 2023

- Fix date parsing not accounting for local time zone.
- Fix dividers in home screen.
- Fix Toolbars for macOS and Windows.
- Release for Windows.

# 0.3.0 - 6th March, 2023

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