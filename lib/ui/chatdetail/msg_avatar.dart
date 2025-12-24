import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/ui/image_view.dart';
import '../../common.dart';
import '../../model/chat_data.dart';
import '../../model/v2_tim_message.dart';
import '../friends/contacts_details_page.dart';

//消息列表中的头像

///封装之后的拍一拍效果[ShakeView]
class MsgAvatar extends StatefulWidget {
  const MsgAvatar({
    super.key,
    required this.model,
  });


  final V2TimMessage model;

  @override
  State<MsgAvatar> createState() => _MsgAvatarState();
}

class _MsgAvatarState extends State<MsgAvatar> with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    start(true);
  }

  void start(bool isInit) {
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    animation = TweenSequence<double>([
      //使用TweenSequence进行多组补间动画
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0, end: 10), weight: 1),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 10, end: 0), weight: 1),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0, end: -10), weight: 1),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: -10, end: 0), weight: 1),
    ]).animate(controller);
    if (!isInit) {
      controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: AnimateWidget(
        animation: animation,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
          margin: const EdgeInsets.only(right: 10.0),
          child: ImageView(
            img: widget.model.sender == Global.user.uuid
                ? strNoEmpty(Global.user.avatar) ? Global.user.avatar! : defIcon
                : strNoEmpty(widget.model.faceUrl) ? widget.model.faceUrl! : defIcon,
            height: 35,
            width: 35,
            fit: BoxFit.cover,
          ),
        ),
      ),
      onDoubleTap: () {
        setState(() => start(false));
      },
      onTap: () {

        Get.to<void>(ContactsDetailsPage(hashid: widget.model.senderId!));
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class AnimateWidget extends AnimatedWidget {
  const AnimateWidget({
    super.key,
    required Animation<double> animation,
    required this.child,
  }) : super(listenable: animation);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;
    return Transform(
      transform: Matrix4.rotationZ(animation.value * pi / 180),
      alignment: Alignment.bottomCenter,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        child: child,
      ),
    );
  }
}
