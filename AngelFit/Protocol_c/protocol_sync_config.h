/*
 * protocol_sync_config.h
 *
 *  Created on: 2016年2月15日
 *      Author: Administrator
 */

#ifndef PROTOCOL_SYNC_CONFIG_H_
#define PROTOCOL_SYNC_CONFIG_H_


#include "include.h"

#ifdef __cplusplus
extern "C" {
#endif

extern uint32_t protocol_sync_config_start(void); //开始同步配置
extern uint32_t protocol_sync_config_stop(void); //停止同步配置
extern bool protocol_sync_config_get_is_run(void);	//获取同步状态
extern uint32_t protocol_sync_config_init(void);
extern uint32_t protocol_sync_config_check(void);

#ifdef __cplusplus
}
#endif

#endif /* PROTOCOL_SYNC_CONFIG_H_ */
