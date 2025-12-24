import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common.dart';
import '../global.dart';
import 'privacy_policy.dart';

// Inspired by the about page in Eajy's flutter demo:
// https://github.com/Eajy/flutter_demo/blob/master/lib/route/about.dart

class MyAboutRoute extends ConsumerStatefulWidget {
  const MyAboutRoute({super.key});

  @override
  _MyAboutRouteState createState() => _MyAboutRouteState();
}


class _MyAboutRouteState extends ConsumerState<MyAboutRoute> {


  // These tiles are also used as drawer nav items in home route.
  static final List<Widget> kAboutListTiles = <Widget>[
    ListTile(
      title: Text(Global.l10n.appDesc),
    ),
    const Divider(),
    ListTile(
      leading: const Icon(Icons.open_in_new),
      title: Text(Global.l10n.app_site),
      onTap: () => url_launcher.launchUrl(Uri.parse(AUTHOR_SITE)),
    ),
    ListTile(
      leading: const Icon(Icons.bug_report),
      title: Text(Global.l10n.app_report_issue),
      onTap: () => url_launcher.launchUrl(Uri.parse('$GITHUB_URL/issues')),
    ),
    ListTile(
      leading: const Icon(Icons.open_in_new),
      title: Text(Global.l10n.privacy_policy),
      onTap: () =>  Get.to<void>(PrivacyPolicyPage()),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final header = ListTile(
      leading: kAppIcon,
      title: const Text(APP_NAME),
      subtitle: Text(kPackageInfo.version),
      trailing: IconButton(
        icon: const Icon(Icons.info),
        onPressed: () {
          showAboutDialog(
            context: context,
            applicationName: APP_NAME,
            applicationVersion: kPackageInfo.version,
            applicationIcon: kAppIcon,
            children: <Widget>[Text(Global.l10n.appDesc)],
          );
        },
      ),
    );
    return Scaffold(
        appBar: AppBar(
          title: Text(Global.l10n.drawer_menu_about),
          centerTitle: true,
        ),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child:
            ListView(
            children: ListTile.divideTiles(
                    context: context,
                    tiles: <Widget>[
                              header,
                              ...kAboutListTiles,
                              ListTile(
                                leading: const Icon(Icons.shop),
                                title: Text(Global.l10n.rate_app),
                                onTap: () =>
                                    url_launcher.launchUrl(Uri.parse(AUTHOR_SITE)),
                              ),
                          ],
                        ).toList(),
            )
    ));
  }
}
