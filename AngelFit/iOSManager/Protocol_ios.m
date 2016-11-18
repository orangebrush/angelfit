//
//  Protocol_ios_evt.c
//  BLEProject
//
//  Created by aiju on 16/3/3.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

#include "include.h"
#include "vbus_evt_app.h"
#include "Protocol_ios_port.h"
#include "protocol.h"

#include "protocol_func_table.h"
#include "protocol_health_resolve_sport.h"
#include "protocol_health_resolve_sleep.h"
#include "protocol_health_resolve_heart_rate.h"
#include "protocol_util.h"
#import "protocol_set_alarm.h"
//#import <Foundation/Foundation.h>
//
//#import "Protocol_model.h"
//#import "MacAddModel.h"
//#import "ProtocolDeviceInfoModel.h"
//#import "ProtocolDeviceFuncModel.h"

#import "CFunc.h"

static uint32_t set_time()
{
    uint32_t ret_code;
    struct protocol_set_time time;
    time.year = 2015;
    time.month = 7;
    time.day = 2;
    time.hour = 2;
    time.month = 2;
    time.second = 2;
    time.week = 3;
    vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SET_TIME, &time, sizeof(time),&ret_code);
    return SUCCESS;
}

static uint32_t set_user_info()
{
    uint32_t ret_code;
    struct protocol_set_user_info info;
    info.year = 1992;
    vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SET_USER_INFO,&info,sizeof(info),&ret_code);
    return SUCCESS;
}

static uint32_t set_alarm()
{
    struct protocol_set_alarm alarm;
    protocol_set_alarm_clean();
    protocol_set_alarm_add(alarm);
    protocol_set_alarm_add(alarm);
    protocol_set_alarm_start_sync();
    return SUCCESS;
}

static uint32_t set_long_sit()
{
    struct protocol_long_sit long_sit;
    uint32_t ret_code;
    long_sit.start_hour = 10;
    long_sit.start_minute = 11;
    vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SET_LONG_SIT, &long_sit, sizeof(long_sit),&ret_code);
    return SUCCESS;
}

static uint32_t set_lost_find()
{
    uint32_t ret_code;
    struct protocol_lost_find lost_find;
    lost_find.mode = 1;
    vbus_tx_data(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_SET_LOST_FIND, &lost_find, sizeof(lost_find),&ret_code);
    return SUCCESS;
}

static uint32_t set_goal()
{
    uint32_t ret_code;
    struct protocol_set_sport_goal goal;
    goal.type = 0x01;
    goal.data = 1;
    vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SET_SPORT_GOAL,&goal,sizeof(goal),&ret_code);
    return SUCCESS;
}

static uint32_t set_uint()
{
    uint32_t ret_code;
    struct protocol_set_uint uint;
    uint.is_12hour_format = 10;
    vbus_tx_data(VBUS_EVT_BASE_APP_SET,VBUS_EVT_APP_SET_UINT,&uint,sizeof(uint),&ret_code);
    return SUCCESS;
}




static uint32_t protocol_ios_vbus_control(VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,void *data,uint32_t size,uint32_t *error_code)
{
    uint32_t ret_code;
    //DEBUG_INFO("VBUS EVT , base = %s,type = %s",protocol_util_vbus_base_to_str(evt_base),protocol_util_vbus_evt_to_str(evt_type));
    if(evt_base == VBUS_EVT_BASE_NOTICE_APP)
    {
        switch(evt_type)
        {
            case VBUS_EVT_APP_GET_DEVICE_INFO :
                {
                    struct protocol_device_info *info = (struct protocol_device_info *)data;
                   // DEBUG_INFO("VBUS_EVT_APP_GET_DEVICE_INFO,version=%d,device id = %d",info->version,info->device_id);
                                  }
                break;
            case VBUS_EVT_APP_GET_FUNC_TABLE_USER :
                {
                    struct protocol_func_table func_table;
                    protocol_func_table_get(&func_table);
                    DEBUG_INFO("VBUS_EVT_APP_GET_FUNC_TABLE_USER alarm_count ＝%d ",func_table.alarm_count );
                }
                break;
            case VBUS_EVT_APP_APP_GET_MAC :
                {
                    struct protocol_device_mac *mac_addr = (struct protocol_device_mac *)data;
                  /*  DEBUG_PRINT("VBUS_EVT_APP_APP_GET_MAC :");
                    for(int i = 0; i < 6; i ++)
                    {
                        DEBUG_PRINT("%02X ",mac_addr->mac_addr[i]);
                    }
                    DEBUG_INFO("");
                    */
                    
                }
                break;
                
            case VBUS_EVT_APP_GET_LIVE_DATA:{
                
                struct protocol_start_live_data *liveData = data;
               
            }
                break;
                default:
                break;
                
        }
    }
    else if(evt_base == VBUS_EVT_BASE_REQUEST) //C库请求
    {
        switch (evt_type) {
            case VBUS_EVT_APP_SET_TIME:
                ble_send_set_time();
                // set_time();
                break;
            case VBUS_EVT_APP_SET_ALARM :
                ble_send_sync__alarm();
                // set_alarm();
                break;
            case VBUS_EVT_APP_SET_LONG_SIT :
                ble_send_sync__alarm();
                //set_long_sit();
                break;
            case VBUS_EVT_APP_SET_LOST_FIND :
                ble_send_lost_find();
                // set_lost_find();
                break;
            case VBUS_EVT_APP_SET_SPORT_GOAL :
                ble_send_goal();
                break;
            case VBUS_EVT_APP_SET_USER_INFO :
                ble_send_set_userinfo();
                break;
            case VBUS_EVT_APP_SET_UINT :
                ble_send_set_uint();
                break;
            case VBUS_EVT_APP_GET_DEVICE_INFO :
                vbus_tx_evt(VBUS_EVT_BASE_APP_GET,VBUS_EVT_APP_GET_DEVICE_INFO,&ret_code);
                break;
            case VBUS_EVT_APP_GET_FUNC_TABLE :
                vbus_tx_evt(VBUS_EVT_BASE_APP_GET,VBUS_EVT_APP_GET_FUNC_TABLE,&ret_code);
                break;
            case VBUS_EVT_APP_APP_GET_MAC :
                vbus_tx_evt(VBUS_EVT_BASE_APP_GET,VBUS_EVT_APP_APP_GET_MAC,&ret_code);
                break;
            case VBUS_EVT_APP_APP_TO_BLE_OPEN_ANCS:
            {
                vbus_tx_evt(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_APP_TO_BLE_OPEN_ANCS, &ret_code);
            }
                break;
            default:
            break;        }
    }
    
    return SUCCESS;
}


static uint32_t protocol_ios_vbus_init()
{
    struct vbus_t vbus;
    uint32_t id;
    uint32_t err_code;
    vbus.control = protocol_ios_vbus_control;
    vbus.name = "protocol ios";
    err_code = vbus_reg(vbus,&id);
    APP_ERROR_CHECK(err);
    
    return SUCCESS;
}

uint32_t protocol_ios_init()
{
   // protocol_ios_vbus_init();
   // protoocl_health_resolve_sport_reg_data_callback(protocol_health_resolve_sport_data_handle);
   // protocol_health_resolve_sleep_reg_data_callback(protocol_health_resolve_sleep_data_handle);
   // protocol_health_resolve_heart_rate_reg_data_callback(protocol_health_resolve_heart_rate_data_handle);
    return SUCCESS;
}
