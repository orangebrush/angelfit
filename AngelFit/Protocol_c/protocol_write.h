/*
 * protocol_write.h
 *
 *  Created on: 2016年1月9日
 *      Author: Administrator
 */

#ifndef PROTOCOL_WRITE_H_
#define PROTOCOL_WRITE_H_

#include "include.h"
#include "protocol_exec.h"


#ifdef __cplusplus
extern "C" {
#endif

extern uint32_t protocol_write_set_cmd_key(uint8_t cmd,uint8_t key,const void *data,uint32_t size,bool need_resend,VBUS_EVT_TYPE evt_type);
extern uint32_t protocol_write_set_head(struct protocol_head head,const void *data,uint32_t size,bool need_resend,VBUS_EVT_TYPE evt_type);
extern uint32_t protocol_write_init(void);
#ifdef __cplusplus
}
#endif

#endif /* PROTOCOL_WRITE_H_ */
