import 'dart:convert';
import 'dart:developer';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:screwdriver/screwdriver.dart';
import 'package:toggl_target/api/toggl_api_service.dart';
import 'package:toggl_target/model/workspace.dart';
import 'package:toggl_target/ui/custom_scaffold.dart';
import 'package:toggl_target/ui/gesture_detector_with_cursor.dart';
import 'package:toggl_target/utils/utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../model/project.dart';
import '../../model/user.dart';
import '../../resources/keys.dart';
import '../../ui/widgets.dart';
import 'project_selection_page.dart';

part 'auth_page.g.dart';

class AuthPageWrapper extends StatelessWidget {
  final bool restoreTheme;

  const AuthPageWrapper({super.key, this.restoreTheme = false});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => AuthStore(),
      dispose: (context, store) => store.dispose(),
      child: AuthPage(restoreTheme: restoreTheme),
    );
  }
}

class AuthPage extends StatefulWidget {
  final bool restoreTheme;

  const AuthPage({super.key, this.restoreTheme = false});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late final TapGestureRecognizer recognizer = TapGestureRecognizer()
    ..onTap = () => launchUrlString('https://toggl.com/track');

  late final AuthStore store = context.read<AuthStore>();

  late bool restoreTheme = widget.restoreTheme;

  @override
  Widget build(BuildContext context) {
    if (restoreTheme) {
      restoreTheme = false;
      Future.delayed(Duration.zero, () => AdaptiveTheme.of(context).reset());
    }
    return CustomScaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 400,
              child: AnimatedSize(
                alignment: Alignment.topCenter,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Welcome to',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/logo_trimmed.png',
                        fit: BoxFit.fitWidth,
                        width: 200,
                        color: context.theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text.rich(
                      TextSpan(
                        text: 'A companion app for  ',
                        children: [
                          TextSpan(
                            text: 'Toggl Track.',
                            recognizer: recognizer,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: context.theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Observer(
                      builder: (context) => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        reverseDuration: const Duration(milliseconds: 250),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        child: store.loginWithAPIKey
                            ? ApiKeyUI(onNext: onNext)
                            : BasicAuthUI(onNext: onNext),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onNext() async {
    final result = await store.saveAndContinue();
    if (result) onSuccess();
  }

  void onSuccess() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => ProjectSelectionPageWrapper(
          workspaces: store.workspaces,
          projects: store.projects,
        ),
      ),
    );
  }

  @override
  void dispose() {
    recognizer.dispose();
    super.dispose();
  }
}

class ApiKeyUI extends StatefulWidget {
  final VoidCallback onNext;

  const ApiKeyUI({super.key, required this.onNext});

  @override
  State<ApiKeyUI> createState() => _ApiKeyUIState();
}

class _ApiKeyUIState extends State<ApiKeyUI> {
  late final TapGestureRecognizer recognizer = TapGestureRecognizer()
    ..onTap = () => launchUrlString('https://track.toggl.com/profile');

  @override
  Widget build(BuildContext context) {
    final store = context.read<AuthStore>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SetupTitle('API key'),
        // https://track.toggl.com/profile
        Text.rich(
          TextSpan(
            text: 'You can find your API key in your profile settings '
                'on Toggl Track. ',
            children: [
              TextSpan(
                text: 'Go to profile settings.',
                recognizer: recognizer,
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  decorationColor: context.theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  color: context.theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          style: subtitleTextStyle,
        ),
        const SizedBox(height: 16),
        Observer(
          builder: (context) {
            if (store.error == null) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: context.theme.colorScheme.error.withOpacity(0.2),
                ),
              ),
              child: Text(
                '${store.error}',
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            );
          },
        ),
        Observer(builder: (context) {
          return TextFormField(
            controller: store.apiKeyController,
            onChanged: (value) {
              store.apiKey = value;
              store.error = null;
            },
            maxLength: 32,
            maxLines: 1,
            readOnly: store.isLoading,
            textInputAction: TextInputAction.go,
            onFieldSubmitted: (_) => widget.onNext(),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-f0-9]')),
            ],
            decoration: const InputDecoration(
              hintText: 'Enter your 32 digit API key',
              counterText: '',
            ),
          );
        }),
        const SizedBox(height: 32),
        Observer(
          builder: (context) => FilledButton(
            onPressed: store.apiKey.isEmpty ? null : widget.onNext,
            child: store.isLoading
                ? FittedBox(
                    child: SpinKitThreeBounce(
                      color: context.theme.colorScheme.onPrimary,
                      size: 18,
                    ),
                  )
                : const Text('Next'),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'OR',
            style: subtitleTextStyle,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetectorWithCursor(
            onTap: () => store.setLoginWithAPIKey(false),
            child: Text(
              'Login with credentials.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: context.theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    recognizer.dispose();
    super.dispose();
  }
}

class BasicAuthUI extends StatefulWidget {
  final VoidCallback onNext;

  const BasicAuthUI({super.key, required this.onNext});

  @override
  State<BasicAuthUI> createState() => _BasicAuthUIState();
}

class _BasicAuthUIState extends State<BasicAuthUI> {
  late final TapGestureRecognizer recognizer = TapGestureRecognizer()
    ..onTap = () => launchUrlString('https://toggl.com/track');

  @override
  Widget build(BuildContext context) {
    final store = context.read<AuthStore>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SetupTitle('Login with Credentials'),
        Text.rich(
          TextSpan(
            text: 'Login with your credentials for ',
            children: [
              TextSpan(
                text: 'Toggl Track.',
                recognizer: recognizer,
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w600,
                  decorationColor: context.theme.colorScheme.primary,
                  color: context.theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          style: subtitleTextStyle,
        ),
        const SizedBox(height: 16),
        Observer(
          builder: (context) {
            if (store.error == null) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: context.theme.colorScheme.error.withOpacity(0.2),
                ),
              ),
              child: Text(
                '${store.error}',
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            );
          },
        ),
        Observer(builder: (context) {
          return TextFormField(
            controller: store.emailController,
            onChanged: (value) {
              store.email = value;
              store.error = null;
            },
            maxLength: 32,
            maxLines: 1,
            autofillHints: const [AutofillHints.email],
            keyboardType: TextInputType.emailAddress,
            readOnly: store.isLoading,
            textInputAction: TextInputAction.go,
            inputFormatters: [
              FilteringTextInputFormatter.deny(' '),
            ],
            decoration: const InputDecoration(
              hintText: 'Enter your email',
              counterText: '',
            ),
          );
        }),
        const SizedBox(height: 16),
        Observer(builder: (context) {
          return TextFormField(
            controller: store.passwordController,
            onChanged: (value) {
              store.password = value;
              store.error = null;
            },
            maxLength: 32,
            maxLines: 1,
            obscureText: true,
            readOnly: store.isLoading,
            textInputAction: TextInputAction.go,
            onFieldSubmitted: (_) => widget.onNext(),
            decoration: const InputDecoration(
              hintText: 'Enter your password',
              counterText: '',
            ),
          );
        }),
        const SizedBox(height: 32),
        Observer(
          builder: (context) => FilledButton(
            onPressed: store.email.isEmpty || store.password.isEmpty
                ? null
                : widget.onNext,
            child: store.isLoading
                ? FittedBox(
                    child: SpinKitThreeBounce(
                      color: context.theme.colorScheme.onPrimary,
                      size: 18,
                    ),
                  )
                : const Text('Next'),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'OR',
            style: subtitleTextStyle,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetectorWithCursor(
            onTap: () => store.setLoginWithAPIKey(true),
            child: Text(
              'Login with API key',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: context.theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    recognizer.dispose();
    super.dispose();
  }
}

// ignore: library_private_types_in_public_api
class AuthStore = _AuthStore with _$AuthStore;

abstract class _AuthStore with Store {
  late final TextEditingController apiKeyController = TextEditingController();
  late final TextEditingController emailController = TextEditingController();
  late final TextEditingController passwordController = TextEditingController();

  late final Box box = getSecretsBox();

  late final TogglApiService apiService = GetIt.instance.get<TogglApiService>();

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @observable
  String apiKey = '';

  List<Workspace> workspaces = [];

  List<Project> projects = [];

  @observable
  bool loginWithAPIKey = false;

  @observable
  String email = '';

  @observable
  String password = '';

  @action
  Future<bool> saveAndContinue() async {
    if (isLoading) return false;

    if (!loginWithAPIKey) {
      if (!email.isEmail) {
        error = 'Invalid email';
        return false;
      }
    }

    isLoading = true;
    try {
      final authKey = loginWithAPIKey
          ? base64Encode('$apiKey:api_token'.codeUnits)
          : base64Encode('$email:$password'.codeUnits);

      box.put(HiveKeys.authKey, authKey);

      final userResponse = await apiService.getProfile();

      if (!userResponse.isSuccessful) {
        if (loginWithAPIKey) {
          error = 'Invalid API key';
        } else {
          error = 'Incorrect email or password';
        }
        isLoading = false;
        return false;
      }

      final User user = userResponse.body!;

      // Load workspaces.
      final workspacesResponse = await apiService.getAllWorkspaces();

      isLoading = false;
      if (!workspacesResponse.isSuccessful) {
        if (loginWithAPIKey) {
          error = 'Invalid API key';
        } else {
          error = 'Incorrect email or password';
        }
        return false;
      }
      workspaces = workspacesResponse.body ?? [];

      if (workspaces.isEmpty) {
        error = 'No workspaces found';
        return false;
      }
      log('${workspaces.length} workspaces found');

      // Load projects.
      final projectsResponse = await apiService.getAllProjects();

      isLoading = false;
      if (!projectsResponse.isSuccessful) {
        error = projectsResponse.bodyString;
        return false;
      }
      projects = projectsResponse.body ?? [];

      await box.putAll({
        HiveKeys.authKey: authKey,
        HiveKeys.user: json.encode(user.toJson()),
      });

      return true;
    } catch (err, stacktrace) {
      log(err.toString());
      log(stacktrace.toString());
      isLoading = false;
      error = err.toString();
      return false;
    }
  }

  @action
  void setLoginWithAPIKey(bool value) {
    if (value) {
      apiKeyController.clear();
      apiKey = '';
    } else {
      emailController.clear();
      passwordController.clear();
      email = '';
      password = '';
    }
    error = null;
    loginWithAPIKey = value;
  }

  void dispose() {
    apiKeyController.dispose();
  }
}
