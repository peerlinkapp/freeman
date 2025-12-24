import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';


typedef VoidCallbackWithType = void Function(String type);
typedef VoidCallbackConfirm = void Function(bool isOk);
typedef VoidCallbackWithMap = void Function(Map item);

final navGK = new GlobalKey<NavigatorState>();


Future<dynamic> routePush(Widget widget) {
  final route = new CupertinoPageRoute(
    builder: (BuildContext context) => widget,
    settings: new RouteSettings(
      name: widget.toStringShort(),
    ),
  );
  return navGK.currentState!.push(route);
}

Future<dynamic> routePushReplace(Widget widget) {
  final route = new CupertinoPageRoute(
    builder: (BuildContext context) => widget,
    settings: new RouteSettings(
      name: widget.toStringShort(),
    ),
  );
  return navGK.currentState!.pushReplacement(route);
}

Future<dynamic> routeMaterialPush(Widget widget) {
  final route = new MaterialPageRoute(
    builder: (BuildContext context) => widget,
    settings: new RouteSettings(
      name: widget.toStringShort(),
    ),
  );
  return navGK.currentState?.push(route) ?? Future.value(null);
}


Future<dynamic> routePushAndRemove(Widget widget) {
  final route = new CupertinoPageRoute(
    builder: (BuildContext context) => widget,
    settings: new RouteSettings(
      name: widget.toStringShort(),
    ),
  );
  return navGK.currentState?.pushAndRemoveUntil(route, (route) => route == null) ?? Future.value(null);
}

pushAndRemoveUntilPage(Widget page) {
  navGK.currentState?.pushAndRemoveUntil(new MaterialPageRoute<dynamic>(
    builder: (BuildContext context) {
      return page;
    },
  ), (Route<dynamic> route) => false) ;
}

pushReplacement(Widget page) {
  navGK.currentState?.pushReplacement(new MaterialPageRoute<dynamic>(
    builder: (BuildContext context) {
      return page;
    },
  ))??print('NavigatorState is null');
}

popToRootPage() {
  if (navGK.currentState != null) {
    navGK.currentState!.popUntil(ModalRoute.withName('/'));
  } else {
    print('NavigatorState is null');
  }
}

popToPage(Widget page) {
  try {
    if (navGK.currentState != null) {
      navGK.currentState!.popUntil(ModalRoute.withName(page.toStringShort()));
    }else {
      print('NavigatorState is null');
    }
  } catch (e) {
    print('pop路由出现错误:::${e.toString()}');
  }
}


void popToHomePage(BuildContext context) {
  Navigator.of(context).popUntil((route) => route.isFirst);
}