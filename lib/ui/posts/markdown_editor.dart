import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freeman/common.dart';
import 'package:freeman/common/ui.dart';
import 'dart:convert';
import 'dart:io';

import 'package:fleather/fleather.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;


class MarkdownEditorPage extends ConsumerStatefulWidget {
  final String? post_uuid; //帖子uuid

  const MarkdownEditorPage({super.key,
    this.post_uuid,
  });

  @override
  _MarkdownEditorState createState() => _MarkdownEditorState();
}

/// 图片来源类型
enum ImageSourceType {
  gallery,
  camera,
}

class _MarkdownEditorState extends ConsumerState<MarkdownEditorPage> {

  final FocusNode _focusNode = FocusNode();
  final GlobalKey<EditorState> _editorKey = GlobalKey();
  FleatherController? _controller;
  final _key = GlobalKey<ExpandableFabState>();


  @override
  void initState() {
    super.initState();
    if (kIsWeb) BrowserContextMenu.disableContextMenu();
    _initController();
  }

  @override
  void dispose() {
    super.dispose();
    if (kIsWeb) BrowserContextMenu.enableContextMenu();
  }

  Future<void> _initController() async {
    try {
      final result = await rootBundle.loadString('assets/welcome.json');
      final heuristics = ParchmentHeuristics(
        formatRules: [],
        insertRules: [
          ForceNewlineForInsertsAroundInlineImageRule(),
        ],
        deleteRules: [],
      ).merge(ParchmentHeuristics.fallback);
      final doc = ParchmentDocument.fromJson(
        jsonDecode(result),
        heuristics: heuristics,
      );
      _controller = FleatherController(document: doc);
    } catch (err, st) {
      if (kDebugMode) {
        print('Cannot read welcome.json: $err\n$st');
      }
      _controller = FleatherController();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, title: Text(Global.l10n.post_title)),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _key,
        type: ExpandableFabType.up,
        // margin: const EdgeInsets.all(100),
        // duration: const Duration(milliseconds: 500),
        // distance: 200.0,
        // type: ExpandableFabType.up,
        // pos: ExpandableFabPos.left,
        // childrenOffset: const Offset(0, 20),
        // childrenAnimation: ExpandableFabAnimation.none,
        // fanAngle: 40,
        // openButtonBuilder: RotateFloatingActionButtonBuilder(
        //   child: const Icon(Icons.abc),
        //   fabSize: ExpandableFabSize.large,
        //   foregroundColor: Colors.amber,
        //   backgroundColor: Colors.green,
        //   shape: const CircleBorder(),
        //   angle: 3.14 * 2,
        //   elevation: 5,
        // ),
        // closeButtonBuilder: FloatingActionButtonBuilder(
        //   size: 56,
        //   builder: (BuildContext context, void Function()? onPressed,
        //       Animation<double> progress) {
        //     return IconButton(
        //       onPressed: onPressed,
        //       icon: const Icon(
        //         Icons.check_circle_outline,
        //         size: 40,
        //       ),
        //     );
        //   },
        // ),
        overlayStyle: ExpandableFabOverlayStyle(
          color: Colors.black.withValues(alpha: 0.5),
          blur: 5,
        ),
        onOpen: () {
          debugPrint('onOpen');
        },
        afterOpen: () {
          debugPrint('afterOpen');
        },
        onClose: () {
          debugPrint('onClose');
        },
        afterClose: () {
          debugPrint('afterClose');
        },
        children: [
          FloatingActionButton.small(
            // shape: const CircleBorder(),
            heroTag: null,
            child: const Icon(Icons.add_a_photo),
            onPressed: () async {
              final File? imageFile = await pickAndSaveImage(
                sourceType: ImageSourceType.gallery
              );

              if (imageFile != null) {
                final selection = _controller!.selection;
                _controller!.replaceText(
                  selection.baseOffset,
                  selection.extentOffset - selection.baseOffset,
                  EmbeddableObject('image', inline: false, data: {
                    'source_type': kIsWeb ? 'url' : 'file',
                    'source': imageFile.path,
                  }),
                );
                _controller!.replaceText(
                  selection.baseOffset + 1,
                  0,
                  '\n',
                  selection:
                  TextSelection.collapsed(offset: selection.baseOffset + 2),
                );
              }
            },
          ),
          FloatingActionButton.small(
            // shape: const CircleBorder(),
            heroTag: null,
            child: const Icon(Icons.save),
            onPressed: () async {
              await saveDocumentToFile();
              showGlobalToast(Global.l10n.post_tip);
              Navigator.pop(context); // 返回上一页
            },
          ),

        ],
      ),
      body: _controller == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          FleatherToolbar.basic(
              controller: _controller!, editorKey: _editorKey),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          Expanded(
            child: FleatherEditor(
              controller: _controller!,
              focusNode: _focusNode,
              editorKey: _editorKey,
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              onLaunchUrl: _launchUrl,
              maxContentWidth: 800,
              embedBuilder: _embedBuilder,
              spellCheckConfiguration: SpellCheckConfiguration(
                  spellCheckService: DefaultSpellCheckService(),
                  misspelledSelectionColor: Colors.red,
                  misspelledTextStyle:
                  DefaultTextStyle.of(context).style),
            ),
          ),
        ],
      ),
    );
  }

  Widget _embedBuilder(BuildContext context, EmbedNode node) {
    if (node.value.type == 'icon') {
      final data = node.value.data;
      // Icons.rocket_launch_outlined
      return Icon(
        IconData(int.parse(data['codePoint']), fontFamily: data['fontFamily']),
        color: Color(int.parse(data['color'])),
        size: 18,
      );
    }

    if (node.value.type == 'image') {
      final sourceType = node.value.data['source_type'];
      ImageProvider? image;
      if (sourceType == 'assets') {
        image = AssetImage(node.value.data['source']);
      } else if (sourceType == 'file') {
        image = FileImage(File(node.value.data['source']));
      } else if (sourceType == 'url') {
        image = NetworkImage(node.value.data['source']);
      }
      if (image != null) {
        return Padding(
          // Caret takes 2 pixels, hence not symmetric padding values.
          padding: const EdgeInsets.only(left: 4, right: 2, top: 2, bottom: 2),
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              image: DecorationImage(image: image, fit: BoxFit.cover),
            ),
          ),
        );
      }
    }

    return defaultFleatherEmbedBuilder(context, node);
  }

  void _launchUrl(String? url) async {
    if (url == null) return;
    final uri = Uri.parse(url);
    final canLaunch = await canLaunchUrl(uri);
    if (canLaunch) {
      await launchUrl(uri);
    }
  }


  Uint8List exportDocumentToBytes() {
    final delta = _controller!.document.toDelta();
    final jsonStr = jsonEncode(delta.toJson());
    final bytes = utf8.encode(jsonStr);
    return Uint8List.fromList(bytes);
  }

  //保存为文件（例如本地 .json 文件）
  Future<void> saveDocumentToFile() async {

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/fleather_doc.json');

    final bytes = exportDocumentToBytes();
    String postUuid = widget.post_uuid ?? "";
    postUuid = file.path;

    //await file.writeAsBytes(bytes);
    await Global.dhtClient.savePost(0, bytes);

    print('保存成功：${file.path}');
  }

  //还原字节流（恢复 Fleather 文档）
  void loadDocumentFromBytes(Uint8List bytes) {
    final jsonStr = utf8.decode(bytes);
    final deltaJson = jsonDecode(jsonStr);
    final delta = Delta.fromJson(deltaJson);
    final doc = ParchmentDocument.fromDelta(delta);
    _controller = FleatherController(document: doc);
    setState(() {}); // 更新界面
  }

  /// 从 image_picker 选择图片并保存到 App 的文档目录
  Future<File?> pickAndSaveImage({ ImageSourceType sourceType = ImageSourceType.gallery,
                    String? customFileName, // 可选的自定义文件名（带扩展名）
                   }) async {

    final picker = ImagePicker();

    try {
      final XFile? pickedFile = await picker.pickImage(
        source: sourceType == ImageSourceType.gallery ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 80
      );

      if (pickedFile == null) return null; // 用户取消选择

      final File tempImage = File(pickedFile.path);

      // 获取保存目录
      final Directory appDir = await getApplicationDocumentsDirectory();

      // 获取文件扩展名（如 .jpg）
      final String extension = p.extension(pickedFile.path);
      final String filename = customFileName ??
      'image_${DateTime.now().millisecondsSinceEpoch}$extension';
      final String savedPath = p.join(appDir.path, "posts", Global.user.uuid);
      createNestedDirectory(savedPath);
      final String imageFile = p.join(savedPath, filename);
      final File savedImage = await tempImage.copy(imageFile);

      return savedImage;
    } catch (e) {
      print('图片选择失败: $e');
      return null;
    }
  }

}

/// This is an example insert rule that will insert a new line before and
/// after inline image embed.
class ForceNewlineForInsertsAroundInlineImageRule extends InsertRule {
  @override
  Delta? apply(Delta document, int index, Object data) {
    if (data is! String) return null;

    final iter = DeltaIterator(document);
    final previous = iter.skip(index);
    final target = iter.next();
    final cursorBeforeInlineEmbed = _isInlineImage(target.data);
    final cursorAfterInlineEmbed =
        previous != null && _isInlineImage(previous.data);

    if (cursorBeforeInlineEmbed || cursorAfterInlineEmbed) {
      final delta = Delta()..retain(index);
      if (cursorAfterInlineEmbed && !data.startsWith('\n')) {
        delta.insert('\n');
      }
      delta.insert(data);
      if (cursorBeforeInlineEmbed && !data.endsWith('\n')) {
        delta.insert('\n');
      }
      return delta;
    }
    return null;
  }

  bool _isInlineImage(Object data) {
    if (data is EmbeddableObject) {
      return data.type == 'image' && data.inline;
    }
    if (data is Map) {
      return data[EmbeddableObject.kTypeKey] == 'image' &&
          data[EmbeddableObject.kInlineKey];
    }
    return false;
  }
}
