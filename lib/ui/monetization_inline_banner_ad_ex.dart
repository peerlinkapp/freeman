import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../constants.dart';
import 'feature_store_secrets.dart';
import 'monetization_user_purchases_ex.dart';

class InlineBannerAdExample extends StatelessWidget {
  const InlineBannerAdExample({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SelectableText(
          '''
          Inline banners\n\n

          Adaptive banners are the next generation of responsive ads, maximizing performance by optimizing ad size for each device. Improving on fixed-size banners, which only supported fixed heights, adaptive banners let developers specify the ad-width and use this to determine the optimal ad size.
          ''',
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (ctx, idx) {
              final content =
                  ListTile(title: Text('App content - item "${idx + 1}"'));
              if ((idx + 1) % 5 == 0) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    content,
                    MyBannerAdWidget(
                        placeholder: Placeholder(fallbackHeight: 32)),
                  ],
                );
              }
              return content;
            },
            itemCount: 100,
          ),
        ),
      ],
    );
  }
}

/// !Create a statefulWidget to repr the inline banner.
/// Otherwise we can't show the same ad twice in the UI.
/// See https://stackoverflow.com/a/71899578/12421326.
class MyBannerAdWidget extends StatefulWidget {
  final Widget placeholder;
  const MyBannerAdWidget({this.placeholder = const SizedBox()});

  @override
  State<MyBannerAdWidget> createState() => _MyBannerAdWidgetState();
}

class _MyBannerAdWidgetState extends State<MyBannerAdWidget> {
  bool _adLoaded = false;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

  }


  @override
  void dispose() {
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
     return Placeholder(fallbackHeight: 32);

  }
}

/// ! Hides the banner ad if user purchased the "RemoveAd" item.
class MyBannerAd extends ConsumerWidget {
  const MyBannerAd({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MyBannerAdWidget();
  }
}
