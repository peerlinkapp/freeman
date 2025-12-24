import 'package:flutter/material.dart';
import '../../common.dart';
import '../../common/ui/pop_view.dart';

class ReplyBottomSheet extends StatefulWidget {

  ReplyBottomSheet({required this.postid});

  final int postid;

  @override
  State<ReplyBottomSheet> createState() => _ReplyBottomSheetState();
}

class _ReplyBottomSheetState extends State<ReplyBottomSheet> {
  final TextEditingController _replyController = TextEditingController();
  int _replyingPostId = 0;
  int _replyingParentId = 0;
  String _hint = '';

  List<Comment> allComments = [];

  late Map<String, List<Comment>> ? commentMap;
  late List<Comment>? rootComments;
  Offset? tapPos;

  @override
  void initState() {
    super.initState();
    _replyingPostId = widget.postid;
    _hint = Global.l10n.post_write_here;
    _loadComments(); // 调用一个 async 方法
  }

  Future<void> _loadComments() async {
    allComments = await Post.getReplys(widget.postid);
    setState(() {}); // 加载完成后刷新 UI
  }

  @override
  Widget build(BuildContext context) {
    commentMap = buildCommentMap(allComments);
    rootComments = commentMap!['root'] ?? [];
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              _buildDragHandle(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  physics: ClampingScrollPhysics(), // 或 BouncingScrollPhysics()
                  itemCount: rootComments!.length,
                  itemBuilder: (context, index) {
                    final comment = rootComments![index];
                    return buildCommentItem(comment, commentMap!, 0);
                  },
                ),
              ),
              if (_replyingPostId != 0) _buildGlobalReplyBox(context),
            ],
          ),
        );
      },
    );
  }


  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }


  Widget _buildGlobalReplyBox(BuildContext context) {
    return SafeArea(
        top: false,
        child:
        Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(    //回复编辑框
              controller: _replyController,
              decoration: InputDecoration(
                hintText: _hint, //Global.l10n.post_write_here
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () async {
              final replyText = _replyController.text.trim();
              if (replyText.isNotEmpty && _replyingPostId != null) {
                print("[Reply] post id:${_replyingPostId}, _replyingParentId:${_replyingParentId}, replyText:$replyText");
                await Post.reply(_replyingPostId, _replyingParentId, replyText);
                _replyController.clear();
                _replyingPostId = 0;
                await _loadComments();

              }
            },
          ),
        ],
      ),
        ),
    );
  }


  Map<String, List<Comment>> buildCommentMap(List<Comment> comments) {
    Map<String, List<Comment>> map = {};

    for (var comment in comments) {
      int parentId = comment.parentId ?? 0;
      final key = parentId ==0 ? "root" : parentId.toString();
      map.putIfAbsent(key, () => []).add(comment);
    }

    return map;
  }



  void _showMenu(BuildContext context, Offset tapPos, int comment_id) {

    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject()! as RenderBox;
    final RelativeRect position = RelativeRect.fromLTRB(tapPos.dx, tapPos.dy,
        overlay.size.width - tapPos.dx, overlay.size.height - tapPos.dy);
    showMenu<String>(
        context: context,
        position: position,
        items: <MyPopupMenuItem<String>>[
          MyPopupMenuItem(value: Global.l10n.del, child: Text(Global.l10n.del)),
          // ignore: missing_return
        ]).then<void>((String? selected) async {
      if(selected == Global.l10n.del)
      {
        Global.dhtClient.delReply(comment_id);
      }
      await _loadComments();
    });
  }


  Widget buildCommentItem(Comment comment, Map<String, List<Comment>> commentMap, int indent) {
    String created_at = DateTimeUtils.getHumanReadableDate(comment.created_at);
    //created_at = comment.created_at.toString();
    return Padding(
      padding: EdgeInsets.only(left: 8+16.0 * indent, top: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
              onTap: () {

                setState(() {
                  if(_replyingParentId == 0) {
                    _replyingParentId = comment.id;
                    _hint = "${Global.l10n.post_reply}${comment.user}: ";
                    print("Container clicked ${_replyingParentId} user:${comment
                        .user}");
                  }else{
                    _replyingParentId = 0;
                    _hint = Global.l10n.post_write_here;
                  }

                });
              },
              onTapDown: (TapDownDetails details) {
                tapPos = details.globalPosition;
              },
              onLongPress: () {
                _showMenu(
                    context,
                    tapPos!,
                    comment.id
                );
              },
              child:
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("${comment.user} ", style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 10), // 可选：添加间距
                            Text("${created_at} ", style: TextStyle(fontSize: 12.0)),
                            Spacer(), // 推动后面的图标到最右
                            InkWell(
                                onTap: () async {
                                  await Global.dhtClient.upvoteReply(comment.id);
                                  await _loadComments();
                                },
                              child: Row(
                                children: [
                                  Icon(comment.meVoted ?? false ? Icons.thumb_up_alt: Icons.thumb_up_alt_outlined, size: 18, color: Colors.grey), // 未点赞
                                  SizedBox(width: 4),
                                  Text(
                                    "${comment.likes}",
                                    style: TextStyle(fontSize: 12.0, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(comment.content),

                      ],
                    ),
                  )
          ),
          ...?commentMap[comment.id.toString()]?.map((child) =>
              buildCommentItem(child, commentMap, indent + 1)),
        ],
      ),
    );
  }

}
