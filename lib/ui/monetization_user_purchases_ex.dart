// ignore_for_file: avoid_positional_boolean_parameters

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../my_app_settings.dart';


Widget buildUserBanner(BuildContext context, WidgetRef ref) {

  final content =  ListTile(
          title: Text('You are logged in '),
          subtitle: Text('Tap here to log in other accounts.'),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () => Navigator.of(context)
              .pushNamed('/firebase_flutterfire_loginui_ex'),
        );
  return Card(color: Colors.blue, child: content);
}

