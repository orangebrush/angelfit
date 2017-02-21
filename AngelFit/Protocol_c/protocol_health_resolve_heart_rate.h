/*
 * protocol_health_resolve_heart_rate.h
 *
 *  Created on: 2016年2月20日
 *      Author: Administrator
 */

#ifndef PROTOCOL_HEALTH_RESOLVE_HEART_RATE_H_
#define PROTOCOL_HEALTH_RESOLVE_HEART_RATE_H_


#include "include.h"
#include "protocol.h"
#include "protocol_health.h"

#define BLE_SYNC_HEART_RATE_TIME_DATA_MAX   	8  //心率数据最大包
#define BLE_SYNC_HEART_RATE_ITEM_ONE_DAY_MAX	(24*60/5)

#pragma pack(1)



struct ble_sync_heart_rate_head
{
	struct protocol_head head;
	uint8_t serial;
	uint8_t length;
	uint16_t year;
	uint8_t month;
	uint8_t day;
	uint16_t minute_offset;
	uint8_t silent_heart_rate;
	uint16_t items_count;
	uint8_t packets_count;


};

struct ble_sync_heart_rate_head1
{
	struct protocol_head head;
	uint8_t serial;
	uint8_t length;
	uint8_t burn_fat_threshold;
	uint8_t aerobic_threshold;
	uint8_t limit_threshold;
	uint16_t burn_fat_mins;
	uint16_t aerobic_mins;
	uint16_t limit_mins;


};


struct ble_sync_heart_rate_item
{
	uint8_t offset;
	uint8_t data;
};


struct ble_sync_heart_rate_data
{
	struct protocol_head head;
	uint8_t serial;
	uint8_t lenght;
	struct ble_sync_heart_rate_item data[BLE_SYNC_HEART_RATE_TIME_DATA_MAX];
};

struct protocol_health_resolve_heart_rate_data_s
{
	struct ble_sync_heart_rate_head head1;
	struct ble_sync_heart_rate_head1 head2;
	struct ble_sync_heart_rate_item items[BLE_SYNC_HEART_RATE_ITEM_ONE_DAY_MAX];
	uint16_t items_count;
};


#pragma pack()

typedef void (*protocol_health_resolve_heart_rate_data_handle_t)(struct protocol_health_resolve_heart_rate_data_s *data);

#ifdef __cplusplus
extern "C" {
#endif

extern uint32_t protocol_health_resolve_heart_rate_init(void);
extern uint32_t protocol_health_resolve_heart_rate_reg_data_callback(protocol_health_resolve_heart_rate_data_handle_t func);

#ifdef __cplusplus
}
#endif

#endif /* PROTOCOL_HEALTH_RESOLVE_HEART_RATE_H_ */
