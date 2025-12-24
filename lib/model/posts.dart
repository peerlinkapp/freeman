
import 'dart:ffi';

import 'package:freeman/common.dart';

import 'message_elem_type.dart';


enum PostType {
  POST_MINE,
  POST_FOLLOWING,
  POST_HOT

}

class Post {
  Post({
    required this.id,
    required this.uuid,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    this.comments,
    this.likes,
    this.views,
    required this.created_at,
    required this.updated_at,
    required this.isVisible,
    required this.isDeleted,
    this.meVoted = false
  });

  final int id;
  final String uuid;
  final int userId;
  final String userName;
  final String userAvatar;
  final String content;
  late int? comments;
  late int? likes;
  late int? views;
  final int created_at;
  final int updated_at;
  final bool isVisible;
  final bool isDeleted;
  late bool? meVoted;

// 将 Post 转换为 Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'comments':comments,
      'likes':likes,
      'views':views,
      'created_at':created_at,
      'updated_at':updated_at,
      'isVisible':isVisible,
      'isDeleted':isDeleted,
      'meVoted':meVoted
    };
  }

  static void delPost(int id)
  {
    Global.dhtClient.delPost(id);
  }
  static Future<bool> upvote(int id) async
  {
    return await Global.dhtClient.upvotePost(id);
  }
  static Future<bool> reply(int id, int parent_id, String content) async
  {
    return await Global.dhtClient.replyPost(id, parent_id, content);
  }

  static Future<List<Comment>> getReplys(int id) async
  {
    List<Comment> allComments = await Global.dhtClient.getPostReplys(id);
/*
    List<Comment> allComments = [
      Comment(id: 9, user: '用户IGG', content: '新评论内容', parentId: 0),
      Comment(id: 8, user: '用户H', content: '新评论内容', parentId: 0),
      Comment(id: 4, user: '用户D', content: '新评论内容', parentId: 0),
      Comment(id: 5, user: '用户E', content: '新评论内容', parentId: 0),
      Comment(id: 6, user: '用户F', content: '新评论内容', parentId: 0),
      Comment(id: 7, user: '用户G', content: '新评论内容', parentId: 0),
      Comment(id: 3, user: '用户C', content: '有道理', parentId: 2),
      Comment(id: 2, user: '用户B', content: '我同意！', parentId: 1),
      Comment(id:1, user: '用户AA', content: '这是第一条评论', parentId: 0),
    ];*/

    return allComments;
  }

}


class Comment {
  final int id;
  final String user;
  final String content;
  late int? likes;
  final int? parentId;
  final int created_at;
  late bool? meVoted;


  Comment({
    required this.id,
    required this.user,
    required this.content,
    this.created_at = 0,
    this.likes = 0,
    this.meVoted = false,
    this.parentId}
      );

}

