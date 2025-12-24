import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

import '../global.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  // 加载本地 markdown 文件
  Future<String> loadMarkdown() async {
    return await rootBundle.loadString("assets/doc/privacy_policy_"+Global.l10n.localeName+".md");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Global.l10n.privacy_policy)),
      body: FutureBuilder<String>(
        future: loadMarkdown(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('${Global.l10n.privacy_policy_load_error}：${snapshot.error}');
            return Center(child: Text(Global.l10n.privacy_policy_load_error));
          } else {
            return Markdown(
              data: snapshot.data!,
              padding: const EdgeInsets.all(16.0),
              styleSheet: MarkdownStyleSheet(
                h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                h2: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                h3: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                p: const TextStyle(fontSize: 16),
                blockquote: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
                a: const TextStyle(color: Colors.blue),
              ),
            );
          }
        },
      ),
    );
  }
}
