/*
 * protocol_switch_data.h
 *
 *  Created on: 2016年9月27日
 *      Author: Administrator
 */

 
#ifndef PROTOCOL_SWITCH_DATA_H_
#define PROTOCOL_SWITCH_DATA_H_


#include "include.h"
#include "protocol.h"

#define PROTOCOL_CMD_SWITCH_DATA							0x10

#define PROTOCOL_KEY_SWITCH_DATA_APP_START					0x01
#define PROTOCOL_KEY_SWITCH_DATA_APP_ING					0x02
#define PROTOCOL_KEY_SWITCH_DATA_APP_END					0x03
#define PROTOCOL_KEY_SWITCH_DATA_APP_PAUSE					0x04
#define PROTOCOL_KEY_SWITCH_DATA_APP_RESTORE				0x05
#define PROTOCOL_KEY_SWITCH_DATA_APP_BLE_END				0x06
#define PROTOCOL_KEY_SWITCH_DATA_APP_BLE_PAUSE			0x07
#define PROTOCOL_KEY_SWITCH_DATA_APP_BLE_RESTORE			0x08


#define PROTOCOL_KEY_SWITCH_DATA_BLE_START					0x11
#define PROTOCOL_KEY_SWITCH_DATA_BLE_ING					0x12
#define PROTOCOL_KEY_SWITCH_DATA_BLE_END					0x13
#define PROTOCOL_KEY_SWITCH_DATA_BLE_PAUSE					0x14
#define PROTOCOL_KEY_SWITCH_DATA_BLE_RESTORE				0x15

#pragma pack(1)

struct protocol_start_time
{
	uint8_t day 	;
	uint8_t hour	;
	uint8_t minute  ;
	uint8_t second  ;
};


struct protocol_switch_heart_rate_values
{
	uint8_t avg_hr_value;	//平均心率
	uint8_t max_hr_value;
	uint8_t burn_fat_mins;
	uint8_t aerobic_mins;
	uint8_t limit_mins;
};

struct protocol_switch_heart_rate_values_items
{
	uint8_t cur_hr_value;
	uint8_t interval_second;
	uint8_t hr_value_serial;
	uint8_t hr_vlaue[6];
};

struct protocol_switch_app_start
{
	struct protocol_head head;
	struct protocol_start_time start_time;
	uint8_t sport_type;
	uint8_t target_type;
	uint32_t target_value;
	uint8_t force_start;

};


struct protocol_switch_app_start_reply
{
	struct protocol_head head;
	uint8_t ret_code;
};


struct protocol_switch_app_ing
{
	struct protocol_head head;
	struct protocol_start_time start_time;
	uint8_t flag;
	uint32_t duration	: 20;
	uint32_t calories	: 18;
	uint32_t distance	: 18;
};

struct protocol_switch_app_ing_reply
{
	struct protocol_head head;
	uint8_t status;
	uint32_t step		: 20;
	uint32_t calories	: 18;
	uint32_t distance	: 18;
	struct protocol_switch_heart_rate_values_items hr_item;
};

struct protocol_switch_app_end
{
	struct protocol_head head;
	struct protocol_start_time start_time;
	uint32_t durations : 20;
	uint32_t calories  : 18;
	uint32_t distance  : 18;
	uint8_t sport_type;
	uint8_t is_save;
};


struct protocol_switch_app_end_reply
{
	struct protocol_head head;
	uint8_t err_code;
	uint32_t step 		: 20;
	uint32_t calories 	: 18;
	uint32_t distance	: 18;
	struct protocol_switch_heart_rate_values hr_value;

};


struct protocol_switch_app_pause
{
	struct protocol_head head;
	struct protocol_start_time start_time;

};

struct protocol_switch_app_pause_reply
{
	struct protocol_head head;
	uint8_t err_code;
};


struct protocol_switch_app_restore
{
	struct protocol_head head;
	struct protocol_start_time start_time;
};

struct protocol_switch_app_restore_reply
{
	struct protocol_head head;
	uint8_t err_code;
};


struct protocol_switch_app_ble_pause
{
	struct protocol_head head;
	struct protocol_start_time start_time;
};


struct protocol_switch_app_ble_pause_reply
{
	struct protocol_head head;
	uint8_t err_code;
};


struct protocol_switch_app_ble_restore
{
	struct protocol_head head;
	struct protocol_start_time start_time;
};


struct protocol_switch_app_ble_restore_reply
{
	struct protocol_head head;
	uint8_t err_code;
};

struct protocol_switch_app_ble_end
{
	struct protocol_head head;
	struct protocol_start_time start_time;
	uint32_t step		: 20;
	uint32_t calories	: 18;
	uint32_t distance	: 18;
	struct protocol_switch_heart_rate_values hr_value;
	uint8_t is_save;
};

struct protocol_switch_app_ble_end_reply
{
	struct protocol_head head;
	uint8_t err_code;
	uint32_t duration	: 20;
	uint32_t calories	: 18;
	uint32_t distance	: 18;

};

struct protocol_switch_ble_start
{
	struct protocol_head head;
	struct protocol_start_time start_time;
	uint8_t type;
};

struct protocol_switch_ble_start_reply
{
	struct protocol_head head;
	uint8_t ret_code;
};

struct protocol_switch_ble_ing
{
	struct protocol_head head;
	struct protocol_start_time start_time;

};

struct protocol_switch_ble_ing_reply
{
	struct protocol_head head;
	uint32_t distance : 24;
};


struct protocol_switch_ble_end
{
	struct protocol_head head;
	struct protocol_start_time start_time;

};

struct protocol_switch_ble_end_reply
{
	struct protocol_head head;
	uint8_t ret_code;
};

struct protocol_switch_ble_pause
{
	struct protocol_head head;
	struct protocol_start_time start_time;
};


struct protocol_switch_ble_pause_reply
{
	struct protocol_head head;
	uint8_t ret_code;
};



struct protocol_switch_ble_restore
{
	struct protocol_head head;
	struct protocol_start_time start_time;
};

struct protocol_switch_ble_restore_reply
{
	struct protocol_head head;
	uint8_t ret_code;
};


#pragma pack()


#ifdef __cplusplus
extern "C" {
#endif


extern uint32_t protocol_switch_init(void);
extern uint32_t protocol_switch_exec(const uint8_t *data,uint16_t length);


#ifdef __cplusplus
}
#endif


#endif /* PROTOCOL_SWITCH_DATA_H_ */
