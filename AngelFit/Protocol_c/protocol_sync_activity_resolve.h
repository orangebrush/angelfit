/*
 * protocol_sync_activity_resolve.h
 *
 *  Created on: 2016年10月17日
 *      Author: Administrator
 */

#ifndef PROTOCOL_SYNC_ACTIVITY_RESOLVE_H_
#define PROTOCOL_SYNC_ACTIVITY_RESOLVE_H_

#include "include.h"
#include "protocol_sync_activity.h"


#define PROTOCOL_SYNC_ACTIVITY_RESOLVE_HR_ITME_MAX_SIZE	(2*60*60/5)

#pragma pack(1)
struct protocol_activity_data
{
	struct protocol_activity_data_head head;
	struct protocol_activity_ex_data1 ex_data1;
	struct protocol_activity_ex_data2 ex_data2;
	uint8_t *hr_value;	//5s钟保存一组,最大保存2小时
};

#pragma pack()


typedef void (*protocol_sync_activity_resolve_data_cb_t) (const struct protocol_activity_data *data);

#ifdef __cplusplus
extern "C" {
#endif

extern uint32_t protocol_sync_activity_resolve_init(void);
extern uint32_t protocol_sync_activity_resolve_data_cb_reg(protocol_sync_activity_resolve_data_cb_t func);


#ifdef __cplusplus
}
#endif

#endif /* PROTOCOL_SYNC_ACTIVITY_RESOLVE_H_ */
