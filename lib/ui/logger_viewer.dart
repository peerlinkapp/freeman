
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../global.dart';

/*
    talker.log('Server exception', logLevel: LogLevel.critical);
    talker.debug('Exception data sent for your analytics server');
    talker.verbose(
      'Start reloading config after critical server exception',
    );
    talker.info('1..............');
    talker.warning('Cache images working slowly on this platform');
*/

class LoggerViewer extends StatefulWidget {
  const LoggerViewer({
    Key? key
  }) : super(key: key);


  @override
  State<LoggerViewer> createState() => _LoggerViewerState();
}

class _LoggerViewerState extends State<LoggerViewer> {
  @override
  void initState() {
    final talker = Global.talker;

    //_handleException();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Talker Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: Builder(builder: (context) {
        return Scaffold(
          body: TalkerScreen(
            talker: Global.talker,
            isLogsExpanded: true,
            isLogOrderReversed: true,
            theme: const TalkerScreenTheme(
              logColors: {
                YourCustomLog.logKey: Colors.green,
              },
            ),
          ),
        );
      }),
    );
  }

  void _handleException() {
    try {
      throw Exception('Test service exception');
    } catch (e, st) {
      Global.talker.handle(e, st, 'FakeService exception');
    }
  }
}

class YourCustomLog extends TalkerLog {
  YourCustomLog(String message) : super(message);

  /// Your own log key (for color customization in settings)
  static const logKey = 'custom_log_key';

  @override
  String? get key => logKey;
}