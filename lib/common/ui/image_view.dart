import 'package:flutter/material.dart';
import 'package:freeman/common.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:flutter/services.dart' show rootBundle;


class ImageView extends StatelessWidget {
  final String img;
  final double width;
  final double height;
  final BoxFit? fit;
  final bool isRadius;
  final int unreadCount;

  ImageView({
    required this.img,
    required this.height,
    required this.width,
    this.fit,
    this.isRadius = true,
    this.unreadCount = 0
  });

  Future<bool> assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {

      return BadgeImage();
  }

  Widget image() {
    //print("[ImageView] img:${this.img}");
    late Widget imgW;
    if(this.img.startsWith("assets/"))
    {
      imgW = new Image.asset(
        this.img,
        width: width-1,
        height: height-1,
        fit: height != null ? BoxFit.fill : fit,
      );
    }else{
      File f = File(this.img);
      bool exists = f.existsSync();
      if(exists) {
        imgW = Image.file(File(this.img),
          width: width - 1,
          height: height - 1,
          fit: height != null ? BoxFit.fill : fit,
        );
      }else{
        imgW = new Image.asset(
          lostIcon,
          width: width-1,
          height: height-1,
          fit: height != null ? BoxFit.fill : fit,
        );
      }
    }

    Widget image  = new Container(
      decoration: BoxDecoration(
          color: Colors.black26.withOpacity(0.1),
          border: Border.all(color: Colors.black.withOpacity(0.2),width: 0.3)
      ),
      child: imgW,
    );
    assetExists(img).then((exists) {
      //print("ImageView:exists=${exists}");
      if(exists)
      {
        image = new Image.file(
          File(img),
          width: width,
          height: height,
          fit: fit,
        );
      }else{
        if (isNetWorkImg(img)) {
          print("ImageView:CachedNetworkImage=${exists}");
          image = new CachedNetworkImage(
            imageUrl: img,
            width: width,
            height: height,
            fit: fit,
            cacheManager: new DefaultCacheManager(),
          );
        } else if (isAssetsImg(img)) {
          print("ImageView:CachedNetworkImage=${exists}");
          image = new Image.asset(
            img,
            width: width,
            height: height,
            fit: height != null ? BoxFit.fill : fit,
          );
        } else {

        }
      }
    });

    if (isRadius) {
      return new ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(4.0),
        ),
        child: image,
      );
    }
    return image;
  }

  Widget BadgeImage() {
    return Stack(
      clipBehavior: Clip.none, // 允许子组件超出父 Stack 区域
      children: [
        // 你的图片或图标
        image(),

        // 右上角未读数字标识
        if (unreadCount > 0)
          Positioned(
            right: -10,
            top: -10,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Center(
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
