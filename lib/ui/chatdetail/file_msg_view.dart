import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import 'package:freeman/common.dart';
import '../../model/v2_tim_message.dart';
import '../../model/v2_tim_img_elem.dart';
import 'msg_avatar.dart';
import 'package:flutter/material.dart';

import 'package:open_filex/open_filex.dart';



class FileTransferCard extends StatefulWidget {
  final int fileId;
  final String fileName;
  final int fileSize;
  final IconData fileIcon;
  final double initialProgress;
  final bool isSender;

  const FileTransferCard({
    super.key,
    required this.fileId,
    required this.fileName,
    required this.fileSize,
    required this.isSender,
    this.fileIcon = Icons.insert_drive_file,
    this.initialProgress = 0.0,
  });

  @override
  State<FileTransferCard> createState() => _FileTransferCardState();
}

class _FileTransferCardState extends State<FileTransferCard> {
  double currentProgress = 0.0;
  late final StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    currentProgress = widget.initialProgress;

    _subscription = Global.dhtClient.fileSendStream.listen((event) {
      try {
        final data = jsonDecode(event);
        if (data is List && data.length >= 2) {
          int fileId = data[0];
          double progress = (data[1] as num).toDouble();
          
          if (fileId == widget.fileId) {
            setState(() {
              currentProgress = progress;
            });
          }
        }
      } catch (e) {
        print('JSON解析失败: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child:Container(
                    height: 100,
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.isSender ? (Global.settings.isDarkMode ? AppDarkColors.MsgMeBgColor : AppColors.MsgMeBgColor) : (Global.settings.isDarkMode ? AppDarkColors.MsgOthersBgColor : AppColors.MsgOthersBgColor),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Row(
                      children: [
                        Icon(widget.fileIcon, size: 40, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.fileName,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const Spacer(),
                              Text(formatBytes(widget.fileSize),
                                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 80,
                          child: currentProgress > 0 ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LinearProgressIndicator(
                                value: currentProgress/100,
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade300,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 4),
                              Text('${(currentProgress  ).toStringAsFixed(2)}%'),
                            ],
                          ): const SizedBox.shrink(), // 不显示任何内容
                        ),
                      ],
                    ),
    ),
    onTap: () {
        String path = Global.dhtClient.get_msg_file_path(widget.fileId);
        if(!Utils.isEmptyStr(path)) openFile(path);
    });
  }

  Future<void> openFile(String filePath) async {
    final result = await OpenFilex.open(filePath);
    print('打开状态: ${result.type}, 消息: ${result.message}');
  }


  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

}


