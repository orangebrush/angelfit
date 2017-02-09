/*
 * protocol_sync_activity.h
 *
 *  Created on: 2016年10月14日
 *      Author: Administrator
 */

#ifndef PROTOCOL_SYNC_ACTIVITY_H_
#define PROTOCOL_SYNC_ACTIVITY_H_

#include "include.h"
#include "protocol.h"




#define PROTOCOL_ACTIVITY_DATA_MAX_PACKET_LENGTH		(16)
#define PROTOCOL_ACTIVITY_DATA_MAX_PACKET_NUM			(1440/PROTOCOL_ACTIVITY_DATA_MAX_PACKET_LENGTH + 3)



#pragma pack(1)

struct protocol_activity_start_time
{
	uint8_t year;
	uint8_t month;
	uint8_t day;
	uint8_t hour;
	uint8_t minute;
	uint8_t second;
};


struct protocol_activity_head
{
	struct protocol_head head;
	uint8_t serial;
	uint8_t length;
};


struct protocol_activity_data_head
{
	struct protocol_head head;
	uint8_t serial;
	uint8_t length;

	struct protocol_activity_start_time time;
	uint8_t data_length;
	uint16_t hr_data_interval_minute;
	uint8_t hr_item_count;
	uint8_t packet_count;

};


struct protocol_activity_ex_data1
{

	struct protocol_head head;
	uint8_t serial;
	uint8_t length;

	uint8_t type;
	uint32_t step :18;
	uint32_t durations : 20;
	uint32_t calories : 18;
	uint32_t distance : 18;


};


struct protocol_activity_ex_data2
{

	struct protocol_head head;
	uint8_t serial;
	uint8_t length;

	uint8_t avg_hr_value;
	uint8_t max_hr_value;
	uint16_t burn_fat_mins;
	uint16_t aerobic_mins;
	uint16_t limit_mins;
};


struct protocol_activity_hr_data
{
    struct protocol_head head;
    uint8_t serial;
    uint8_t length;
    uint8_t data[16];

};

struct activity_packet_data
{
	uint8_t serial;
	uint8_t length;
	uint8_t hr_data[PROTOCOL_TRANSPORT_MAX_SIZE];
};

struct protocol_activity_hr_tx_complete
{
	struct protocol_head head;
	uint8_t serial;
	uint8_t length;
	uint8_t flag;
};

struct protocol_new_health_activity_count
{
	struct protocol_head head;
	uint8_t count;
};


#pragma pack()

typedef void (*protocol_sync_activity_data_cb_t)(const struct activity_packet_data data[],uint16_t serial_count);
typedef uint16_t (*protocol_sync_activiey_get_packet_count_t)(uint8_t *data,uint16_t length);
typedef void (*protocol_sync_activity_progress )(uint8_t progress);



#ifdef __cplusplus
extern "C" {
#endif


extern uint32_t protocol_sync_activity_rx_data_reg(protocol_sync_activity_data_cb_t func);
extern uint32_t protocol_sync_activity_get_packet_reg(protocol_sync_activiey_get_packet_count_t func);
extern uint32_t protocol_sync_activity_progress_reg(protocol_sync_activity_progress func);

extern uint32_t protocol_sync_activity_exec(const uint8_t *data,uint16_t length);


extern uint32_t protocol_sync_activity_init(void);
extern uint32_t protocol_sync_activity_start(void);	//开始同步
extern uint32_t protocol_sync_activity_stop(void);	//
extern uint32_t protocol_sync_activity_restart(void);		//重新同步
extern bool protocol_sync_activity_get_sync_status(void);	//获取同步状态


#ifdef __cplusplus
}
#endif

#endif /* PROTOCOL_SYNC_ACTIVITY_H_ */
