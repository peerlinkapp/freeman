
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import '../../common.dart';
import '../../common/ui.dart';
import 'message_handler.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';


class ChatMorePage extends StatefulWidget {
  final int? index;
  final int id; //Conversation id
  final int type;
  final double keyboardHeight;

  ChatMorePage({this.index = 0, required this.id, required this.type, required this.keyboardHeight});

  @override
  _ChatMorePageState createState() => _ChatMorePageState();
}

class _ChatMorePageState extends State<ChatMorePage> {
  List data = [
    {"name": Global.l10n.chat_album, "icon": "assets/images/chat/ic_details_photo.webp"},
    {"name": Global.l10n.chat_camera, "icon": "assets/images/chat/ic_details_camera.webp"},
    {"name": Global.l10n.chat_file, "icon": "assets/images/chat/ic_details_file.webp"},
    //{"name": "视频通话", "icon": "assets/images/chat/ic_details_media.webp"},
   // {"name": "语音输入", "icon": "assets/images/chat/ic_chat_voice.webp"},
  ];

  List dataS = [
    {"name": "名片", "icon": "assets/images/chat/ic_details_card.webp"},
    {"name": "文件", "icon": "assets/images/chat/ic_details_file.webp"},
  ];

  List<AssetEntity> assets = <AssetEntity>[];

  action(String name) async {
    String remoteid = Global.dhtClient.get_conversation_remote_id(widget.id);

    try {
      if (name == Global.l10n.chat_album) {
        print("[ChatMorePage] name:${name}");
        AssetPicker.pickAssets(
          context,
          // maxAssets: 9,
          // pageSize: 320,
          // pathThumbSize: 80,
          // gridCount: 4,
          // selectedAssets: assets,
          // themeColor: Colors.green,
          // // textDelegate: DefaultAssetsPickerTextDelegate(),
          // routeCurve: Curves.easeIn,
          // routeDuration: const Duration(milliseconds: 500),
        ).then((List<AssetEntity>? result) {
          result!.forEach((AssetEntity element) async {

              debugPrint("[ChatMorePage] sendImageMsg to:$remoteid, img:${element.file}");

              sendImageMsg(remoteid, widget.type, file: await element.file,
                  callback: (v) {
                    print("[ChatMorePage] v:${v}");
                    if (v == null) return;

                  },
                  source: ImageSource.gallery
              );

              //刷新消息列表中的消息


          });
        });
      } else if (name == Global.l10n.chat_camera) {

        final AssetEntity? result = await CameraPicker.pickFromCamera(
          context,
          pickerConfig: CameraPickerConfig(
            enableRecording: true, // 启用录制视频
            enableAudio: true,     // 启用音频录制
          ),
        );

        if (result != null) {
          // 确保 result 不是 null，然后获取文件的路径
          final file = await result.file;
          if (file != null) {
            // 处理返回的拍照或录像结果
            print("[拍摄] 文件路径: ${file.path}");// ✅ 照片路径
            sendImageMsg(remoteid, widget.type, file: File(file.path),
                callback: (v) {
                  print("[ChatMorePage] v:${v}");
                  if (v == null) return;

                },
                source: ImageSource.camera
            );

          }
        }

      } else if (name == '红包') {
        showToast( '测试发送红包消息');
        await sendTextMsg( widget.id!,  "测试发送红包消息");
      } else if (name == Global.l10n.chat_file) { //文件
        await pickSingleFile(remoteid);
      } else {
        showToast( '敬请期待$name');
      }

    }catch (e) {
      print('Error in action method: $e');
      showToast('操作失败，请稍后再试');
    }
  }

  //选择文件
  Future<void> pickSingleFile(String remoteid) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      sendFileMsg( remoteid,  path);
    } else {
      print('用户取消了文件选择');
    }
  }

  itemBuild(data) {
    return new Container(
      margin: EdgeInsets.all(20.0),
      padding: EdgeInsets.only(bottom: 20.0),
      child: new Wrap(
        runSpacing: 10.0,
        spacing: 10,
        children: List.generate(data.length, (index) {
          //debugPrint("[ChatMorePage] data.length:${data.length}");
          String name = data[index]['name'];
          String icon = data[index]['icon'];
          return new MoreItemCard(
            name: name,
            icon: icon,
            keyboardHeight: widget.keyboardHeight,
            onPressed: () => action(name),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.index == 0) {
      debugPrint("[ChatMorePage] ${widget.index}");
      return itemBuild(data);
    } else {
      return itemBuild(dataS);
    }
  }
}
