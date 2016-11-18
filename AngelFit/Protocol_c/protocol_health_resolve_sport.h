/*
 * protocol_health_resolve_sport.h
 *
 *  Created on: 2016年2月18日
 *      Author: Administrator
 */

#ifndef PROTOCOL_HEALTH_RESOLVE_SPORT_H_
#define PROTOCOL_HEALTH_RESOLVE_SPORT_H_


#include "include.h"
#include "protocol.h"
#include "protocol_health.h"


#define BLE_SYNC_SPORT_IIEM_DATA_MAX        3 //运动数据一个包发3个item
#define BLE_SYNC_SPORT_ONE_DAY_ITEMS_MAX	(24*60/15)

#pragma pack(1)

    struct ble_sync_sport_head
    {
        struct protocol_head head;
        uint8_t serial;
        uint8_t length;
        struct protocol_date date;
        uint16_t minute_offset;
        uint8_t per_minute;
        uint8_t item_count;
        uint8_t packet_count;
        uint8_t reserved;
    };

    struct ble_sync_sport_head1
    {
        struct protocol_head head;
        uint8_t serial;
        uint8_t length;
        uint32_t total_step;
        uint32_t total_cal;
        uint32_t total_distances;
        uint32_t total_active_time;
    };


    struct ble_sync_sport_item
    {
        uint16_t mode : 2;
        uint16_t sport_count : 12;
        uint16_t active_time : 4;
        uint16_t calories : 10;
        uint16_t distance : 12;
    };

    struct ble_sync_sport_data
    {
        struct protocol_head head;
        uint8_t serial;
        uint8_t length;
        struct ble_sync_sport_item item[BLE_SYNC_SPORT_IIEM_DATA_MAX];
    };



    struct protocol_health_resolve_sport_data_s
    {
    	struct ble_sync_sport_head head1;
    	struct ble_sync_sport_head1 head2;
    	struct ble_sync_sport_item items[BLE_SYNC_SPORT_ONE_DAY_ITEMS_MAX];
    	uint16_t items_count;
    };


    #pragma pack()

    typedef void (*protocol_health_resolve_sport_data_handle_t)(struct protocol_health_resolve_sport_data_s *data);

#ifdef __cplusplus
extern "C" {
#endif

extern uint32_t protocol_health_resolve_sport_init(void);
extern uint32_t protoocl_health_resolve_sport_reg_data_callback(protocol_health_resolve_sport_data_handle_t func); //注册运动数据回调

#ifdef __cplusplus
}
#endif

#endif /* PROTOCOL_HEALTH_RESOLVE_SPORT_H_ */
