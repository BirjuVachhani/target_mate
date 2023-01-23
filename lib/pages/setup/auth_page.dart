import 'dart:convert';
import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:screwdriver/screwdriver.dart';
import 'package:toggl_target/utils/utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../resources/keys.dart';
import '../../ui/widgets.dart';
import 'workspace_selection_page.dart';

part 'auth_page.g.dart';

class AuthPageWrapper extends StatelessWidget {
  const AuthPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => AuthStore(),
      dispose: (context, store) => store.dispose(),
      child: const AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late final AuthStore store = context.read<AuthStore>();

  late final TapGestureRecognizer recognizer = TapGestureRecognizer()
    ..onTap = () => launchUrlString('https://track.toggl.com/profile');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: SizedBox(
            width: 350,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                          fontWeight: FontWeight.w600,
                          color: context.theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  style: subtitleTextStyle,
                ),
                const SizedBox(height: 16),
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
                    onFieldSubmitted: (_) => store.saveAndContinue(),
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
                  builder: (context) => ElevatedButton(
                    onPressed: store.apiKey.isEmpty ? null : onNext,
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
                Observer(builder: (context) {
                  if (store.error == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Error: ${store.error}',
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  );
                }),
              ],
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
      FadeThroughPageRoute(
        child: WorkspaceSelectionPageWrapper(
          workspaces: store.workspaces,
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

// ignore: library_private_types_in_public_api
class AuthStore = _AuthStore with _$AuthStore;

abstract class _AuthStore with Store {
  late final TextEditingController apiKeyController = TextEditingController();

  late final Box box = getSecretsBox();

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @observable
  String apiKey = '';

  List<Map<String, dynamic>> workspaces = [];

  @action
  Future<bool> saveAndContinue() async {
    if (isLoading) return false;
    isLoading = true;
    try {
      final authKey = base64Encode('$apiKey:api_token'.codeUnits);

      final profileResponse = await http.get(
        Uri.parse('https://api.track.toggl.com/api/v9/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $authKey',
        },
      );

      if (profileResponse.statusCode != 200) {
        log(profileResponse.body);
        error = 'Invalid API key';
        return false;
      }

      final JsonMap profile = jsonDecode(profileResponse.body);

      // Load workspaces.
      final response = await http.get(
        Uri.parse('https://api.track.toggl.com/api/v9/workspaces'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $authKey',
        },
      );

      isLoading = false;
      if (response.statusCode != 200) {
        log(response.body);
        error = 'Invalid API key';
        return false;
      }
      final data = List.from(jsonDecode(response.body));
      workspaces = data.map((e) => Map<String, dynamic>.from(e)).toList();

      if (workspaces.isEmpty) {
        error = 'No workspaces found';
        return false;
      }
      log('${workspaces.length} workspaces found');

      await box.putAll({
        HiveKeys.apiKey: apiKey,
        HiveKeys.fullName: profile['fullname'],
        HiveKeys.email: profile['email'],
        HiveKeys.timezone: profile['timezone'],
        HiveKeys.avatarUrl: profile['image_url'],
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

  void dispose() {
    apiKeyController.dispose();
  }
}
