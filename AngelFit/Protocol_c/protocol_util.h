/*
 * protocol_util.h
 *
 *  Created on: 2016年1月21日
 *      Author: Administrator
 */

#include "include.h"
#include "vbus_evt_app.h"

#ifndef PROTOCOL_UTIL_H_
#define PROTOCOL_UTIL_H_


#define UTIL_BYTE_TO_STR(bytes)
#define ARRAY_LEN(arr)	(sizeof(arr)/sizeof(arr[0]))
#define NAME_TO_STR(str) (#str)


#ifdef __cplusplus
extern "C" {
#endif


//事件转字符串
extern char *protocol_util_vbus_base_to_str(VBUS_EVT_BASE base);
extern char *protocol_util_vbus_evt_to_str(VBUS_EVT_TYPE type);
//错误代码转字符串
extern char *protocol_util_error_to_str(uint32_t error_code);


#ifdef __cplusplus
}
#endif

#endif /* PROTOCOL_UTIL_H_ */
