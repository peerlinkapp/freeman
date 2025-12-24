

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:freeman/common.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class AvatarModel{

  static Future<String> getAvatarPath() async
  {
    return  Global.dhtClient.getUserDataPath();
  }

}

class AvatarPicker extends StatefulWidget {
  @override
  _AvatarPickerState createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final String AVATAR_FILE_FLAG = "_avatar_";

  // 选择图片
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _cropImage(File(pickedFile.path)); // 选择完后直接裁剪
    }
  }

  // 裁剪图片
  Future<void> _cropImage(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1), // 1:1 适合头像
      compressQuality: 80, // 压缩质量
      maxWidth: 512,
      maxHeight: 512,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '裁剪图片',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true, // 锁定1:1裁剪
        ),
        IOSUiSettings(
          title: '裁剪图片',
          aspectRatioLockEnabled: true, // 锁定1:1裁剪
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _image = File(croppedFile.path);
      });
    }
  }

  Future<void> delOldAvatarFile() async {
    try {
      final String path = await AvatarModel.getAvatarPath();
      String pattern = Global.user.uuid+AVATAR_FILE_FLAG+r'.*\..*';  // 匹配所有以 .txt 结尾的文件

      deleteFilesByPattern(path, pattern);
    } catch (e) {
      print("保存文件失败: $e");

    }
  }

  Future<File> saveFile(File file, String fileName) async {
    try {
      final String path = await AvatarModel.getAvatarPath();
      // 目标文件路径
      final File newFile = File('$path/$fileName');
      //设置头像路径到用户数据库中
      Global.user.setAvatar(newFile.path);

      // 复制原始文件到目标路径
      return await file.copy(newFile.path);
    } catch (e) {
      print("保存文件失败: $e");
      return Future.error("保存文件失败");
    }
  }


  // 选择图片
  Future<void> _confirmImage() async {
      if(_image == null) return;
      String ext = Utils.getFileExt(_image!.path);
      DateTime now = DateTime.now();
      String strRand = DateFormat('yyyyMMddHHmmss').format(now);
      //清除之前的旧头像文件
      delOldAvatarFile();
      //保存最新的头像文件
      saveFile(_image!, Global.user.uuid+AVATAR_FILE_FLAG+strRand+ext);

      Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if(_image == null ) _pickImage();

    return Scaffold(
      appBar: AppBar(title: Text('头像编辑器')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? ClipOval(
              child: Image.file(
                _image!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            )
                : CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _confirmImage,
              icon: Icon(Icons.image),
              label: Text('确定'),
            ),

          ],
        ),
      ),
    );
  }
}
