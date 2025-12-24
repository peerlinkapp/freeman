import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import 'package:freeman/common.dart';
import '../../model/v2_tim_message.dart';
import '../../model/v2_tim_img_elem.dart';
import 'msg_avatar.dart';

class ImgMsg extends StatelessWidget {
  final V2TimMessage model;

  const ImgMsg(this.model, {super.key});

  @override
  Widget build(BuildContext context) {

    final V2TimImageElem imageElem = model.imageElem!;
    if (!listNoEmpty(imageElem.imageList!)) {
      return const Text('发送中');
    }
    final V2TimImage? msgInfo = imageElem.imageList![0];
    final double height = msgInfo!.height!.toDouble();
    final double resultH = height > 200.0 ? 200.0 : height;
    final String url = msgInfo.url!;
    final bool isFile = isLocalFilePath(url);

    List<Widget> body = <Widget>[
      MsgAvatar(model: model),
      const SizedBox(width: mainSpace),
      Expanded(
        child: GestureDetector(
          child: Container(
            padding: const EdgeInsets.all(5.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              child: isFile
                  ? Image.file(File(url))
                  : CachedNetworkImage(
                      imageUrl: url, height: resultH, fit: BoxFit.cover),
            ),
          ),
          onTap: () => Get.to<void>(
            PhotoView(
              imageProvider: (isFile ? FileImage(File(url)) as ImageProvider : NetworkImage(url) as ImageProvider),
              onTapUp: (BuildContext c, TapUpDetails f,
                      PhotoViewControllerValue s) =>
                  Navigator.of(context).pop(),
              maxScale: 3.0,
              minScale: 1.0,
            ),
          ),
        ),
      ),
      const Spacer(),
    ];
    if (model.senderId == Global.user.uuid) {
      body = body.reversed.toList();
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      alignment: Alignment.topCenter,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: body),
    );
  }
}
