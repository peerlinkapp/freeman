// This file declares routes of this app, in particular it declares the
// "structure" of the group of example routes, in a const List<Tuple2> object.
// ignore_for_file: sort_child_properties_last
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freeman/ui/my/change_name_page.dart';
import '../constants.dart';
import 'home_page.dart';
import 'login.dart';
import 'my/my_index.dart';
import 'my_route.dart';
import 'about.dart';
import 'widgets_text_ex.dart';
import '../global.dart';
import 'logger_viewer.dart';



class MyRouteGroup {
  const MyRouteGroup(
      {required this.groupName, required this.icon, required this.routes});
  final String groupName;
  final Widget icon;
  final List<MyRoute> routes;
}

const kMyAppRoutesBasic = <MyRouteGroup>[

  MyRouteGroup(
    groupName: 'Hot Topics',
    icon: Icon(Icons.dashboard),
    routes: <MyRoute>[
      MyRoute(
        child: MyAboutRoute(),
        sourceFilePath: 'lib/ui/chatlist/chatlist.dart',
        title: 'Container',
        description: 'Basic widgets for layout.',
        links: {
          'Doc': 'https://docs.flutter.io/flutter/widgets/Container-class.html',
        },
      ),
      MyRoute(
        child: TextExample(),
        sourceFilePath: 'lib/routes/widgets_text_ex.dart',
        title: 'text',
        description: 'Showing data in a table.',
        links: {
          'Docs':
              'https://docs.flutter.io/flutter/material/PaginatedDataTable-class.html'
        },
      ),
    ],
  ),
];



final kAllRouteGroups = <MyRouteGroup>[
  ...kMyAppRoutesBasic,
];

final kAllRoutes = <MyRoute>[
  ...kAllRouteGroups.expand((group) => group.routes)
];


final kRouteNameToRoute = <String, MyRoute>{
  for (final route in kAllRoutes) route.routeName: route
};

final kRouteNameToRouteGroup = <String, MyRouteGroup>{
  for (final group in kAllRouteGroups)
    for (final route in group.routes) route.routeName: group
};


