#pragma once

/**
 * 本文件为针对freex提供的接口的使用，对其针对apk需要用到的功能，做简要封装；
 * 使用ffigen转换为dart接口后，再在dhtclient.dart中使用binding接口再为dart封装一下，供apk使用 *
 */

#include "include/dart_api_dl.h"

#define ID_LEN 40
#define FILE_READ_ONCE_BYTES 1024
#define FILE_MAX_PATH 1024
#define UUID_LEN 36
#define ANNOUNCEMENT_SIZE 1000 //群聊公告长度

#define NAME_MAX_LEN 100 //名称的最大长度
#define REMARK_MAX_LEN 1000 //备注的最大长度
#define MSG_CONTENT_MAX_LEN 2048 //
#define POST_ITEM_CONTENT_BYTES 1000 //动态列表中，显示的动态内容长度

/**
 * 使用方法：，
 * 1. 切换注释#define EXPORT为空
 * 2.在项目目录（pubspec.yaml同级目录）下运行： dart run ffigen
 * 3.在生成lib\generated_bindings.dart后，重新切换EXPORT宏注释
 */

//输出接口，才可以被ffi调用
#define EXPORT extern "C" __attribute__((visibility("default"))) __attribute__((used))
//#define EXPORT    //使用ffigen时，需要将EXPORT定义为空

typedef  void* DhtClientObj;


typedef struct {
    int id;
    char hashid[ID_LEN+1]; //uuid
    char avatar[FILE_MAX_PATH+1]; //头像文件路径
    char name[NAME_MAX_LEN+1]; //昵称
    char addme_q;
    char addme_a;
    int addme_mode;
    int  sex;
    int  age;
    char slogan[NAME_MAX_LEN+1]; //签名
}UserEntity;

typedef struct {
    uint64_t id;
    char hashid[ID_LEN+1]; //hashid
    char inviteCode[UUID_LEN+1]; //uuid
    char avatar[FILE_MAX_PATH+1]; //头像文件路径
    char name[NAME_MAX_LEN+1]; //昵称
    char alias[NAME_MAX_LEN+1]; //备注名
    char remark[REMARK_MAX_LEN+1]; //备注
    uint64_t updateTime;
    int ftype; //好友类型，参见
    int sex; //性别
}ContactEntity;


typedef struct {
    int64_t msgID;
    int64_t randID;
    uint64_t conversationID ; //会话id
    int msgType; //消息类型：MessageElemType
    char content[MSG_CONTENT_MAX_LEN+1]; //会话名（对方名或群名/话题名）
    char senderID[ID_LEN+1]; //发送者id
    char senderName[NAME_MAX_LEN]; //发送者昵称
    char senderAvatar[FILE_MAX_PATH]; //头像
    uint64_t updateTime;
}MessageItem;

typedef struct {
    uint64_t id; //
    char uuid[UUID_LEN+1];
    char showName[NAME_MAX_LEN+1]; //会话名（对方名或群名/话题名）
    char announcement[ANNOUNCEMENT_SIZE+1]; //会话名（对方名或群名/话题名）
    char faceUrl[FILE_MAX_PATH+1]; //图标
    MessageItem lastMessage;//最近一次的消息
    int istop;//是否置顶
    int isGroup;//是否群聊
    int isPublic; //是否公开
    int isEnable; //是否有效
    int role; //角色
    int unreadCount; //未读消息条数
    uint64_t createTime; //创建时间
    uint64_t updateTime; //更新时间
}ConversationItem;

typedef struct {
    uint64_t id; //
    uint64_t parentId; // 父id(用于展示树状回复）
    char uuid[ID_LEN+1];
    uint64_t userId; //
    char userName[NAME_MAX_LEN+1];
    char userAvatar[FILE_MAX_PATH+1];
    char content[POST_ITEM_CONTENT_BYTES+1];
    uint32_t comments;
    uint32_t likes;
    uint32_t views;
    uint64_t created_at;
    uint64_t updated_at;
    bool isVisible;
    bool isDeleted;
    bool meVoted;
}PostItem;

typedef struct {
    uint64_t userId;
    char name[NAME_MAX_LEN+1];
    char avatar[FILE_MAX_PATH+1];
    uint8_t role;
}GroupUserInfo;

//网络回调
EXPORT void set_net_status_sendport(Dart_Port_DL main_isolate_send_port);

// 定义一个加好友回调类型
typedef void (*AddFriendCallback)(int value);
// 设置
EXPORT void set_recv_add_friend_result_sendport(Dart_Port_DL main_isolate_send_port);

// 设置查找用户回调函数
EXPORT void set_find_user_sendport(Dart_Port_DL main_isolate_send_port);

// 设置加好友回调函数
EXPORT void set_add_me_sendport(Dart_Port_DL main_isolate_send_port);

//设置消息发送监控
EXPORT void set_msg_sent_sendport(Dart_Port_DL main_isolate_send_port);
// 设置收到消息回调方法
EXPORT void set_recv_msg_sendport(Dart_Port_DL main_isolate_send_port);

// 设置新帖到达通知
EXPORT void set_new_post_sendport(Dart_Port_DL main_isolate_send_port);

//设置文件发送监控
EXPORT void set_file_sent_sendport(Dart_Port_DL main_isolate_send_port);

//创建dhtclient对象
EXPORT DhtClientObj dhtclient_create(const char* path);

EXPORT int dhtclient_login(DhtClientObj obj, const char* user, const char* pwd);

EXPORT int dhtclient_regist(DhtClientObj obj, const char* user, const char* pwd);

//设置帐号关联参数
EXPORT void         dhtclient_set_cfg(DhtClientObj obj, const char* key, const char* value);
//获取帐号关联参数
EXPORT const char * dhtclient_get_cfg(DhtClientObj obj, const char* key);

//获取id
EXPORT const char *dhtclient_getid(DhtClientObj obj);
//获取邀请码
EXPORT const char *dhtclient_get_invite_code(DhtClientObj obj);
//重新生成邀请码
EXPORT const char *dhtclient_regen_invite_code(DhtClientObj obj);


//获取用户表中的userid
EXPORT uint64_t dhtclient_get_userid(DhtClientObj obj);

/*添加好友
 * user: Hashid截短后转换为十进制后的数值字符串
 * 返回值：freex错误代码
*/
EXPORT void dhtclient_find_user(DhtClientObj obj, const char* user);


/*发送消息
*/
EXPORT uint64_t dhtclient_send_msg(DhtClientObj obj, uint64_t cid, const char* content);

//删除消息
EXPORT void dhtclient_del_msg(DhtClientObj obj, int64_t id);

EXPORT uint64_t dhtclient_send_img_msg(DhtClientObj obj, const char* dest_hashid, const char* imgfile);

//发送文件
EXPORT uint64_t dhtclient_send_file(DhtClientObj obj, const char* dest_hashid, const char* filepath);

//根据文件消息id，获取文件保存路径
EXPORT const char * dhtclient_get_msg_file_path(DhtClientObj obj, uint64_t cid);

//发送语音文件
EXPORT uint64_t dhtclient_send_audio_file(DhtClientObj obj, const char* dest_hashid, const char* filepath);


EXPORT void dhtclient_release(DhtClientObj obj);

EXPORT intptr_t ffi_Dart_InitializeApiDL(void* data);

/***************************    好友******************************/
//发送添加好友请求给远端
EXPORT void dhtclient_send_add_friend(DhtClientObj obj, const char* contact_hashid);

EXPORT bool dhtclient_send_apply_friend_reply(DhtClientObj obj, const char* contact_hashid, bool allow);

//添加好友/联系人
EXPORT void dhtclient_add_contact(DhtClientObj obj, const char* contact_hashid, const char* contact_name);
//删除好友/联系人
EXPORT void dhtclient_del_contact(DhtClientObj obj, const char* contact_hashid);
//获取联系人
EXPORT  ContactEntity* dhtclient_get_contacts(DhtClientObj obj,  int* count , int ftype);
//用于释放dhtclient_get_contacts接口获取的数据内存
EXPORT void  dhtclient_free_contacts(ContactEntity* list);
//获取好友资料
EXPORT  void dhtclient_get_contact_profile(DhtClientObj obj,  const char* hashid, ContactEntity* c);
EXPORT  void dhtclient_get_contact_profile2(DhtClientObj obj,  uint64_t uid, ContactEntity* c);

//修改好友别名
EXPORT  void dhtclient_set_contact_alias(DhtClientObj obj,  uint64_t id, const char* alias);
//设置联系人备注
EXPORT  void dhtclient_set_contact_remark(DhtClientObj obj,  uint64_t id, const char* remark);

//获取用户是否p2p连接已连通
EXPORT bool dhtclient_is_contact_p2p(DhtClientObj obj, const char* contact_hashid);

/***************************    会话  ******************************/

//获取会话详细资料
EXPORT void dhtclient_get_conversation_profile(DhtClientObj obj, uint64_t cid, ConversationItem* c);

//获取聊天列表
EXPORT  ConversationItem* dhtclient_get_conversations(DhtClientObj obj,  int* count );
//用于释放 dhtclient_get_conversations 接口获取的数据内存
EXPORT void  dhtclient_free_conversations(ConversationItem* list);

//获取群聊列表, count：输出参数，获取到的条目数量
EXPORT  ConversationItem* dhtclient_get_groups(DhtClientObj obj,  int* count);


//获取消息列表
EXPORT  MessageItem* dhtclient_get_messages(DhtClientObj obj, int conversationID, int offset, int* count);
//用于释放 dhtclient_get_conversations 接口获取的数据内存
EXPORT void  dhtclient_free_messages(MessageItem* list);

//获取未读消息条数
EXPORT int dhtclient_get_messages_unread(DhtClientObj obj, int cid);
//设置会话消息已读
EXPORT void dhtclient_set_messages_read(DhtClientObj obj, int cid);

//根据会话id，获取对方hashid
EXPORT const char *dhtclient_get_remote_id(DhtClientObj obj, uint64_t cid);

//根据对方hashid，获取会话id
EXPORT  uint64_t dhtclient_get_conv_id(DhtClientObj obj, const char* remoteid);

//创建会话（单人）
EXPORT  uint64_t dhtclient_create_conversation_c2c(DhtClientObj obj, const char* remoteid);

//创建群聊（公开/私有）
EXPORT uint64_t dhtclient_create_conversation(DhtClientObj obj, const char* title,  const char* notice, const uint64_t* members, const uint64_t members_count, bool isPublic);
//清除会话消息
EXPORT void dhtclient_clear_conversation(DhtClientObj obj, int id);
//删除会话
EXPORT  bool dhtclient_del_conversation(DhtClientObj obj, const char* id);
//置顶会话
EXPORT  bool dhtclient_pin_conversation(DhtClientObj obj, const char* id, int istop);
//获取会话是否置顶
EXPORT  bool dhtclient_is_conversation_pintop(DhtClientObj obj, const char* id);

//设置群名
EXPORT void dhtclient_set_group_name(DhtClientObj obj, uint64_t cid, const char* title);
EXPORT void dhtclient_set_group_notice(DhtClientObj obj, uint64_t cid, const char* content);
/***************************    群    ******************************/
//获取群成员
EXPORT GroupUserInfo* dhtclient_get_group_members(DhtClientObj obj, uint64_t cid, int* count);
EXPORT void  dhtclient_free_group_members(GroupUserInfo* list);

//增加群会员
EXPORT int dhtclient_group_add_members(DhtClientObj obj, int cid, const uint64_t* users, int count);
//删除群会员
EXPORT void dhtclient_group_drop_members(DhtClientObj obj, int cid, const uint64_t* users, int count);
/***************************** 我的 *****************************/
//修改昵称
EXPORT  bool dhtclient_change_nickname(DhtClientObj obj, const char* name);
//设置头像
EXPORT  void dhtclient_set_avatar(DhtClientObj obj, const char* avatar);
//设置性别
EXPORT  void dhtclient_set_sex(DhtClientObj obj, int sex);
//设置性别
EXPORT  void dhtclient_set_slogan(DhtClientObj obj, const char* slogan);
//获取档案信息
EXPORT  void dhtclient_get_user_profile(DhtClientObj obj, const char* hashid, UserEntity* user);

//设置加我为好友的模式
EXPORT  void dhtclient_set_addmemode(DhtClientObj obj, int mode);
//获取加我好友的模式
EXPORT  int dhtclient_get_addmemode(DhtClientObj obj);

//执行sql
EXPORT  void dhtclient_sql(DhtClientObj obj, const char* sql);


/***************************** P2P *****************************/
EXPORT  void dhtclient_create_p2p(DhtClientObj obj, const char* remoteid);
//获取对端相关信息，如p2p连接信息
EXPORT const char *dhtclient_get_remote_stats(DhtClientObj obj, const char* cid);


//
EXPORT  void dhtclient_free_string(const char* str);

/*************************     Post动态/帖子/朋友圈、          *********************/
EXPORT int dhtclient_write_post(DhtClientObj obj, int id, const uint8_t* data, int length);
//获取动态列表
EXPORT PostItem* dhtclient_get_posts(DhtClientObj obj, int postType, int userid, int offset, int* count );

EXPORT void  dhtclient_free_posts(PostItem* list);

//删帖
EXPORT void dhtclient_del_post(DhtClientObj obj, uint64_t id);
//点赞
EXPORT bool dhtclient_upvote_post(DhtClientObj obj, uint64_t id);
//回复
EXPORT bool dhtclient_reply_post(DhtClientObj obj, uint64_t post_id, uint64_t parent_id, const char* data);
//获取回复列表
EXPORT PostItem* dhtclient_get_post_replys(DhtClientObj obj, uint64_t post_id, int* count);
//删除回复
EXPORT void dhtclient_del_reply(DhtClientObj obj, uint64_t id);
//评论点赞
EXPORT bool dhtclient_upvote_reply(DhtClientObj obj, uint64_t id);
/********** 各种获取路径 ************/
//获取用户数据目录
EXPORT const char* dhtclient_get_user_path(DhtClientObj obj);
