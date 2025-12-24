import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:freeman/common.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zxing2/qrcode.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:get/get.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String scannedData = Global.l10n.btn_scan_please;
  bool hasScanned = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void showToastResult()
  {
    var snackBar = SnackBar(
      /// need to set following properties for best effect of awesome_snackbar_content
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: Global.l10n.add_friend,
        message: Global.l10n.after_apply_add_friend,
        /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
        contentType: ContentType.success,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  void handleScanResult(String? code) {
    if (code == null || hasScanned) return;
    hasScanned = true;

    setState(() {
      scannedData = code;
    });

    Global.dhtClient.sendAddFriendMsg(code);
    Global.talker.info("send add friend $code message!");
    showToastResult();
    Get.back(result: true);
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      handleScanResult(scanData.code);
    });
  }

  Future<void> pickImageAndScanQRCode() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      try {
        final bytes = await pickedFile.readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        final image = frame.image;

        // 获取像素数据
        final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        if (byteData == null) throw Exception("Image byte data is null");

        final int width = image.width;
        final int height = image.height;

        final luminanceSource = RGBLuminanceSource(
          width,
          height,
          byteData.buffer.asInt32List(),
        );

        final bitmap = BinaryBitmap(HybridBinarizer(luminanceSource));
        final reader = QRCodeReader();

        final result = reader.decode(bitmap);

        handleScanResult(result.text);
      } catch (e) {
        Global.talker.error("Failed to scan QR from gallery using zxing2: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(Global.l10n.scan_failed)),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Global.l10n.btn_scan)),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 4,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
              ),
              Expanded(
                child: Center(
                  child: Text("${Global.l10n.scan_result} $scannedData"),
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 150,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 闪光灯按钮 + 说明文字
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      heroTag: "toggleFlash",
                      onPressed: () async {
                        await controller?.toggleFlash();
                        final flashStatus = await controller?.getFlashStatus();
                        Global.talker.info("Flash is ${flashStatus == true ? 'ON' : 'OFF'}");
                        setState(() {});
                      },
                      backgroundColor: Colors.amber,
                      child: FutureBuilder<bool?>(
                        future: controller?.getFlashStatus(),
                        builder: (context, snapshot) {
                          final isOn = snapshot.data ?? false;
                          return Icon(
                            isOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                          );
                        },
                      ),
                      tooltip: Global.l10n.toggle_flash,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      Global.l10n.toggle_flash,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),

                // 相册按钮 + 说明文字
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      heroTag: "scanFromGallery",
                      onPressed: pickImageAndScanQRCode,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(Icons.photo, color: Colors.white),
                      tooltip: Global.l10n.scan_from_gallery,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      Global.l10n.scan_from_gallery,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),


        ],
      ),
    );
  }

}
