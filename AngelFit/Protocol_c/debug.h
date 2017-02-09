/*
 * debug.h
 *
 *  Created on: 2016年1月9日
 *      Author: Administrator
 */

#ifndef DEBUG_H_
#define DEBUG_H_

#include "config.h"

//调试信息配置

#define USE_DEBUG           1     //是否使用日志输出
#define USE_SOCKETLOG         1   //是否使用网络日志

#define USE_DEBUG_ANDROID	PROTOCOL_ANDROID     //是否启动android 日志
#define USE_DEBUG_IOS		PROTOCOL_IOS    	 //是否启动ios 日志

//断言
#define APP_ERROR_CHECK(ERR_CODE)	;

//默认标签[xxx]
#ifndef DEBUG_STR
#define DEBUG_STR   ""
#endif


//#define DEBUG_LINE_STR ("[LINE : %d]",__LINE__)
//行号信息
#define DEBUG_LINE_STR ""

#if USE_DEBUG


#if USE_DEBUG_ANDROID

#include <android/log.h>
#include "jni_debug.h"

#if USE_SOCKETLOG
#include "jni_protocol.h"
#endif


#define  LOG_TAG    "PROTOCOL_JNI"
#define DEBUG_PRINT(...) jni_log_print(ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__)
#define DEBUG_INFO(...)	 jni_log_info(ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__)


#if 0
#define DEBUG_PRINT(...) \
do {\
	__android_log_print(ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__); \
}while(0)
#endif

#if 0
#define DEBUG_INFO(...) \
do {\
	__android_log_print(ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__); \
while(0)
#endif


#endif /*end USE_DEBUG_ANDROID*/

#if USE_DEBUG_IOS

#if USE_SOCKETLOG
#import "SocketLogC.h"
#endif

#define DEBUG_PRINT(debug...) \
do {\
    printf(debug );\
    socket_debug_print(debug );\
}while(0)

#define DEBUG_INFO(debug...)     \
do {\
    printf(DEBUG_STR);\
    printf(DEBUG_LINE_STR);\
    printf(debug );\
    printf("\n");\
    socket_debug_print(DEBUG_STR);\
    socket_debug_print(DEBUG_LINE_STR);\
    socket_debug_print(debug );\
    socket_debug_print("\r\n");\
}while(0);

#else
#define DEBUG_PRINT(debug...) \
do {\
    printf(debug );\
}while(0)

#define DEBUG_INFO(debug...)     \
do {\
    printf(DEBUG_STR);\
    printf(DEBUG_LINE_STR);\
    printf(debug );\
    printf("\n");\
}while(0);


#endif

#endif //end USE_DEBUG_IOS

#else //USE_DEBUG

#define DEBUG_PRINT(...)	;
#define DEBUG_INFO(...)		;



#endif //USE_DEBUG

