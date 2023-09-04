import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

import '../utils/extensions.dart';
import '../utils/font_variations.dart';
import '../utils/utils.dart';
import 'back_button.dart';
import 'custom_safe_area.dart';
import 'custom_scaffold.dart';

class NetworkMarkdownPage extends StatefulWidget {
  final String url;
  final String? title;

  const NetworkMarkdownPage({super.key, required this.url, this.title});

  @override
  State<NetworkMarkdownPage> createState() => _NetworkMarkdownPageState();
}

class _NetworkMarkdownPageState extends State<NetworkMarkdownPage> {
  String markdownSource = '';
  bool isLoading = true;
  String? error;

  late final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadFromUrl();
  }

  Future<void> loadFromUrl() async {
    try {
      if (!isLoading) {
        isLoading = true;
        error = null;
        if (mounted) setState(() {});
      }
      final response = await http.get(Uri.parse(widget.url));

      if (response.statusCode == 200) {
        markdownSource = response.body;
      } else {
        error = 'Oops, something went wrong!';
      }

      isLoading = false;
      if (mounted) setState(() {});

      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        if (mounted) setState(() {});
      });
    } catch (e) {
      error = 'Oops, something went wrong!';
      isLoading = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      fontSize: 15,
      height: 1.7,
      letterSpacing: 0.2,
      fontFamily: context.textTheme.bodyLarge?.fontFamily,
      color: context.theme.textColor,
    );
    return CustomScaffold(
      body: CustomSafeArea(
        child: Center(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            controller: scrollController,
            slivers: [
              const SliverPersistentHeader(
                delegate: AppHeaderDelegate(),
                pinned: true,
              ),
              if (!isLoading && error == null && widget.title != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                    child: Align(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.title ?? '',
                            style: context.textTheme.titleLarge?.copyWith(
                              height: 3,
                              fontVariations: FontVariations.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (isLoading)
                SliverFillRemaining(
                  child: Center(
                    child: SpinKitFoldingCube(
                      color: context.theme.textColor.withOpacity(0.5),
                      size: 40,
                    ),
                  ),
                )
              else if (error != null)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.exclamationmark_circle,
                          size: 100,
                          color: context.colorScheme.error,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          error ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontVariations: FontVariations.semiBold,
                            color: context.theme.textColor.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FractionallySizedBox(
                          widthFactor: 0.75,
                          child: Text(
                            'Please check your internet connection and try again.',
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.theme.textColor.withOpacity(0.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        FilledButton.tonal(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                          onPressed: loadFromUrl,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: MarkdownBody(
                          data: markdownSource,
                          styleSheet: MarkdownStyleSheet(
                            p: baseStyle,
                            h1: context.textTheme.titleLarge?.copyWith(
                              height: 3,
                              fontVariations: FontVariations.bold,
                            ),
                            h2: context.textTheme.titleMedium?.copyWith(
                              height: 2,
                              fontVariations: FontVariations.semiBold,
                            ),
                            h3: context.textTheme.titleSmall?.copyWith(
                              fontVariations: FontVariations.medium,
                            ),
                            h4: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            h5: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            h6: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            a: baseStyle.copyWith(
                              color: context.theme.primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                            strong: baseStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              fontVariations: FontVariations.bold,
                            ),
                            listBullet: baseStyle,
                            em: baseStyle.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          styleSheetTheme:
                              MarkdownStyleSheetBaseTheme.cupertino,
                        ),
                      ),
                    ),
                  ),
                ),
              if (!isLoading && error == null)
                SliverToBoxAdapter(
                  child: ListenableBuilder(
                    listenable: scrollController,
                    builder: (context, child) {
                      // required to auto update when window is resized.
                      MediaQuery.sizeOf(context);
                      if (!scrollController.hasClients ||
                          !scrollController.position.hasViewportDimension) {
                        return const SizedBox.shrink();
                      }
                      if (scrollController.position.extentTotal >
                          scrollController.position.viewportDimension) {
                        return child!;
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                    child: const BottomNoteWidget(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNoteWidget extends StatelessWidget {
  final String? label;

  const BottomNoteWidget({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: ShaderMask(
        shaderCallback: (rect) {
          return LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.3, 0.6, 1],
            colors: [
              context.colorScheme.secondary,
              context.colorScheme.secondary.withOpacity(0.5),
              context.colorScheme.secondary.withOpacity(0.1),
            ],
          ).createShader(rect);
        },
        child: Text(
          label ?? '-- You reached at the bottom! --',
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall,
        ),
      ),
    );
  }
}

class AppHeaderDelegate extends SliverPersistentHeaderDelegate {
  const AppHeaderDelegate();

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(kSidePadding, 0, kSidePadding, 0),
      child: Center(
        child: Container(
          color: context.theme.scaffoldBackgroundColor,
          constraints: const BoxConstraints(maxWidth: 700),
          child: const CustomBackButton(usePrimaryColor: false),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 40;

  @override
  double get minExtent => 40;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
