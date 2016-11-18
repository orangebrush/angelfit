/*
 * protocol_set_alarm.h
 *
 *  Created on: 2016年1月18日
 *      Author: Administrator
 */

#ifndef PROTOCOL_SET_ALARM_H_
#define PROTOCOL_SET_ALARM_H_

#include "include.h"
#include "protocol.h"

//闹钟同步进度结构体
struct protocol_set_alarm_progress_s
{
    uint8_t sync_id; //已经同步的id
};

typedef void (*protocol_set_alarm_sync_evt)(uint32_t err_code);

#ifdef __cplusplus
extern "C" {
#endif

extern uint32_t protocol_set_alarm_init(void);
extern uint32_t protocol_set_alarm_add(struct protocol_set_alarm alarm); //添加闹钟
extern uint32_t protocol_set_alarm_clean(void);	//请求之前添加的闹钟
extern uint32_t protocol_set_alarm_start_sync(void);	//开始同步闹钟
extern uint32_t protocol_set_alarm_stop_sync(void);	//停止闹钟同步
extern uint32_t protocol_set_sync_evt(protocol_set_alarm_sync_evt func);
#ifdef __cplusplus
}
#endif

#endif /* PROTOCOL_SET_ALARM_H_ */
