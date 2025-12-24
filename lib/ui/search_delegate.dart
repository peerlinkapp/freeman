import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:isolate';
import '../generated_bindings.dart';

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart' as english_words;
import 'package:freeman/common.dart';
import 'package:freeman/ui/friends/contact_item.dart';
import '../global.dart';


// Adapted from search demo in offical flutter gallery:
// https://github.com/flutter/flutter/blob/master/examples/flutter_gallery/lib/demo/material/search_demo.dart
class AppBarSearchExample extends StatefulWidget {
  const AppBarSearchExample({super.key});

  @override
  _AppBarSearchExampleState createState() => _AppBarSearchExampleState();
}

class _AppBarSearchExampleState extends State<AppBarSearchExample> {
  final List<String> kEnglishWords;
  late MySearchDelegate _delegate;

  _AppBarSearchExampleState()
      : kEnglishWords = List.from(Set.from(english_words.all))
    ..sort(
          (w1, w2) => w1.toLowerCase().compareTo(w2.toLowerCase()),
    ),
        super();

  @override
  void initState() {
    super.initState();
    _delegate = MySearchDelegate(kEnglishWords);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('English Words'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () async {
              final String? selected = await showSearch<String>(
                context: context,
                delegate: _delegate,
              );
              if (context.mounted && selected != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('You have selected the word: $selected'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Scrollbar(
        child: ListView.builder(
          itemCount: kEnglishWords.length,
          itemBuilder: (context, idx) => ListTile(
            title: Text(kEnglishWords[idx]),
          ),
        ),
      ),
    );
  }
}

// Defines the content of the search page in `showSearch()`.
// SearchDelegate has a member `query` which is the query string.
class MySearchDelegate extends SearchDelegate<String> {
  final List<String> _words;
  final List<String> _history;
  String _strResult = '';

  // 定义 setter
  set strResult(String value) {
    _strResult = value;
  }

  // 定义 getter
  String get strResult => _strResult;

  MySearchDelegate(List<String> words)
      : _words = words,
        _history = <String>['6d85d0', 'f2', 'f1'],
        _strResult = '',
        super()
  {
     //final callbackPointer = ffi.Pointer.fromFunction<AddFriendCallbackFunction>(findUserCallback);
     //Global.dhtClient.setFindUserNotify();
  }

  // Leading icon in search bar.
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        // SearchDelegate.close() can return vlaues, similar to Navigator.pop().
        this.close(context, '');
      },
    );
  }

  // Dart 回调函数
  static void findUserCallback(int result) {

      final resultString = result.toString();
      print('Task result: $resultString');

  }

// 封装异步调用
  Future<void> callNativeAsync() async {
    //final callbackPointer = ffi.Pointer.fromFunction<AddFriendCallbackFunction>(findUserCallback);
    //Global.dhtClient.setFindUserCbk(callbackPointer);
  }

  Future<List<String>> _searchResults(String query) async {
    //await Future.delayed(Duration(seconds: 2)); // 模拟延迟
    if (query.isEmpty) {
      return [];
    }

    List<String> users = [];
    List<Contact> contacts = await Global.getContacts(key: query);
    for (var contact in contacts) {
      users.add(jsonEncode(contact.toJson()));
    }
    return users;
  }

  @override
  Widget buildResults(BuildContext context) {
    // 使用 FutureBuilder 显示异步结果
    return FutureBuilder<List<String>>(
      future: _searchResults(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // 加载中
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); // 错误状态
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No results found')); // 无结果
        }
        // 显示搜索结果
        List<String> results = snapshot.data!;

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (BuildContext context, int index) {

              Contact _contact = Contact.fromJson(jsonDecode(results[index]));
              return new ContactItem(
                avatar: _contact.avatar,
                title: _contact.name,
                identifier: _contact.identifier,
              );

            }
        );
      },
    );
  }

  // Suggestions list while typing (this.query).
  @override
  Widget buildSuggestions(BuildContext context) {
    final Iterable<String> suggestions = this.query.isEmpty
        ? _history
        : _words.where((word) => word.startsWith(query));

    return _SuggestionList(
      query: this.query,
      suggestions: suggestions.toList(),
      onSelected: (String suggestion) {
        this.query = suggestion;
        this._history.insert(0, suggestion);
        showResults(context);
      },
    );
  }

  // Action buttons at the right of search bar.
  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      if (query.isEmpty)
        IconButton(
          tooltip: 'Voice Search',
          icon: const Icon(Icons.mic),
          onPressed: () {
            this.query = 'TODO: implement voice input';
          },
        )
      else
        IconButton(
          tooltip: 'Clear',
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        )
    ];
  }
}

// Suggestions list widget displayed in the search page.
class _SuggestionList extends StatelessWidget {
  const _SuggestionList(
      {required this.suggestions,
        required this.query,
        required this.onSelected});

  final List<String> suggestions;
  final String query;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.titleMedium!;
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int i) {
        final String suggestion = suggestions[i];
        return ListTile(
          leading: query.isEmpty ? const Icon(Icons.history) : const Icon(null),
          // Highlight the substring that matched the query.
          title: RichText(
            text: TextSpan(
              text: suggestion.substring(0, query.length),
              style: textTheme.copyWith(fontWeight: FontWeight.bold),
              children: <TextSpan>[
                TextSpan(
                  text: suggestion.substring(query.length),
                  style: textTheme,
                ),
              ],
            ),
          ),
          onTap: () {
            onSelected(suggestion);
          },
        );
      },
    );
  }
}
