#pragma once
#include <string>

//tail -f /var/log/syslog | grep FreeMan
#include <syslog.h>

#include "def.h"
#include "sqlite3.h"

#define GET_STMT_STRING_COL(stmt, x)   sqlite3_column_text(stmt, x) == NULL ? "": std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, x)))


namespace FX
{
	using namespace std;
	
	
	class AppConfig{
	    public:
    	    static AppConfig* getInstance();
            static sqlite3* getDB() { return _db; };
    	    
    		void pushBootStrap(const string& id, const string& addr);
    		void setDataPath(const string& dataPath);
    		string getIdFile();
    		string getIdPwd();
    		
    		//传用用户id，返回相应的hashid。如果用户id不存在，则返回空字符串
    		string getHashIdByClientId(const string& clientid);
    		
    		//保存用户id/name与hashid的对应关系
    		void newUser(const string& clientid, const string& hashid, const string& inviteCode);
    		
            //接收到新的文件，将相关信息存储进数据库
            void SaveFileTask(const string& sender, const string& filesum, const string& filename,  uint64_t totalItems, uint64_t totalBytes);

    		void SaveToDB(const string& filesum, int idx, char* buff, uint64_t buff_bytes);

            //导出文件
            bool dumpFile(const string& filesum);

            void dropFileTask(const string& filesum);

            static int executeSQL(const string sql);


			//置顶会话
			bool pinTopConversation(const string& id, int isTop);

            //获取好友名（如果有设置别名，则返回别名）
            string getFriendName(const string& remoteid, const string& ownerid);
			//根据hashid获取userid
			uint64_t getUserId(const string& remoteid);

			
			//设置好友头像
			bool setFriendAvatar(const string& remoteid, const string& avatar_path);
			
			/*************************************** 我的 ******************************/
			//修改昵称
			void changeNickname(const string& hashid, const string& name);
			
			

		private:
		    AppConfig();
		    ~AppConfig();
		    string _dataPath;
		    static sqlite3 *_db;
		    void createTables();
			void importDhtBootstrap();
		    static AppConfig* _instance;
			static bool _dbPrintError;

            
	};
}
