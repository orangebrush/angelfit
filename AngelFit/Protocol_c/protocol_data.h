/*
 * protocol_data.h
 *
 *  Created on: 2016年1月22日
 *      Author: Administrator
 */

#ifndef PROTOCOL_DATA_H_
#define PROTOCOL_DATA_H_

#include "include.h"


typedef enum
{
    PROTOCOL_MODE_UNBIND, //没有绑定
    PROTOCOL_MODE_BIND,   //已经绑定
    PROTOCOL_MODE_OTA,    //升级模式
}PROTOCOL_MODE;

#ifdef __cplusplus
extern "C" {
#endif

extern PROTOCOL_MODE protoocl_get_mode(void);
extern uint32_t protocol_set_mode(PROTOCOL_MODE mode);

#ifdef __cplusplus
}
#endif

#endif /* PROTOCOL_DATA_H_ */
