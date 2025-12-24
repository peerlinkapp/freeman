#pragma once

#define APP_NAME "FreeMan"
#define ID_FILE "id"
#define ID_PWD "test"
#define PACKET_SPLIT_VERSION 1
#define PACKET_CLIENT_VERSION 1

#define TOPIC_PREFIX "freex_"

#define SEND_AVATAR

#define INFO_HASH_BYTES 20
#define ID_LEN 40
#define FILE_READ_ONCE_BYTES 1024
#define FILE_MAX_PATH 1024
#define FILE_CHUNK_BYTES 11352
#define FILE_PRESEND_IDX_OFFSET 30 //用于发送文件的滑动窗口控制

#define NAME_MAX_LEN 100 //名称的最大长度
#define REMARK_MAX_LEN 1000 //备注的最大长度

#define LEVEL_ONE_FANS_NUM 10 //一级粉丝数量（用于直接接收post数据的粉丝列表）

#define DHT_MSG_BYTES 1900


#ifdef OS_ANDROID
#include  <android/log.h>
#define  TAG    "JNITEST"
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, TAG,__VA_ARGS__)
#else

#endif