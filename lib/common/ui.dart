
import 'package:flutter/material.dart';
export 'package:freeman/common/ui/commom_bar.dart';
export 'package:freeman/common/ui/commom_button.dart';
export 'package:freeman/common/ui/main_input.dart';
export 'package:freeman/common/ui/image_view.dart';
export 'package:freeman/common/ui/label_row.dart';
export 'package:freeman/common/ui/button_row.dart';
export 'package:freeman/common/ui/more_item_card.dart';
export 'package:freeman/common/ui/text_item_container.dart';
export 'package:freeman/common/ui/text_span_builder.dart';
export 'package:freeman/common/ui/confirm_alert.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HorizontalLine extends StatelessWidget {
  final double height;
  final Color color;
  final double horizontal;

  HorizontalLine({
    this.height = 0.5,
    this.color = const Color(0xFFEEEEEE),
    this.horizontal = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: height,
      color: color,
      margin: new EdgeInsets.symmetric(horizontal: horizontal),
    );
  }
}

class VerticalLine extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double vertical;

  VerticalLine({
    this.width = 1.0,
    this.height = 25,
    this.color = const Color.fromRGBO(209, 209, 209, 0.5),
    this.vertical = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: width,
      color: Color(0xffDCE0E5),
      margin: new EdgeInsets.symmetric(vertical: vertical),
      height: height,
    );
  }
}

class Space extends StatelessWidget {
  final double width;
  final double height;

  Space({this.width = 10.0, this.height = 10.0});

  @override
  Widget build(BuildContext context) {
    return new Container(width: width, height: height);
  }
}


double winWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double winHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double winTop(BuildContext context) {
  return MediaQuery.of(context).padding.top;
}

double winBottom(BuildContext context) {
  return MediaQuery.of(context).padding.bottom;
}

double winLeft(BuildContext context) {
  return MediaQuery.of(context).padding.left;
}

double winRight(BuildContext context) {
  return MediaQuery.of(context).padding.right;
}

double winKeyHeight(BuildContext context) {
  return MediaQuery.of(context).viewInsets.bottom;
}



double navigationBarHeight(BuildContext context) {
  return kToolbarHeight;
}



showToast(String msg, {int duration = 1, int gravity = 0}) {
  showGlobalToast(msg);
}



void showGlobalToast(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: const Color(0xAA000000),
    textColor: const Color(0xFFFFFFFF),
    fontSize: 16.0,
  );
}