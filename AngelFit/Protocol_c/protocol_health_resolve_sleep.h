/*
 * protocol_health_resolve_sleep.h
 *
 *  Created on: 2016年2月20日
 *      Author: Administrator
 */

#ifndef PROTOCOL_HEALTH_RESOLVE_SLEEP_H_
#define PROTOCOL_HEALTH_RESOLVE_SLEEP_H_

#include "include.h"
#include "protocol.h"
#include "protocol_health.h"

#define BLE_SYNC_SLEEP_TIME_DATA_MAX        8  //睡眠数据最大Items
#define BLE_SYNC_SLEEP_ITEM_ONE_DAY_DATA_MAX		80

#pragma pack(1)

    struct ble_sync_sleep_head
    {
        struct protocol_head head;
        uint8_t serial;
        uint8_t length;
        struct protocol_date date;
        uint8_t end_time_hour;
        uint8_t end_time_minute;
        uint16_t total_minute;
        uint8_t sleep_item_count;
        uint8_t packet_count;
    };

    struct ble_sync_sleep_head1
    {
        struct protocol_head head;
        uint8_t serial;
        uint8_t length;
        uint8_t light_sleep_count;
        uint8_t deep_sleep_count;
        uint8_t wake_count;
        uint16_t ligth_sleep_minute;
        uint16_t deep_sleep_minute;
    };

    struct ble_sync_sleep_item
    {
        uint8_t sleep_status;
        uint8_t durations;
    };

    struct ble_sync_sleep_data
    {
        struct protocol_head head;
        uint8_t serial;
        uint8_t lenght;
//        struct ble_sync_sleep_item sleep_data[(PROTOCOL_DATA_LENGTH - sizeof(struct protocol_sync_head)) / sizeof(struct ble_sync_sleep_item)];
        struct ble_sync_sleep_item sleep_data[BLE_SYNC_SLEEP_TIME_DATA_MAX];
    };


    struct  protocol_health_resolve_sleep_data_s
    {
    	struct ble_sync_sleep_head head1;
    	struct ble_sync_sleep_head1 head2;
    	struct ble_sync_sleep_item	itmes[BLE_SYNC_SLEEP_ITEM_ONE_DAY_DATA_MAX];
    	uint16_t itmes_count;
    };

    #pragma pack()

    typedef void (*protocol_health_resolve_sleep_data_handle_t)(struct protocol_health_resolve_sleep_data_s *data);

#ifdef __cplusplus
extern "C" {
#endif


extern uint32_t protocol_health_resolve_sleep_init(void);
extern uint32_t protocol_health_resolve_sleep_reg_data_callback(protocol_health_resolve_sleep_data_handle_t func);

#ifdef __cplusplus
}
#endif

#endif /* PROTOCOL_HEALTH_RESOLVE_SLEEP_H_ */
