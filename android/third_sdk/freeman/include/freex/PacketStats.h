#pragma once
#include <string>
#include <stdint.h>
#include "AppConfig.h"

namespace FX
{
	enum MsgStatusCode{
		STATUS_ERROR = -1,
		STATUS_INIT = 0,
		STATUS_SENDED,	//已发
		STATUS_RECVED,	//已收
		STATUS_READED	//已读	
	};
	
	//消息发送统计数据
	struct MsgSendStats{
		uint64_t msgId; //消息ID
		uint64_t totalBytes;		
		uint64_t passedBytes;
		double progress; //进度值
		MsgStatusCode status; //状态码，参见MsgStatusCode
		string errStr; //如果出错, 此处描述错误原因
		time_t updatetime; //更新时间（用于超时清理_msgSendStats或判断）
		MsgSendStats()
		{
			totalBytes = 0;
			passedBytes = 0;
			progress = 0.0;
			status = STATUS_INIT;			
		}
	};
	
	
	class PacketStats {

	public:
		
		PacketStats(uint64_t id);
		~PacketStats();
		
		void setOwnerId(uint64_t userid);
		void setNeedAck(bool needack);
		void setTopic(const std::string& topic);
		void setRemote(const std::string& remote);
		void setContent(char* data, int len);
		void setTotalBytes(uint64_t total);
		uint64_t getTotalBytes();
		void setStatus(MsgStatusCode status);
		void passBytes(uint64_t total);
		void getStats(MsgSendStats& stats);
	private:
		static AppConfig *_cfg;
		static sqlite3 *_db;
		int64_t _id;
	};
}
