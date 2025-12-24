import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../../model/notice.dart';
import '../../common.dart';

Future<dynamic> sendSoundMessages(String id, String soundPath, int duration,
    int type, Callback callback) async {
  try {
    //var result = await im.sendSoundMessages(id, soundPath, type, duration);
    //callback(result);
  } on PlatformException {
    debugPrint('发送语音  失败');
  }
}

/*
id: 接收人id (hashid)
 */
Future<void> sendTextMsg(int cid,  String content) async {

  debugPrint('发送消息结果 ===> coversation id:${cid},  content:${content}');

  await Global.dhtClient.sendMsg(cid, content);

}

bool isSupportedImageFormat(String filePath) {
  // 获取文件扩展名（小写）
  String ext = path.extension(filePath).toLowerCase();

  // 判断是否是支持的格式
  return ext == '.jpg' || ext == '.jpeg' || ext == '.png' || ext == '.webp';
}
//发送图片消息
Future<void> sendImageMsg(String remoteId, int type,
    {required Callback callback,
      required ImageSource source,
      required File? file}) async {
  if(file == null) return;
  XFile? image;
  if (file.existsSync()) {
    image = XFile(file.path);
  } else {
    image = await ImagePicker().pickImage(source: source);
  }
  if (image == null) return;
  String targetPath = path.join(Global.dhtClient.getUserDataPath(), "conversations");

  await createNestedDirectory(targetPath);

  targetPath = path.join(targetPath, getFileName(image.path));
  debugPrint("发送图片消息  ===>  remoteId:${remoteId}, image.path:${image.path}, targetPath:${targetPath}");
  if(isSupportedImageFormat(image.path))
  {
    File ? compressImg = await singleCompressFile(File(image.path), targetPath, quality: 50);
    if(compressImg == null)
    {
      debugPrint("[sendImageMsg] compressImg == null");
      return;
    }
    /// Send image message
    if(compressImg != null)
    {
      Global.dhtClient.sendImgMsg(remoteId, compressImg.path);
    }
  }else{
    debugPrint("发送图片消息  ===>  不支持的图片格式:${image.path}");
  }
}

/*
id: 接收人id (hashid)
 */
Future<void> sendFileMsg(String remoteid,  String filepath) async {

  debugPrint('发送文件： ===> remoteid:${remoteid},  filepath:${filepath}');

  await Global.dhtClient.sendFileMsg(remoteid, filepath);

}

/*
发送语音消息
 */
Future<void> sendVoiceMsg(String remoteid,  String filepath) async {
  debugPrint('发送语音： ===> remoteid:${remoteid},  filepath:${filepath}');
  await Global.dhtClient.sendVoiceMsg(remoteid, filepath);

}