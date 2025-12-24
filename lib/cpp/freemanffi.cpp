#include <stdint.h>
#include "dart_api_dl.h"
#include "freex.h"
#include "freemanffi.h"
#include <android/log.h>
#include <map>

#if defined(__ANDROID__)
#include <android/log.h>
#define LOG_TAG "NativeCode"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)
#elif defined(__APPLE__)
#include <Foundation/Foundation.h>
#define LOGI(...) NSLog(@__VA_ARGS__)
#define LOGE(...) NSLog(@__VA_ARGS__)
#else
#include <stdio.h>
#define LOGI(...) printf(__VA_ARGS__); printf("\n")
#define LOGE(...) printf(__VA_ARGS__); printf("\n")
#endif

Dart_Port_DL find_user_send_port;
Dart_Port_DL add_me_send_port;
Dart_Port_DL recv_msg_send_port;
Dart_Port_DL recv_applyaddfriend_result_send_port;
Dart_Port_DL net_status_send_port;
Dart_Port_DL new_post_send_port;
//发送消息结果
Dart_Port_DL msg_sent_port;
//文件发送进度结果
Dart_Port_DL file_sent_port;

void set_net_status_sendport(Dart_Port_DL main_isolate_send_port)
{
    net_status_send_port = main_isolate_send_port;
}

void on_net_status_change(bool& avail) {
    const int COUNT = 1;
    Dart_CObject array[COUNT];
    array[0].type = Dart_CObject_kBool;
    array[0].value.as_bool = avail;

    Dart_CObject message;
    message.type = Dart_CObject_kArray;
    Dart_CObject* array_ptr[COUNT];// 创建指针数组
    for(int i=0; i<COUNT; i++)
    {
        array_ptr[i] = &array[i];
    }
    message.value.as_array.values = array_ptr;  // 赋值指针数组
    message.value.as_array.length = COUNT;

    LOGE("Posting on_net_status_change\n");

    const bool result = Dart_PostCObject_DL(net_status_send_port, &message);
    if(!result)
    {
        LOGE("Posting on_net_status_chang message to port failed.\n");
    }
}

void on_find_user(FX::UserEntity& user)
{
    const int count = 7;
    Dart_CObject array[count];
    array[0].type = Dart_CObject_kString;
    array[0].value.as_string = user.hashid.c_str();
    array[1].type = Dart_CObject_kString;
    array[1].value.as_string = user.inviteCode.c_str();
    array[2].type = Dart_CObject_kString;
    array[2].value.as_string = user.name.c_str();
    array[3].type = Dart_CObject_kString;
    array[3].value.as_string = user.avatar.c_str();
    array[4].type = Dart_CObject_kString;
    array[4].value.as_string = user.addme_q.c_str();
    array[5].type = Dart_CObject_kString;
    array[5].value.as_string = user.addme_a.c_str();
    array[6].type = Dart_CObject_kInt32;
    array[6].value.as_int32 = user.addme_mode;

    Dart_CObject message;
    message.type = Dart_CObject_kArray;
    Dart_CObject* array_ptr[count];// 创建指针数组
    for(int i=0; i<count; i++)
    {
        array_ptr[i] = &array[i];
    }
    message.value.as_array.values = array_ptr;  // 赋值指针数组
    message.value.as_array.length = count;

    const bool result = Dart_PostCObject_DL(find_user_send_port, &message);
    if(!result)
    {
        LOGE("Posting find_user message to port failed.\n");
    }
}

void on_recv_add_remote_reply(const std::string& remoteid, int result)
{
    const int count = 1;
    Dart_CObject array[count];
    array[0].type = Dart_CObject_kString;
    array[0].value.as_string = remoteid.c_str();

    Dart_CObject message;
    message.type = Dart_CObject_kArray;
    Dart_CObject* array_ptr[count];// 创建指针数组
    for(int i=0; i<count; i++)
    {
        array_ptr[i] = &array[i];
    }
    message.value.as_array.values = array_ptr;  // 赋值指针数组
    message.value.as_array.length = count;

    const bool ret = Dart_PostCObject_DL(recv_applyaddfriend_result_send_port, &message);
    if(!ret)
    {
        printf("C: Posting on_recv_add_remote_reply message to port failed.\n");
    }else{
        printf("C: Posting on_recv_add_remote_reply message to port success.\n");
    }
}

void set_recv_add_friend_result_sendport(Dart_Port_DL main_isolate_send_port)
{
    recv_applyaddfriend_result_send_port = main_isolate_send_port;
}

void set_find_user_sendport(Dart_Port_DL main_isolate_send_port)
{
    find_user_send_port = main_isolate_send_port;
}

void set_add_me_sendport(Dart_Port_DL main_isolate_send_port)
{
    add_me_send_port = main_isolate_send_port;
}

void on_recv_msg(const FX::MessageEntity& msg)
{
    //LOGE("[on_recv_msg] msgID:%lu", msg.msgID);
    const int COUNT = 8;
    Dart_CObject array[COUNT];
    array[0].type = Dart_CObject_kInt64;
    array[0].value.as_int64 = msg.msgID;
    array[1].type = Dart_CObject_kInt64;
    array[1].value.as_int64 = msg.randID;
    array[2].type = Dart_CObject_kString;
    array[2].value.as_string = msg.senderID.c_str();
    array[3].type = Dart_CObject_kString;
    array[3].value.as_string = msg.content.c_str();
    array[4].type = Dart_CObject_kInt64;
    array[4].value.as_int64 =msg.updateTime;
    array[5].type = Dart_CObject_kString;
    array[5].value.as_string = msg.avatar.c_str();
    array[6].type = Dart_CObject_kInt32;
    array[6].value.as_int32 = msg.msgType;
    array[7].type = Dart_CObject_kString;
    array[7].value.as_string = msg.ext.c_str();

    Dart_CObject message;
    message.type = Dart_CObject_kArray;
    Dart_CObject* array_ptr[COUNT];// 创建指针数组
    for(int i=0; i<COUNT; i++)
    {
        array_ptr[i] = &array[i];
    }
    message.value.as_array.values = array_ptr;  // 赋值指针数组
    message.value.as_array.length = COUNT;

    const bool result = Dart_PostCObject_DL(recv_msg_send_port, &message);
    if(!result)
    {
        printf("C: Posting recv message to port failed.\n");
    }
}
void set_recv_msg_sendport(Dart_Port_DL main_isolate_send_port)
{
    recv_msg_send_port = main_isolate_send_port;
}

void set_msg_sent_sendport(Dart_Port_DL main_isolate_send_port)
{
    msg_sent_port = main_isolate_send_port;
}

void on_msg_sent(FX::MsgSendStats& msg_stats)
{
    const int count = 4;
    Dart_CObject array[count];
    array[0].type = Dart_CObject_kInt64;
    array[0].value.as_int64 = msg_stats.msgId;
    array[1].type = Dart_CObject_kInt32;
    array[1].value.as_int32 = msg_stats.status;
    array[2].type = Dart_CObject_kString;
    array[2].value.as_string = msg_stats.errStr.c_str();
    array[3].type = Dart_CObject_kDouble;
    array[3].value.as_double = msg_stats.progress;

    Dart_CObject message;
    message.type = Dart_CObject_kArray;
    Dart_CObject* array_ptr[count];// 创建指针数组
    for(int i=0; i<count; i++)
    {
        array_ptr[i] = &array[i];
    }
    message.value.as_array.values = array_ptr;  // 赋值指针数组
    message.value.as_array.length = count;

    const bool ret = Dart_PostCObject_DL(msg_sent_port, &message);
    if(!ret)
    {
        LOGE("[on_msg_sent] Posting on_msg_sent message to port failed.\n");
    }
}

void set_file_sent_sendport(Dart_Port_DL main_isolate_send_port)
{
    file_sent_port = main_isolate_send_port;
}

void on_file_sent(FX::FileTransStats& stats)
{
    const int count = 2;
    Dart_CObject array[count];
    array[0].type = Dart_CObject_kInt64;
    array[0].value.as_int64 = stats.fileid;
    array[1].type = Dart_CObject_kDouble;
    array[1].value.as_double = stats.progress;

    Dart_CObject message;
    message.type = Dart_CObject_kArray;
    Dart_CObject* array_ptr[count];// 创建指针数组
    for(int i=0; i<count; i++)
    {
        array_ptr[i] = &array[i];
    }
    message.value.as_array.values = array_ptr;  // 赋值指针数组
    message.value.as_array.length = count;

    const bool ret = Dart_PostCObject_DL(file_sent_port, &message);
    if(!ret)
    {
        LOGE("[on_file_sent] Posting message to port failed.\n");
    }
}

//收到添加我的请求，处理之（允许/拒绝)
void on_add_me_request(FX::FriendEntity &f, int mode, FX::DhtClient* dht)
{
    const int COUNT = 3;
    Dart_CObject array[COUNT];
    array[0].type = Dart_CObject_kString;
    array[0].value.as_string = f.hashid.c_str();
    array[1].type = Dart_CObject_kString;
    array[1].value.as_string = f.name.c_str();
    array[2].type = Dart_CObject_kString;
    array[2].value.as_string = f.avatar.c_str();

    Dart_CObject message;
    message.type = Dart_CObject_kArray;
    Dart_CObject* array_ptr[COUNT];// 创建指针数组
    for(int i=0; i<COUNT; i++)
    {
        array_ptr[i] = &array[i];
    }
    message.value.as_array.values = array_ptr;  // 赋值指针数组
    message.value.as_array.length = COUNT;

    const bool result = Dart_PostCObject_DL(add_me_send_port, &message);
    if(!result)
    {
        LOGE("Posting add_friend message to port failed.\n");
    }

    switch(mode)
    {
        case FX::ApplyFriendMode::NEED_MY_CHECK:
            //调用回调方法，通用上层加好友申请
            //dht->send_AddFriendReply(f.id, true);
            break;

    }
}


void set_new_post_sendport(Dart_Port_DL main_isolate_send_port)
{
    new_post_send_port = main_isolate_send_port;
}

void on_new_post(FX::PostEntify& post)
{
    const int COUNT = 14;
    Dart_CObject array[COUNT];
    array[0].type = Dart_CObject_kInt64;
    array[0].value.as_int64 = post.id;
    array[1].type = Dart_CObject_kString;
    array[1].value.as_string = post.uuid.c_str();
    array[2].type = Dart_CObject_kInt64;
    array[2].value.as_int64 = post.userId;
    array[3].type = Dart_CObject_kString;
    array[3].value.as_string = post.userName.c_str();
    array[4].type = Dart_CObject_kString;
    array[4].value.as_string = post.userAvatar.c_str();
    array[5].type = Dart_CObject_kString;
    array[5].value.as_string = post.content.c_str();
    array[6].type = Dart_CObject_kInt32;
    array[6].value.as_int32 = post.comments;
    array[7].type = Dart_CObject_kInt32;
    array[7].value.as_int32 = post.likes;
    array[8].type = Dart_CObject_kInt32;
    array[8].value.as_int32 = post.views;
    array[9].type = Dart_CObject_kInt64;
    array[9].value.as_int64 = post.created_at;
    array[10].type = Dart_CObject_kInt64;
    array[10].value.as_int64 = post.updated_at;
    array[11].type = Dart_CObject_kBool;
    array[11].value.as_bool = post.isVisible;
    array[12].type = Dart_CObject_kBool;
    array[12].value.as_bool = post.isDeleted;
    array[13].type = Dart_CObject_kBool;
    array[13].value.as_bool = post.meVoted;

    Dart_CObject message;
    message.type = Dart_CObject_kArray;
    Dart_CObject* array_ptr[COUNT];// 创建指针数组
    for(int i=0; i<COUNT; i++)
    {
        array_ptr[i] = &array[i];
    }
    message.value.as_array.values = array_ptr;  // 赋值指针数组
    message.value.as_array.length = COUNT;

    const bool result = Dart_PostCObject_DL(new_post_send_port, &message);
    if(!result)
    {
        LOGE("Posting new post to port failed!");
    }
}


const char *dhtclient_getid(DhtClientObj obj){
    FX::DhtClient *client = (FX::DhtClient *)obj;
    return strdup(client->id().c_str());
}

const char *dhtclient_get_invite_code(DhtClientObj obj) {
    FX::DhtClient *client = (FX::DhtClient *)obj;
    return strdup(client->getInviteCode().c_str());
}

const char *dhtclient_regen_invite_code(DhtClientObj obj) {
    FX::DhtClient *client = (FX::DhtClient *)obj;
    return strdup(client->genInviteCode().c_str());
}

DhtClientObj dhtclient_create(const char* path)
{
    std::string strPath = path;
    FX::DhtClient *client = new FX::DhtClient(strPath);
    //网络状态回调
    client->setNetStatusCbk(on_net_status_change);
    //设置发送消息结果回调
    client->setMsgSentResultCbk(on_msg_sent);
    //设置收到消息回调
    client->setRecvMsgCbk(on_recv_msg);
    //设置查找用户结果回调
    client->setFindFriendResultCbk(on_find_user);
    //设置收到加好友回复回调
    client->setAddFriendReplyNotifyCbk(on_recv_add_remote_reply);
    //对方收到添加我的请求，处理之（允许/拒绝)
    client->setAddMeNotifyCbk(on_add_me_request);
    //动态
    client->setAddPostNotifyCbk(on_new_post);
    //文件发送进度回调
    client->setFileSentResultCbk(on_file_sent);
    return client;
}

void dhtclient_release(DhtClientObj obj)
{
    FX::DhtClient *client = (FX::DhtClient *)obj;
    delete client;
}

int dhtclient_login(DhtClientObj obj, const char* user, const char* pwd)
{
    FX::DhtClient *client = (FX::DhtClient *)obj;
    return client->login(user, pwd) ? 1 : 0;
}

int dhtclient_regist(DhtClientObj obj, const char* user, const char* pwd)
{
    FX::DhtClient *client = (FX::DhtClient *)obj;
    return client->regist(user, pwd) ? 1 : 0;
}

void dhtclient_find_user(DhtClientObj obj, const char* user)
{
    if(obj == 0) return;


    FX::DhtClient *client = (FX::DhtClient *)obj;

    client->send_FindFriend(user);


}

intptr_t ffi_Dart_InitializeApiDL(void* data) {
    return Dart_InitializeApiDL(data);
}

void dhtclient_send_add_friend(DhtClientObj obj, const char* contact_hashid) {
    if(obj == 0) return;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    client->send_AddFriend(contact_hashid);
}

bool dhtclient_send_apply_friend_reply(DhtClientObj obj, const char* contact_hashid, bool allow)
{
    if(obj == 0) return false;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    client->send_AddFriendReply(contact_hashid, allow);
    return true;
}
//
void dhtclient_add_contact(DhtClientObj obj, const char* contact_hashid, const char* contact_name)
{
    if(obj == 0) return;

    FX::DhtClient *client = (FX::DhtClient *)obj;
    std::string hashid = contact_hashid;
    std::string name = contact_name;
    LOGE("dhtclient_add_contact:%s, %s", contact_hashid, contact_name);
    client->addFriend(hashid, name);
}

void dhtclient_del_contact(DhtClientObj obj, const char* contact_hashid)
{
    if(obj == 0) return;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    LOGE("dhtclient_del_contact:%s", contact_hashid);
    client->delFriend(contact_hashid);
}

void dhtclient_get_contact_profile2(DhtClientObj obj,  uint64_t uid, ContactEntity* c)
{
    if(obj == 0) return;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    std::string hashid = client->getContactHashId(uid);
    dhtclient_get_contact_profile(obj, hashid.c_str(), c);
}
void dhtclient_get_contact_profile(DhtClientObj obj,  const char* hashid, ContactEntity* c)
{
    if(obj == 0) return;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    FX::FriendEntity f;
    client->getFriendProfile(hashid, f);
    c->id = f.id;
    std::strcpy(c->hashid, f.hashid.c_str());
    std::strcpy(c->name, f.name.c_str());
    std::strcpy(c->avatar, f.avatar.c_str());
    std::strcpy(c->alias, f.alias.c_str());
    std::strcpy(c->remark, f.remark.c_str());
    std::strcpy(c->inviteCode, f.inviteCode.c_str());
    c->ftype = static_cast<int>(f.ftype);
    c->sex = f.sex;
    c->updateTime = f.updateTime;
}
// 示例方法：返回一个 FriendList（动态分配内存）
ContactEntity* dhtclient_get_contacts(DhtClientObj obj, int* count, int ftype) {
    if(obj == 0) return NULL;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    std::map<std::string, FX::FriendEntity> contacts = client->getContacts(static_cast<FX::AddFriendProgress>(ftype));
    *count = contacts.size();
    //LOGE("dhtclient_get_contacts:%d", *count);
    // 将 C++ vector 转换为 FriendList（指针数组）
    ContactEntity* entrys = new ContactEntity[contacts.size()];
    std::map<std::string, FX::FriendEntity>::iterator it = contacts.begin();
    int i=0;
    for(; it != contacts.end(); ++it)
    {
        entrys[i].id =  it->second.id;
        entrys[i].sex = it->second.sex;
        std::strcpy(entrys[i].hashid, it->second.hashid.c_str());
        std::strcpy(entrys[i].inviteCode, it->second.inviteCode.c_str());
        std::strcpy(entrys[i].name, it->second.name.c_str());
        std::strcpy(entrys[i].avatar, it->second.avatar.c_str());
        std::strcpy(entrys[i].alias, it->second.alias.c_str());
        std::strcpy(entrys[i].remark, it->second.remark.c_str());
        entrys[i].ftype = static_cast<int>(it->second.ftype);
        entrys[i].updateTime = it->second.updateTime;
        i++;
    }
    return entrys;
}

// 示例方法：释放分配的 FriendList
void dhtclient_free_contacts(ContactEntity* list) {
    delete[] list;
}

void dhtclient_set_contact_alias(DhtClientObj obj,  uint64_t id, const char* alias)
{
    if(obj == 0) return;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    client->setContactAlias(id, alias);
}

void dhtclient_set_contact_remark(DhtClientObj obj,  uint64_t id, const char* remark) {
    if(obj == 0) return;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    client->setContactRemark(id, remark);
}

uint64_t dhtclient_send_msg(DhtClientObj obj, uint64_t cid, const char* content)
{
    if(obj == 0) return 0;

    FX::DhtClient *client = (FX::DhtClient *)obj;
    return client->sendConversationMsg(cid, content);
}

uint64_t dhtclient_send_img_msg(DhtClientObj obj, const char* dest_hashid, const char* imgfile) {
    if(obj == 0) return 0;

    FX::DhtClient *client = (FX::DhtClient *)obj;
    return client->sendImgMsg(dest_hashid, imgfile);
}

uint64_t dhtclient_send_file(DhtClientObj obj, const char* dest_hashid, const char* filepath) {
    if(obj == 0) return 0;

    FX::DhtClient *client = (FX::DhtClient *)obj;
    return client->sendFileChunks(filepath, dest_hashid);
}

const char * dhtclient_get_msg_file_path(DhtClientObj obj, uint64_t msgid)
{
    if(obj == 0) return 0;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    return strdup(client->getMsgFilePath(msgid).c_str());
}

uint64_t dhtclient_send_audio_file(DhtClientObj obj, const char* dest_hashid, const char* filepath) {
    if(obj == 0) return 0;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    return client->sendVoiceFile(filepath, dest_hashid);
}

void dhtclient_del_msg(DhtClientObj obj, int64_t id)
{
    if(obj == 0) return;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    return client->delMsg(id);
}

int dhtclient_get_messages_unread(DhtClientObj obj, int cid)
{
    if(obj == 0) return 0;

    FX::DhtClient *client = (FX::DhtClient *)obj;
    return client->getMessagesUnread(cid);
}
void dhtclient_set_messages_read(DhtClientObj obj, int cid)
{
    if(obj == 0) return;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    client->setMessagesRead(cid);
}

void dhtclient_get_conversation_profile(DhtClientObj obj, uint64_t cid, ConversationItem* c) {
    if(obj == 0) return;
    FX::DhtClient* client = (FX::DhtClient *)obj;
    FX::ConversationEntity entify;
    client->getConversationProfile(cid, entify);
    c->id =  entify.id;

    std::strncpy(c->uuid, entify.uuid.c_str(), UUID_LEN);
    c->uuid[UUID_LEN] = '\0';

    std::strncpy(c->showName, entify.name.c_str(), NAME_MAX_LEN);
    c->showName[NAME_MAX_LEN] = '\0';

    std::strncpy(c->announcement, entify.notice.c_str(), ANNOUNCEMENT_SIZE);
    c->announcement[ANNOUNCEMENT_SIZE] = '\0';

    std::strncpy(c->faceUrl, entify.avatar.c_str(), FILE_MAX_PATH);
    c->faceUrl[FILE_MAX_PATH] = '\0';

    c->istop = entify.istop;
    c->isGroup = entify.isGroup;
    c->isPublic = entify.isPublic;
    c->isEnable = entify.isEnable;
    c->role = entify.role;
    c->unreadCount = entify.unreadCount;
    c->createTime = entify.createTime;
}

//获取聊天列表
ConversationItem* dhtclient_get_conversations(DhtClientObj obj,  int* count )
{
    if(obj == 0) return NULL;
    FX::DhtClient* client = (FX::DhtClient *)obj;
    std::map<std::string, FX::ConversationEntity> lists = client->getConversations();
    *count = lists.size();
    ConversationItem* items = new ConversationItem[lists.size()];
    std::map<std::string, FX::ConversationEntity>::iterator it = lists.begin();
    int i=0;
    for(; it != lists.end(); ++it)
    {
        items[i].id =  it->second.id;
        std::strcpy(items[i].showName, it->second.name.c_str());
        std::strcpy(items[i].faceUrl, it->second.avatar.c_str());
        items[i].istop = it->second.istop;
        items[i].isGroup = it->second.isGroup;
        items[i].isPublic = it->second.isPublic;
        items[i].isEnable = it->second.isEnable;
        items[i].unreadCount = it->second.unreadCount;
        items[i].createTime = it->second.createTime;
        //LOGE("dhtclient_get_conversations id:%ld, name:%s faceUrl:%s, createTime:%ld", items[i].id, it->second.name.c_str(), items[i].faceUrl, items[i].createTime);
        i++;
    }
    return items;
}
//用于释放 dhtclient_get_conversations 接口获取的数据内存
void  dhtclient_free_conversations(ConversationItem* list)
{
    delete[] list;
}

//获取聊天列表
ConversationItem* dhtclient_get_groups(DhtClientObj obj,  int* count )
{
    if(obj == 0) return NULL;
    FX::DhtClient* client = (FX::DhtClient *)obj;
    std::map<std::string, FX::ConversationEntity> lists = client->getGroupConversations();
    *count = lists.size();
    ConversationItem* items = new ConversationItem[lists.size()];
    std::map<std::string, FX::ConversationEntity>::iterator it = lists.begin();
    int i=0;
    for(; it != lists.end(); ++it)
    {
        items[i].id =  it->second.id;
        std::strcpy(items[i].showName, it->second.name.c_str());
        std::strcpy(items[i].faceUrl, it->second.avatar.c_str());
        items[i].istop = it->second.istop;
        items[i].isGroup = it->second.isGroup;
        items[i].isPublic = it->second.isPublic;
        items[i].isEnable = it->second.isEnable;
        items[i].unreadCount = it->second.unreadCount;
        items[i].createTime = it->second.createTime;
        LOGE("[dhtclient_get_groups] id:%ld, name:%s faceUrl:%s, createTime:%ld", items[i].id, it->second.name.c_str(), items[i].faceUrl, items[i].createTime);
        i++;
    }
    return items;
}


MessageItem* dhtclient_get_messages(DhtClientObj obj, int conversationID, int offset, int* count)
{
    if(obj == 0) return NULL;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    std::list<FX::MessageEntity> lists = client->getMessages(conversationID, offset, *count);
    *count = lists.size();
    MessageItem* items = new MessageItem[lists.size()];
    std::list<FX::MessageEntity>::iterator it = lists.begin();
    int i=0;
    for(; it != lists.end(); ++it)
    {
        items[i].msgID = it->msgID;
        items[i].randID = it->randID;
        items[i].msgType = it->msgType;
        items[i].conversationID = it->conversationID;
        std::strcpy(items[i].content, it->content.c_str());
        std::strcpy(items[i].senderID, it->senderID.c_str());
        std::strcpy(items[i].senderName, it->senderName.c_str());
        std::strcpy(items[i].senderAvatar, it->avatar.c_str());
        items[i].updateTime = it->updateTime;
        //LOGE("dhtclient_get_conversations showName:%s", it->second.showName.c_str());
        i++;
    }
    return items;
}

//用于释放 dhtclient_get_conversations 接口获取的数据内存
void  dhtclient_free_messages(MessageItem* list)
{
    delete[] list;
}

//根据会话id，获取对方hashid
const char *dhtclient_get_remote_id(DhtClientObj obj, uint64_t cid)
{
    if(obj == 0) return NULL;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    return strdup(client->getRemoteID(cid).c_str());
}

//根据对方hashid，获取会话id
uint64_t dhtclient_get_conv_id(DhtClientObj obj, const char* remoteid)
{
    if(obj == 0) return 0;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    return client->getConversationID(remoteid);
}

uint64_t dhtclient_create_conversation_c2c(DhtClientObj obj, const char* remoteid)
{
    if(obj == 0) return 0;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    uint64_t cid = 0;
    cid = client->createConversation(remoteid);
    return cid;
}
//创建群聊（公开/私有）
uint64_t dhtclient_create_conversation(DhtClientObj obj, const char* title,  const char* notice, const uint64_t* members, const uint64_t members_count, bool isPublic)
{
    if(obj == 0) return 0;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    uint64_t cid = 0;

    std::vector<uint64_t> users(members, members + members_count);
    cid = client->createConversation(title, notice, users, true);

    return cid;
}

void dhtclient_clear_conversation(DhtClientObj obj, int id)
{
    if(obj == 0) return;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    return client->clearConversation(id);
}

bool dhtclient_del_conversation(DhtClientObj obj, const char* id)
{
    if(obj == 0) return false;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    return client->delConversation(std::stoull(id));
}

bool dhtclient_pin_conversation(DhtClientObj obj, const char* id, int istop)
{
    if(obj == 0) return false;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    return client->pinToTopConversation(std::stoull(id), istop);
}
bool dhtclient_is_conversation_pintop(DhtClientObj obj, const char* id)
{
    if(obj == 0) return false;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    return client->isConversationPinToTop(std::stoull(id));
}

//设置群名
void dhtclient_set_group_name(DhtClientObj obj, uint64_t cid, const char* title)
{
    if(obj == 0) return;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    client->setGroupName(cid, title);
}

//设置群公告
void dhtclient_set_group_notice(DhtClientObj obj, uint64_t cid, const char* notice)
{
    if(obj == 0) return;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    client->setGroupNotice(cid, notice);
}

GroupUserInfo* dhtclient_get_group_members(DhtClientObj obj, uint64_t cid, int* count)
{
    if(obj == 0) return NULL;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    std::vector<FX::GroupUserInfo> members;
    client->getGroupMembers(cid, members);
    LOGE("[dhtclient_get_group_members] members size:%ld", members.size());
    *count = members.size();
    GroupUserInfo* items = new GroupUserInfo[*count];
    int i=0;
    for(const FX::GroupUserInfo& info : members) {
        items[i].userId = info.userId;
        std::strncpy(items[i].name, info.name.c_str(), NAME_MAX_LEN);
        items[i].name[NAME_MAX_LEN] = '\0';
        std::strncpy(items[i].avatar, info.avatar.c_str(), FILE_MAX_PATH);
        items[i].avatar[FILE_MAX_PATH] = '\0';
        items[i].role = info.role;
        i++;
    }
    return items;
}
void  dhtclient_free_group_members(GroupUserInfo* list)
{
    delete [] list;
}

int dhtclient_group_add_members(DhtClientObj obj, int cid, const uint64_t* users, int count)
{
    if(obj == 0) return false;
    FX::DhtClient *client = (FX::DhtClient *)obj;

    std::vector<uint64_t> ids;
    for(int i=0; i<count; i++)
    {
        ids.push_back(*(users+i));
    }
    return client->addGroupMembers(cid, ids);
}

void dhtclient_group_drop_members(DhtClientObj obj, int cid, const uint64_t* users, int count)
{
    if(obj == 0) return;
    FX::DhtClient *client = (FX::DhtClient *)obj;

    std::vector<uint64_t> ids;
    for(int i=0; i<count; i++)
    {
        ids.push_back(*(users+i));
    }
    client->dropGroupMembers(cid, ids);
}

bool dhtclient_change_nickname(DhtClientObj obj, const char* name)
{
    if(obj == 0) return false;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    client->changeNickname(name);
    return true;
}

void dhtclient_set_avatar(DhtClientObj obj, const char* avatar) {
    if(obj == 0) return;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    client->setAvatar(avatar);
}

void dhtclient_set_sex(DhtClientObj obj, int sex) {
    if(obj == 0) return;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    client->setSex(sex);
}

void dhtclient_set_slogan(DhtClientObj obj, const char* slogan)
{
    if(obj == 0) return;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    client->setSlogan(slogan);
}

void dhtclient_get_user_profile(DhtClientObj obj, const char* hashid, UserEntity* entity)
{
    if(obj == 0) return;
    FX::UserEntity user;

    FX::DhtClient *client = (FX::DhtClient *)obj;
    client->getProfile(hashid, user);

    entity->id= user.id;
    std::strcpy(entity->avatar, user.avatar.c_str());
    std::strcpy(entity->name, user.name.c_str());
    std::strcpy(entity->hashid, hashid);
    entity->sex= user.sex;
    entity->age= user.age;
    entity->addme_mode = user.addme_mode;
    std::strcpy(entity->slogan, user.slogan.c_str());

}

const char* dhtclient_get_user_path(DhtClientObj obj)
{
    if(obj == 0) return NULL;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    return strdup(client->getUserDataPath().c_str());
}

//设置加我为好友的模式
void dhtclient_set_addmemode(DhtClientObj obj, int mode)
{
    if(obj == 0) return;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    client->setAddMeMode(mode);
}
int dhtclient_get_addmemode(DhtClientObj obj)
{
    if(obj == 0) return 0;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    return client->getAddMeMode();
}

void dhtclient_sql(DhtClientObj obj, const char* sql) {
    if(obj == 0) return;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    client->exeSql(sql);
}

void dhtclient_create_p2p(DhtClientObj obj, const char* remoteid)
{
    if(obj == 0) return;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    client->createP2P(remoteid);
}

//返回std::string内容的示例，需要使用strdup，避免临时变量野指针
const char *dhtclient_get_remote_stats(DhtClientObj obj, const char* cid) {
    if(obj == 0) return NULL;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    return strdup(client->getRemoteStats(cid).c_str());
}

void dhtclient_free_string(const char* str) {
    free((void*)str);  // 释放 strdup() 返回的字符串
}

int dhtclient_write_post(DhtClientObj obj, int id, const uint8_t* data, int length)
{
    if(obj == 0) return 0;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    std::string content(reinterpret_cast<const char*>(data), length);
    client->postUpdate(id, content);

    return 0;
}

bool dhtclient_reply_post(DhtClientObj obj, uint64_t post_id, uint64_t parent_id,  const char* data)
{
    if(obj == 0) return 0;
    FX::DhtClient *client = (FX::DhtClient *)obj;

    uint64_t reply_id =  client->replyPost(post_id, parent_id, data);
    return reply_id > 0;
}

PostItem* dhtclient_get_posts(DhtClientObj obj, int postType, int userid, int offset, int* count )
{
    if(obj == 0) return NULL;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    std::vector<FX::PostEntify> posts;
    client->getPosts(postType, userid, offset, *count, posts);
    *count = posts.size();
    PostItem* items = new PostItem[*count];
    auto it = posts.begin();
    int i=0;
    for(; it != posts.end(); ++it)
    {
        items[i].id = it->id;

        std::strncpy(items[i].uuid, it->uuid.c_str(), ID_LEN);
        items[i].uuid[ID_LEN] = '\0';

        items[i].userId = it->userId;

        std::strncpy(items[i].userName, it->userName.c_str(), NAME_MAX_LEN);
        items[i].userName[NAME_MAX_LEN] = '\0';
        std::strncpy(items[i].userAvatar, it->userAvatar.c_str(), FILE_MAX_PATH);
        items[i].userAvatar[FILE_MAX_PATH] = '\0';

        std::strncpy(items[i].content, it->content.c_str(), POST_ITEM_CONTENT_BYTES);
        items[i].content[POST_ITEM_CONTENT_BYTES] = '\0';

        items[i].comments = it->comments;
        items[i].likes = it->likes;
        items[i].views = it->views;

        items[i].created_at = it->created_at;
        items[i].updated_at = it->updated_at;

        items[i].isDeleted = it->isDeleted;
        items[i].isVisible = it->isVisible;
        items[i].meVoted = it->meVoted;
        //LOGE("dhtclient_get_posts created_at:%ld", it->created_at);
        i++;
    }
    return items;
}

void  dhtclient_free_posts(PostItem* list)
{
    delete[] list;
}

void dhtclient_del_post(DhtClientObj obj, uint64_t id)
{
    if(obj == 0) return;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    client->delPost(id);
}

bool dhtclient_upvote_post(DhtClientObj obj, uint64_t id)
{
    if(obj == 0) return false;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    return client->upvotePost(id);
}

PostItem* dhtclient_get_post_replys(DhtClientObj obj, uint64_t post_id, int* count)
{
    if(obj == 0) return NULL;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    std::vector<FX::PostEntify> posts;
    client->getPostReplys(post_id, posts);
    *count= posts.size();
    PostItem* items = new PostItem[*count];
    auto it = posts.begin();
    int i=0;
    for(; it != posts.end(); ++it)
    {
        items[i].id = it->id;

        std::strncpy(items[i].uuid, it->uuid.c_str(), ID_LEN);
        items[i].uuid[ID_LEN] = '\0';

        items[i].userId = it->userId;

        std::strncpy(items[i].userName, it->userName.c_str(), NAME_MAX_LEN);
        items[i].userName[NAME_MAX_LEN] = '\0';
        std::strncpy(items[i].userAvatar, it->userAvatar.c_str(), FILE_MAX_PATH);
        items[i].userAvatar[FILE_MAX_PATH] = '\0';

        std::strncpy(items[i].content, it->content.c_str(), POST_ITEM_CONTENT_BYTES);
        items[i].content[POST_ITEM_CONTENT_BYTES] = '\0';

        items[i].comments = it->comments;
        items[i].likes = it->likes;
        items[i].views = it->views;
        items[i].created_at = it->created_at;
        items[i].updated_at = it->updated_at;

        items[i].isDeleted = it->isDeleted;
        items[i].isVisible = it->isVisible;
        items[i].meVoted = it->meVoted;

        items[i].parentId = it->parentId;
        LOGE("[dhtclient_get_post_replys] created_at:%ld, meVoted:%d", it->created_at, it->meVoted);
        i++;
    }
    return items;
}

void dhtclient_del_reply(DhtClientObj obj, uint64_t id)
{
    if(obj == 0) return;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    client->delReply(id);
}

bool dhtclient_upvote_reply(DhtClientObj obj, uint64_t id)
{
    if(obj == 0) return false;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    return client->upvoteReply(id);
}

//设置帐号关联参数
void dhtclient_set_cfg(DhtClientObj obj, const char* key, const char* value)
{
    if(obj == 0) return;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    client->setCfgValue(key, value);
}
//获取帐号关联参数
const char * dhtclient_get_cfg(DhtClientObj obj, const char* key)
{
    if(obj == 0) return NULL;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    return strdup(client->getCfgValue(key).c_str());
}

uint64_t dhtclient_get_userid(DhtClientObj obj)
{
    if(obj == 0) return 0;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    return client->getMyUserId();
}

bool dhtclient_is_contact_p2p(DhtClientObj obj, const char* contact_hashid)
{
    if(obj == 0) return false;
    FX::DhtClient *client = (FX::DhtClient *)obj;
    return client->isP2pConnected(contact_hashid);
}