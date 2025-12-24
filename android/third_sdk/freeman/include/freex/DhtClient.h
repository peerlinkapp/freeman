#pragma once
#include <string>
#include <opendht.h>
#include <opendht/dht.h>
#include <functional>
#include <list>
#include <map>
#include <stdint.h>
#include <openssl/md5.h>
#include <msgpack.hpp>
#include "AppConfig.h"
#include "PacketStats.h"


namespace FX
{
	using namespace std;
	using namespace dht;
	
	class P2PClient;
	class DataBufferManager;
	class DhtClient;
	

	enum ClientMessageAction{
		ACTION_NONE,
		ACTION_ACK, //收到消息的回馈
		ACTION_ONLINE,
		ACTION_FIND_USER ,		//查找用户
	    ACTION_FIND_USER_REPLY, //查找用户回复
		ACTION_ADD_USER,
	    ACTION_ADD_USER_REPLY,
		ACTION_PROFILE_UPDATE, //资料更新		
		ACTION_SYNC_ADDRBOOK, //通讯录发给远端（收到后需执行ACTION_SYNC_ADDRBOOK2)
		ACTION_SYNC_ADDRBOOK2, //通讯录发给远端
		ACTION_CHAT_MSG,
		ACTION_FIX_LOST,
		ACTION_P2P_SDP,
		ACTION_P2P_REPLY_SDP,
		ACTION_POST_UPDATE, //up主有新帖通知
		ACTION_POST_DATA, //帖子数据通知
		ACTION_FILE_CHUNK, //文件分块
		ACTION_FILE_CHUNK_IDX, //已接收文件块索引号（用于滑动窗口控制）
		ACTION_GET_USER_POSTLIST, //查询某用户的动态id列表
		ACTION_GET_USER_POSTLIST_RESULT, //某用户的动态id列表结果
		ACTION_GIVE_ME_POST, //请给我post_uuid的帖子
		ACTION_GIVE_ME_POST_ATTACH, //给我某个帖子的附件
		ACTION_POST_UPVOTE, //点赞帖子给up主
		ACTION_POST_REPLY, //回复帖子给up主
		ACTION_REPLY_UPVOTE, //点赞回复给up主
		ACTION_POST_REPLY_UPDATE, //up主发送回复更新通知
		ACTION_POST_REPLY_GET_UPDATE, //收到REPLY_UPDATE更新后，根据本地回复版本发送给服务端的带本地版本的获取更新请求
		ACTION_POST_REPLY_DATA, //帖子回复数据通知（增量更新）
		ACTION_PING, 	      //尝试dht ping
		ACTION_PONG,
		ACTION_INVITE_JOINGROUP, //加群邀请
		ACTION_GROUP_QUIT, //退群指令
		ACTION_FIND_GROUP, //发现群
		ACTION_FIND_GROUP_REPLY,  //群信息
		ACTION_GROUP_BOOK, //群成员列表
	};
	
	enum DhtMessageType{
		DHT_MSG_NONE = 0,
	    DHT_MSG_TXT = 1,
		DHT_MSG_CUSTOM = 2,
	    DHT_MSG_IMAGE = 3,
		DHT_MSG_VOICE = 4,
		DHT_MSG_VIDEO = 5,
	    DHT_MSG_FILE = 6,
		DHT_MSG_LOCATION = 7,
		DHT_MSG_FACE = 8,
		DHT_MSG_GROUP_TIPS = 9,
		DHT_MSG_GROUP_MERGER = 10,
		DHT_MSG_P2P = 11,
		DHT_MSG_GROUP_INVITE = 12,
	};
	
	enum FileMessageType{
		FILE_MSG_NONE = 0,
	    FILE_MSG_POST_ATTACH = 1,
		FILE_MSG_VOICE = 2
	};
	
	enum ApplyFriendMode{
		NEED_MY_CHECK = 0, //需要审核
	    AUTO_ALLOW = 1, //自动通过, 并加对方进通讯录
		AUTO_ALLOW_NOT_IN_CONTACTS = 2, //自动通过, 但不加对方进通讯录，（对方发消息后可显示在消息列表中）
		DENY_ALL = 3, //拒绝一切加好友请求
		ALLOW_BY_ANSWER = 4 //通过问答加好友
	};
	
	enum class AddFriendProgress{
		NONE = 0,
		FIND_TMP_SAVE, //查找用户的结果，临时存储
	    WAIT_ME_REVIEW, //等待我审批的对端
		REMOTE_NOT_ALLOW, //对方已拒绝		
		FANS, //对方加我，我未加对方(粉丝)
		ONLY_ME, //我加对方好友，对方未加我
		BOTH  //双方
	};
	
	enum ChatUserRole{
		CHAT_ROLE_USER = 0, //普通
		CHAT_ROLE_OWNER = 1, //会话属主（在会话中可能是普通用户，如群聊参与者）
	    CHAT_ROLE_ADMIN = 2, //管理员
		CHAT_ROLE_CREATOR = 3, //创建者
	};
	
	struct DhtMessagePacket{
	    int         version; //版本号
	    DhtMessageType typeId;
		uint8_t md5sum[MD5_DIGEST_LENGTH]; //md5sum结果
	    int            idx; //当前序号值
	};
	
	struct DhtMessageFirstPacket{
	    DhtMessagePacket header;
	    int totalItems; //总条数, 当header.idx==0时
	    int totalBytes; //总字节数
	    char* name; //文件名
	};
		
	//单条话题统计
	struct TopicMeta{
		dht::InfoHash id;
		std::string title;
		time_t updateTime;
		size_t count;
		size_t hot;
		
		static bool sortbyint_desc(const pair<string, int> &f1, const pair<string, int> &f2)
		{
			if(f1.second > f2.second) return true;
			else if(f1.second == f2.second) return f1.first < f2.first;
			else return false;
		}
		
	};
	
	
    // 用户实体
	struct UserEntity{
      int id;
	  string hashid;
	  string inviteCode; //邀请码
	  string avatar; //头像
	  string name; //昵称 （自起）
	  string slogan; //签名
	  string addme_q; //
	  string addme_a;
	  int sex;
	  int age;
	  int addme_mode;
	  UserEntity()
	  {
		  id = 0;
		  sex = 0;
		  age = 0;
		  addme_mode = 0;
	  }
	};
    
	//好友节点
	struct FriendEntity{
      uint64_t id; //
	  string hashid; //hashid
	  string avatar; //头像
	  string name; //昵称 （自起）
	  string alias; //别名 （备注名）
	  string remark; //备注 （备注信息）
	  string inviteCode; //邀请码
	  uint8_t sex; //性别
      time_t updateTime; //最近在线的时间
      size_t countArticles; //发布的文章的数量
      size_t hot; //亲密度分值
	  AddFriendProgress	ftype; //好友进度类型
	  bool online; //是否在线
	  bool isDel; //关系是否已删除

      FriendEntity()
      {
		id = 0;
		sex = 0;
        updateTime = 0;
        countArticles = 0;
        hot = 0;
		online = false;
      }      
	};
	
	//群成员用户信息
	struct GroupUserInfo{
		uint64_t userId; //用户id
		string hashid; //
		string name; //在群中的名字
		string avatar; //头像 
		ChatUserRole role; //在群中的角色
	};

	//会话实体
	struct ConversationEntity {
		uint64_t id; //会话id
		string uuid;
		string hashid; 
		string name; //	
		string notice; //公告
		string avatar; //	
		string lastMessage; //	
		int istop; //是否置顶
		int isGroup; //是否群聊
		int isPublic; //是否公开
		int isEnable; //是否有效
		int role; //当前用户在群中的角色
		int unreadCount; //未读消息条数
		time_t updateTime; //最后更新时间
		time_t createTime; //创建时间
	};

	//消息实体
	struct MessageEntity {
		int64_t msgID; //INT PRIVMARY KEY
		int64_t randID; //随机ID
		uint64_t conversationID;
		int msgType;
		int msgCode;// 状态码		
		string content;		
		string senderID; //发送者ID
		string senderName; //发送者名
		string avatar; //头像
		time_t updateTime; //
		string ext; //扩展：图片型消息存储扩展名
		MessageEntity()
		{
			msgID = 0;
			conversationID = 0;
			msgType = 0;
			msgCode = 0;
			updateTime = 0;			
		}
	};
	
	//动态
	struct PostEntify{
		uint64_t id;
		string uuid;
		uint64_t parentId; //父id(用于表示回复树）
		uint32_t version; //版本号
		uint64_t userId;
		string userName;
		string userAvatar;
		string content;
		uint32_t comments;
		uint32_t likes;
		uint32_t views;
		bool meVoted; //当前用户是否点赞
		bool isVisible;
		bool isDeleted;
		time_t created_at;
		time_t updated_at;
		uint32_t ttl;//分发ttl
		PostEntify()
		{
			id = 0;
			version = 0;
			comments = 0;
			likes = 0;
			views = 0;
			created_at = 0;
			updated_at = 0;	
			isVisible = true;
			isDeleted = false;
			meVoted = false;
			ttl = 0;
		}
	};
	
	
	enum PostType{
		POST_USER, //某用户的帖子
		POST_FOLLOWING = 1, //关注的帖子
	    POST_HOT = 2		//热门的帖子
	};
	
	struct FileTransStats{
		uint64_t fileid;
		double progress;
	};
	
	struct DhtClientCallBackFunc{
		std::function<void(UserEntity&)> onFindFriend;
		std::function<void(FriendEntity&, int mode, DhtClient* dht)> onAddMeRequest;
		std::function<void(const std::string& sender, int result)> onAddRemoteReply; //收到加好友申请的回复
		std::function<void(MessageEntity&)> onRecvMsg;			
		std::function<void(bool&)> onNetStatusCbk; //网络状态变化回调
		std::function<void(PostEntify& post)> onNewPost; //收到新的动态
		std::function<void(MsgSendStats& stats)> onMessageSentResult; //消息发送结果回馈
		std::function<void(FileTransStats& stats)> onFileSentResult; //文件发送进度
	};
	
	//话题列表
	typedef map<dht::InfoHash, TopicMeta> TopicList;
	typedef vector<pair<string, int>> SortedTopic;
	
    //好友节点列表
	typedef map<string, FriendEntity> FriendList;
	//会话列表
	typedef map<string, ConversationEntity> ConversationList;
	//消息列表
	typedef list<MessageEntity> MessageList;
	
	
	struct P2pHolder{
		std::shared_ptr<P2PClient> p2p;
		int p2p_error_count; //p2p失败次数
		
		P2pHolder()
		{
			p2p.reset();
			p2p_error_count = 0;
		}
	};
	
	//p2p连接列表，key为用户的hashid
	typedef map<string, P2pHolder> PeersList;

	
	//回调函数，被请求加好友
	//typedef void (*OnApplyAddFriend)(std::string from_hash_id, std::string from_nick_name);


	class DhtClient{
		friend class P2PClient;
		friend class DataBuffer;
		
		public:

            DhtClient(const string& dataPath);
			
			//本应用的数据目录
			const string getDataPath() const{return _dataPath;}
			
			//用户数据存储目录（每个用户的数据单独组织一个目录）
			inline std::string getUserDataPath()
			{
				return getDataPath() + "users/" + _id + "/";
			}
			
			//临时数据目录，此目录下的文件会在程序启动时清空
			inline std::string getTmpDataPath()
			{
				return getDataPath() + "tmp/";
			}
			//头像目录
			inline  std::string getUserAvatarPath()
			{
				return getDataPath() + "avatar/";
			}
			
			//获取接收文件的目录（根据时间、扩展名确定）
			std::string getRecvFilePath();
			
			//获取该帐号的配置参数的值
			std::string getCfgValue(const string& key);
			void setCfgValue(const string& key, const string& value);
			
            
            //使用给定id登入dhtclient
            bool login(const string& clientid, const string& pwd);
			
			//设置头像
			void setAvatar(const string& avatar_file_path);
			//获取个人资料
			static void getProfile(const string& hashid, UserEntity& user);
			//设置性别
			void setSex(int val);
			//设置签名
			void setSlogan(const string& txt);
			

			//判断用户是否存在
			bool isExistUser(const string& clientid);

			//注册
			bool regist(const string& username, const string& pwd);
			
			//退出
			void exit(){ _exit = true;}
			
			~DhtClient();
			
            
            //是否已连入DHT网络
            bool isConnected();
			
			bool isConnectedP2P(const string& remoteId);
			
			//网络状态回调
			void setNetStatusCbk(std::function<void(bool&)> cbk)
			{
				_cbk.onNetStatusCbk = cbk;
			}
			
			//订阅
			void subscribe(const string& topic);
			
			//主题方式（非端对端）
			//发送无大小限制的，含"丢包重传"的数据包
			uint64_t pushSendData(const string& to, const string& topic, std::map<std::string, msgpack::object>& data, bool enc = false);
			
			//
			uint64_t sendMap(const string& to, const string& topic, std::map<std::string, msgpack::object>& data);
			uint64_t sendMapToUser(uint64_t user_id,   std::map<std::string, msgpack::object>& data);
			
			//发送map数据，返回相应的消息randID, 在发送成功或失败后，_msgSendStats 中可查到执行结果
			uint64_t sendMsg(const string& to, std::map<std::string, msgpack::object>& data); //发送map
			uint64_t sendMsg(const string& to, const string& body); //发送文本内容
			uint64_t sendImgMsg(const string& to, const string& img_file); //发送图片
			void setMsgSentResultCbk(std::function<void(MsgSendStats& stats)> cbk)
			{
				_cbk.onMessageSentResult = cbk;
			}
			void onReceiveMsg_chat(const string& sender, std::map<std::string, msgpack::object> &map, const std::time_t& recv_time, std::uint64_t msgId);
			
			//删除消息
			
			
			//发送消息回馈
			void sendRecvMsg_ACK(string remoteid, uint64_t msgid);
			//通用的收到消息回馈
			void onReceiveMsg_ACK(const string& sender, std::map<std::string, msgpack::object> &map);
			
			
			//设置收到消息回调
			void setRecvMsgCbk(std::function<void(const MessageEntity& msg )> cbk);
			
			void sendBytes(uint64_t msgid, const string& to, const string& topic_src, const string& body);
			 
			void dumpTopicStats();
			
			//hashid
			string id() const;
			
			
			//获取users表中代表“我”的INT主键
			uint64_t getMyUserId();
			
			//获取account表中的帐号id
			uint64_t getAccountId();
			
			
			//删除某好友的所有对话
			bool cleanFriendMessages(string idstr);
						
			
			//更新热门话题榜
			void updateHotTopics();
            
            //打印exportNodes            
            void dumpExportNodes();
            
            void dumpStatus() const;
            
            void printBasicInfoAndStats();
			
			void printRoutingTable();
			

			/************************* 消息 ***********************************/
			//获取消息列表
			MessageList getMessages(int conversationID, int offset, int count, int* unReadedCount = nullptr);
			
			//设置会话消息已读
			void setMessagesRead(int conversationID);
			//获取未读消息条数
			int getMessagesUnread(int conversationID);
			
			//删除消息
			void delMsg(int64_t msgid);
		private:
			//将消息保存进数据表，返回消息的key INT
			int64_t saveMsg(const MessageEntity& msg);
			
		public:
			/************************* 会话 ***********************************/
			//获取会话列表
			ConversationList getConversations();
			//获取群聊
			ConversationList getGroupConversations();
			
			//根据对方hashid，获取会话id
			uint64_t getConversationID(const string& remoteid);
			//根据群的hashid，获取群id
			uint64_t getConversation(const string& hashid);
			//根据会话id，获取对方hashid(群聊返回组的hashid)
			string getRemoteID(const uint64_t conversationID);
			
			//创建单聊
			uint64_t createConversation(const string& remoteid);
			//创建话题
			uint64_t createConversation(const string& name, const string& notice, vector<uint64_t> &members, bool visiblePublic = false, bool isGroup = true); 
			
			
			//设置会话群聊名称
			void setGroupName(uint64_t id, const string& name);
			//设置群聊公告
			void setGroupNotice(uint64_t id, const string& notice);
			
			
			//在会话中发送一条文本消息
			uint64_t sendConversationMsg(uint64_t cid, const string& body);
			
			//发送群消息
			uint64_t sendGroupMsg(uint64_t cid, const MessageEntity& msg);
			
			//删除会话
			bool delConversation(uint64_t id);
			
			//清除会话聊天记录
			void clearConversation(uint64_t id);
			
			//置顶会话
			bool pinToTopConversation(uint64_t id, int istop);
			//获取会话是否置顶
			bool isConversationPinToTop(uint64_t id);
			
			//获取会话资料
			void getConversationProfile(uint64_t cid, ConversationEntity& c);
			
			/************************* 会话群 ***********************************/
			
			//获取群成员
			void getGroupMembers(const uint64_t cid, vector<GroupUserInfo>& members);
			//拉用户入群
			int addGroupMembers(const uint64_t cid, const vector<uint64_t>& ids, int role = ChatUserRole::CHAT_ROLE_USER);
			void addGroupMembers_Invite(const uint64_t cid, const vector<uint64_t>& ids, int role = ChatUserRole::CHAT_ROLE_USER);
			
			void onReceiveMsg_GroupBook(const string& sender, std::map<std::string, msgpack::object> &data);
			
			//删除群中用户
			void dropGroupMembers(const uint64_t cid, const vector<uint64_t>& ids);
			
			//搜索群
			void sendFindGroupByTitle(const string& title);
			
			//
			void getGroupActiveMembers(const uint64_t cid, vector<GroupUserInfo>& members);
			
		private:
		
			//给某用户发送加群邀请
			void sendJoinGroupInvite( const uint64_t cid, const uint64_t uid);
			//退群指令
			void sendGroupQuit( const uint64_t cid, const uint64_t uid);
			
			//发送群成员列表数据
			void sendGroupMemberBook( const uint64_t cid, const uint64_t uid);
			
			void onReceiveMsg_JoinGroupInvite(const string& sender, std::map<std::string, msgpack::object> &data);
			
			void onReceiveMsg_GroupQuit(const string& sender, std::map<std::string, msgpack::object> &data);
			
			void onReceiveMsg_FindGroupByTitle(const string& sender, std::map<std::string, msgpack::object> &data);
			
			void onReceiveMsg_FindGroupReply(const string& sender, std::map<std::string, msgpack::object> &data);
			
			void onMessageSent(uint64_t msgid, bool ok,  uint32_t bytes);
			
		public:	
			/************************* 通讯录相关 ***********************************/
			
			//idstr可为一个有意义的英语单词，也可为一个40字节长的InfoHash字符串
			bool addFriend(string idstr, string name = "", string icon_path = "");
			bool addFriend(const FriendEntity& f);
			
			bool delFriend(string idstr);
			
			//设置加我好友审核模式
			void setAddMeMode(int val);
			//获取加我好友审核模式
			int getAddMeMode();

			//通过“添加好友magic”发送查好友hashid请求, num_from_hash为目标用户public hashid的前6位字符。
			void send_FindFriend(string key);
			void setFindFriendResultCbk(std::function<void(UserEntity&)> cbk);
			
			void onReceiveMsg_find_user(const string& sender, std::map<std::string, msgpack::object> &map);
			
			//通过网络申请（需审核）或告知添加好方好友（不需审核）
			void send_AddFriend(string remoteid);
			//收到对端添加好友请求
			void onReceiveMsg_AddFriend(const string& sender, std::map<std::string, msgpack::object> &map);
			
			//
			
			//FriendEntity对方信息，mode:我的加好友审核模式
			void setAddMeNotifyCbk(std::function<void(FriendEntity&, int mode, DhtClient* dht)> cbk)
			{
				_cbk.onAddMeRequest = cbk;
			}
			
			void onReceiveMsg_add_friend_reply(const string& sender, std::map<std::string, msgpack::object> &map);
			
			
			//发送允许或拒绝 添加好友请求
			void send_AddFriendReply(const string& sender, bool allow);
			
			//收到对方允许拒绝加好友答复
			void setAddFriendReplyNotifyCbk(std::function<void(const string& remoteid, int result)> cbk){
				_cbk.onAddRemoteReply = cbk;
			}
			
			//根据hashid，获取好友信息
			void getFriendProfile(const string& hashid, FriendEntity& f);
			
			//根据用户id，获取用户hashid
			string getContactHashId(uint64_t id);
			//根据hashid, 获取users.id
			uint64_t getUserId(const string& hashid);
			
			
			//更改联系人信息
			void changeContactProfile(string id, string name, string icon_path);
			void changeContactProfile(dht::InfoHash id, string name, string icon_path);
			
			//设置联系人别名
			void setContactAlias(uint64_t id, string alias);
			//设置联系人备注
			void setContactRemark(uint64_t id, string remark);

			//获取联系人列表
			FriendList getContacts(AddFriendProgress ftype = AddFriendProgress::NONE, time_t sync_time = 0);
			
			//获取共同联系人列表
			void getMutualContacts(uint64_t user_id, vector<uint64_t>& ids);
			
			//获取n个最活跃联系人列表
			FriendList getActiveContacts(int n);
			
			//设置好友类型
			void setFriendType(const string& friend_hashid,  AddFriendProgress ftype);
			
			//发送通讯录给对端
			void sendContactsToRemote(const string& hashid, bool needSendToo = false);	
			//收到up主的通讯录，追加进本地数据表中，并判断是否需要发自己的通讯录给对端（needSendToo）
			void onReceiveMsg_Conntacts(const string& sender, std::map<std::string, msgpack::object> &data, bool needSendToo);
			
			//获取某用户的n个粉丝
			void getRandFollowedPartList(uint64_t user_id, int n, std::set<dht::InfoHash> &followed, bool online = true);			
			
			//保存up主和粉丝记录
			void saveOwnerFans(const string& owner_id, const string& fans_id, bool isDel = false);
		
			
			/************************* 我的 ***********************************/
			void changeNickname(const string& name);
			
			
			
			//生成新的邀请码
			string genInviteCode();
			//获取邀请码
			string getInviteCode();
			
			
			//转换
			static dht::InfoHash getHashid(string idstr);
			
			//打印数据发送接收缓冲区信息
			void printBufferInfo();
			
			//
			int exeSql(const string& sql);
			
			/************************* 主题相关 ***********************************/
			//主题转换算法（将接近明文的topic经加密扰乱后Hash，以避免了解到主题算法后，截取数据包）
			static InfoHash getTopicHash(const string topic);
			
			//创建P2P通道（调用者作为PJ_ICE_SESS_ROLE_CONTROLLED)
			void createP2P(string remoteid);
			
			/************************* P2P ICE相关 ***********************************/
			//打印p2p连接列表（含遍历p2p示例）
			void printPeers();
			
			//通过P2p发送数据
			void p2pSend(const string& remoteid, int compId, const string& content);
			
			void onIceComplete( const string& remoteid, int op, bool success, const string& reason);
			
			//返回remoteid相关的信息，如p2p连接状态等
			std::string getRemoteStats(const string& remoteid);
			
			//判断与某联系人p2p连接是否已连通
			bool isP2pConnected(const string& remoteid);
		private:
			//更新资料后发送最新的个人资料信息给对方
			void sendUpdatedProfile();
			void sendUpdatedProfile(const string& remote_id);
			void onReceiveMsg_UpdatedProfile(const string& sender, std::map<std::string, msgpack::object> &map);
			
			/************************* Post 动态相关 ***********************************/
		public:
			//发布或修改动态，id=0，发布新动态，非0，则为修改相应动态的内容
			void postUpdate(uint64_t id, const string& content);
			
			//
			void setAddPostNotifyCbk(std::function<void(PostEntify& post)> cbk)
			{
				_cbk.onNewPost = cbk;
			}
			
			//删除动态
			void delPost(uint64_t id);
			
			//彻底删除动态
			void clearPost(uint64_t id);
			
			//获取动态内容
			void getPostContent(uint64_t id, string& content);
			//获取动态列表
			void getPosts(int postType, uint64_t userid, int offset, int count, vector<PostEntify>& posts);
			
			//获取帖子的回复列表
			void getPostReplys(uint64_t post_id, vector<PostEntify>& posts);
			
			//获取动态对象
			void getPost(const string& post_uuid, PostEntify& post);
			void getPost(uint64_t id, PostEntify& post);
			
			//给某帖点赞/取消点赞
			bool upvotePost(uint64_t id);
			
			//回复帖子
			uint64_t replyPost(uint64_t post_id, uint64_t parent_id, const string& content);
			
			//删除回复
			bool delReply(uint64_t reply_id);
			
			//给回复点赞/取消点赞
			bool upvoteReply(uint64_t reply_id);
			
		private:
			void getPostMedias(const string& content, vector<string>& medias);
			
			
			//发布新帖后通过此方法，通知好友节点有更新
			void postUpdateNotify(uint64_t post_id);			
			//收到up主的post更新通知
			void onReceivePostUpdated(const string& owner_id, std::map<std::string, msgpack::object> &data);
			
			//推送Post数据, userHashId为目标用户的hashid，为空则以“广播主题”方式推
			void sendPostPushData(uint64_t post_id, const string& userHashId);
			//发送帖子附件文件
			void sendPostAttachs(uint64_t post_id, const string& userHashId);
			//
			void onReceivePostData(const string& owner_id, std::map<std::string, msgpack::object> &data);
			void parsePostMedias(string& medias, vector<string> &files);		
			
			//帖子正文修改（如附件路径改为相对路径，等等）
			void postContentFix(string& content, const string& remote_path);
			
			//设置帖子是否可见（当接收到新帖文本正文时创建新帖时不可见，当接收完所有附件数据后，才设为可见）
			void setPostVisibility(const string& post_uuid, bool visible);
			void setPostDeleted(const string& post_uuid, bool deleted);
			
			//判断帖子是否已存在，version为0或空，则不限版本
			bool isPostExist(const string& post_uuid, uint32_t version = 0);
			
			//查询某粉丝上up主的帖子列表
			void sendGetUserPostList(const string& fanHashId, const string& posterHashId);
			void onReceiveMsg_getUserPostList(const string& sender, std::map<std::string, msgpack::object> &map);
			//
			void onReceiveMsg_getUserPostListResult(const string& sender, std::map<std::string, msgpack::object> &map);
			
			//获取保存在本地的用户动态的最新版本，无则返回0
			int getUserPostVersion(uint64_t userid);
			
			//向srvUserId用户请求post_uuid的帖子
			void sendGetPostRequest(const string& srvUserId, const string& post_uuid);
			
			//收到获取用户动态请求
			void onReceiveMsg_getUserPost(const string& sender, std::map<std::string, msgpack::object> &map);
			
			//起线程，获取某好友的动态, hashid:对方的hashid
			void getFriendPostThread(const string& hashid);
			
			//根据帖子的uuid返回帖子的id
			uint64_t getPostIdByUuid(const string& post_uuid);
			
			//根据帖子的id返回帖子的uuid
			string getPostUuid(uint64_t post_id);
			
			
			//查询当前用户是否已对某回复点赞
			bool isReplyMeVoted(uint64_t reply_id);
			
			//收到点赞处理
			void onReceiveMsg_upvotePost(const string& sender, std::map<std::string, msgpack::object> &data);
			//收到回复
			void onReceiveMsg_replyPost(const string& sender, std::map<std::string, msgpack::object> &map);
			//收到对评论的点赞 
			void onReceiveMsg_upvoteReply(const string& sender, std::map<std::string, msgpack::object> &map);
			
			//获取回复的子回复
			void getReplySub(uint64_t reply_id, vector<uint64_t>& subs);
			//获取回复的uuid
			string getReplyUuid(uint64_t reply_id);
			//
			uint64_t getReplyId(const string& reply_uuid);
			
			//当帖子回复被更新时需调用此方法
			void postReplyUpdateNotify(uint64_t post_id);
			void onReceiveMsg_replyUpdate(const string& sender, std::map<std::string, msgpack::object> &map);
			void onReceiveMsg_replyGetUpdate(const string& sender, std::map<std::string, msgpack::object> &map);
			void onReceiveMsg_replyData(const string& sender, std::map<std::string, msgpack::object> &data);
		/************************* 文件收发 ***********************************/
		public:
			/*
			topic: 发送的主题，默认为空，即to+TOPIC_MSG
			*/
			uint64_t sendFileChunks(const string& filepath, const string& to, const std::string& meta="");
			
			//获取某msgid/fileid对应的接收文件后保存的路径
			std::string getMsgFilePath(uint64_t msgid);
			
			void setFileSentResultCbk(std::function<void(FileTransStats& stats)> cbk)
			{
				_cbk.onFileSentResult = cbk;
			}
			
			//发送语音
			uint64_t sendVoiceFile(const string& filepath, const string& to);
			
		private:
			void sendFileChunksProcess(const std::string& filepath, const std::string& to, uint64_t file_msgid, const std::string& post_uuid);
			
			//发送端
			struct SendingFileMeta{
				std::mutex mutex; //因为会在发送线程和收包线程中同时访问
				int chunk_idx; //接收到的对端已确认收到的连续块的最大块号
				int total_chunks; // 总块数，用于计算发送百分比
				std::set<int> miss;//
				bool cancel; //是否放弃（因错误等原因）
			};
			std::map<uint64_t, SendingFileMeta> _sendingFile; //key为"文件消息id" 
			
			//文件发送端收到接收端发来的已收到的最大连续块索引号
			void onReceiveFileChunkIdx(const string& sender, std::map<std::string, msgpack::object> &data );
			
			//接收端收到文件块数据
			void onReceiveFileChunk(const string& sender, std::map<std::string, msgpack::object> &map );
			
			struct ReceivingFile {
				std::string filename;        // 临时文件路径
				std::string meta;       //该文件相关的辅助信息
				std::string md5; 		//md5 sum
				int64_t fileLength;			// 总字节数
				int chunk_size;				//
				int total_chunks;         //总块数
				int confirm_chunk_idx;    //收到的连续的已确认的最大块索引号				
				std::set<int> received_chunks;    // 已收到块索引(非全集，而是已接收到的索引集合-confirm_chunk_idx之前的）
				std::set<string> senders; //持有文件的节点
				std::ofstream file_stream;        // 打开的文件流
				time_t recv_time; //接收到0块的时间
				time_t last_check_miss; //最近一次检查缺块索引号的时间
			};

			std::map<uint64_t, std::map<int, std::vector<uint8_t>>> _fileChunksMem; //暂存进内存的文件块，key为fileid
			std::map<uint64_t, ReceivingFile> _filesRecving;	 //正在接收的文件列表，key为fileid
			std::mutex _filesRecvingMutex; // 
			
			std::map<uint64_t, time_t> _filesRecvingFin;      //已接收完毕的文件列表（用于丢弃接收完毕后仍收到的残余包）
			void onGetFileChunk(int chunk_idx, std::vector<uint8_t> &binaryData, uint64_t fileid, const string& sender);
			void dumpMemoryChunk(uint64_t fileid, const string& sender);
			void genFileMsg(MessageEntity& msg, const string& sender, const string& filename, size_t filebytes, const string& saved_path);
			//当收到帖子的某个文件（图片，视频……）
			void onReceivePostMedia(const string& post_uuid, const string& media);
			void parseMedias(const string& content, std::set<std::string>& medias);

		/*************************   ***********************************/
		public:	
			static constexpr const char* TOPIC_MSG = "_msg";
		private:			
			//static constexpr const char* TOPIC_STATUS = "_status";
			
			DhtClientCallBackFunc _cbk;
	
		    //用户名称，代号
		    std::string _username;
		    //密码
		    std::string _pwd; 
		    //数据文件所在路径
		    string _dataPath;
		    
            //public key id
            std::string _id;
			
			uint64_t _userId;
			            
            bool _connectedDHT; //是否连接DHT网络
			time_t _netStatusUpdateTime; //_connectedDHT的更新时间
			
            //初始化相关动作
            void init();
			
			
            
            void OnNetStatusChanged(dht::NodeStatus s, dht::NodeStatus t);
            
            //保存已知节点，用于下次互联
            void saveNodes() const;
            
            //从本地加载节点
            std::vector<dht::NodeExport> importNodes();
			
			
			std::unordered_map<std::string, std::shared_future<size_t>>  _topicTokens;
            
            //测试是否已连入DHT
            void pingPong();
            
            //启动后自动订阅的话题
            void initJoinTopics();
            
			
			void joinTopic(const string& topic);
			
			//退订主题
			void cancelJoinTopic(const string& topic);
			
			//请求
			void requestHotTopic(const dht::InfoHash& remote);
			
			//dht节点
			dht::DhtRunner mDht;
			
			//系统话题排行榜
			static const string SYS_TOP_TOPIC;
			//用于群聊标题检索
			static const string TOPIC_GROUP_CHAT;
			//用于topic的防猜字符串后缀
			static const string TOPIC_POSTFIX;
			
			//话题热度值+1
			void addTopicHotScore(const string& topic);
			
			
			//话题列表
			TopicList _topics;
			
			//好友列表
			FriendList _friends;

			//会话列表
			ConversationList _conversations;
			
			//话题排序算法（热度倒序）
			static void sortTopicByHotDesc(TopicList &src, SortedTopic &result);
            
            //本地侦听端口
			int _port;
            //从本地已知节点列表中启动
            bool _bootFromLocal;
            static AppConfig *_cfg;
			static sqlite3* _db;
            

			//文件检查任务是否在执行
			bool _fileCheckTaskLaunched;
			
			

       private:
			 
			bool _onReceive(const string topic, dht::ImMessage& msg);
	   
            //用于异步检查文件接收情况
            void fileRecvThreadsCheck();

			void checkFileTask();

			void checkFileIntegrity(const string& filesum, int slices_count);

			void onUpdateFriendList();
			
			void afterLogin();
			
			void onConnected();
			
			//更新用户表中用户在线状态
			void setUserOnline(const string& hashid, bool online);
			//用户是否在线
			bool isUserOnline(const string& hashid);
			
			time_t GetLastActiveTime(const string& hashid);
			
			//根据最后活跃时间倒序获取某用户的活跃粉丝
			void getUserActiveFans(uint64_t userid, set<string>& fans, int count = 10);
			
			volatile bool _exit;

			//添加好友magic数字+特定防冲突字符串
			string getAddFriendMagic(std::string inviteCode = "");
			void send_FindUserReply(const dht::InfoHash& requester);
			
			
			//保存好友关系
			void saveRelations(uint64_t ownerid, uint64_t userid, AddFriendProgress ftype, bool isDel = false);
			

			//查询该好友是否已在列表中
			bool isExistFriend(std::string friend_hashid, std::string owner_hashid, AddFriendProgress ftype = AddFriendProgress::NONE);
			
			std::vector<dht::NodeExport> importNodesFromLocalFileExample();
			 
			 
			/*************************      发送消息处理             ***********************/			 
			DataBufferManager* _sendDataBufferManager;
			std::thread _sendWorkerThread;
			void sendDataPoolProcess();
			std::mutex _mtxSendDataPool; 
			std::condition_variable _cvSendDataPool;      // 条件变量	
			void resend(); //发送packets表中需要确认，仍未确认的包
			
			
			/*************************      接收消息处理             ***********************/
			void onReceiveMsg(const string& topic, dht::ImMessage& msg);
			void onReceiveMsg2(const string& topic, const string& body, const string& sender, const std::time_t& now, std::uint64_t msgId);
			
			DataBufferManager* _recvDataBufferManager;
			std::thread _recvWorkerThread;
			void recvDataPoolProcess();
			std::mutex _mtxRecvDataPool; 
			std::condition_variable _cvRecvDataPool;      // 条件变量
			
			/*************************      接收到消息的处理函数             ***********************/
			void onReceiveMsg_find_user_reply(std::map<std::string, msgpack::object> &map);
			void _processFriendEntity(std::map<std::string, msgpack::object> &map, AddFriendProgress ftype);
			
			void onReceiveMsg_online(const string& sender, std::map<std::string, msgpack::object> &map);
			
			/*************************      post_wait处理线程             ***********************/
			void postThreadProcess();
			
			std::mutex _mtxNewPost; 
			std::condition_variable _cvNewPost;
			bool _newPostArrived;
			
			
			/***********************************/
			
			
			//清除临时朋友节点（查找用户结果）
			void clearTempFriend();
			
			//将好友临时头像文件转正
			string moveAvatarFitPosition(const string& friend_hashid);
			
			//发送上/下线通知
			void sendOnlinePacket();
			
			
			void sendPing(string remote_hashid);
			void onReceiveMsg_ping(const string& sender, std::map<std::string, msgpack::object> &data);
			void onReceiveMsg_pong(const string& sender, std::map<std::string, msgpack::object> &data);
			
			/************************* P2P ICE相关 ***********************************/
			PeersList _peers;
			std::mutex _mtxPeers; 
			
			void onReceiveMsg_p2pSdp(const string& sender, std::map<std::string, msgpack::object> &map);
			void onReceiveMsg_p2pRemoteResult(const string& sender, std::map<std::string, msgpack::object> &map);
			
			void startIce(const string& remoteId, const string& remoteSdp);
			
			void destroyP2P();
			
			
	};
}
