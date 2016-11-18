//
//  CDataManager.c
//  AngelFit
//
//  Created by aiju_huangjing1 on 2016/11/16.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

#include "CDataManager.h"

void (^ __nonnull swiftMacAddress)(void * __nonnull) = NULL;
void (^ __nonnull swiftDeviceInfo)(void * __nonnull) = NULL;
void (^ __nonnull swiftFuncTable)(void * __nonnull)  = NULL;
void (^ __nonnull swiftLiveData)(void * __nonnull)   = NULL;
void (^ __nonnull swiftGetCameraSignal)(VBUS_EVT_TYPE type) = NULL;
void (^ __nonnull swiftSynchronizationHealthData)(bool status , int percent) = NULL;
void (^ __nonnull swiftSynchronizationConfig)(bool status) = NULL;
void (^ __nonnull swiftSynchronizationAlarm)(bool status) = NULL;
void (^ __nonnull swiftGetNoticeStatus)(int8_t notice,int8_t status,int8_t errorCode) = NULL;
void (^ __nonnull swiftSendSetTime)() = NULL;



extern void c_get_macAddress(void * __nonnull data){
    swiftMacAddress(data);
}

extern void c_get_device_info(void * __nonnull data){
    swiftDeviceInfo(data);
}

extern void c_get_func_table(void * __nonnull data){
    swiftFuncTable(data);
}

extern void c_get_live_data(void * __nonnull data){
    swiftLiveData(data);
}

extern void c_get_camera_signal(VBUS_EVT_TYPE type){
    swiftGetCameraSignal(type);
}

extern void c_synchronization_health_data(bool status , int percent){
    swiftSynchronizationHealthData(status,percent);
}

extern void c_synchronization_config(bool status){
    swiftSynchronizationConfig(status);
}
extern void c_synchronization_alarm(bool status){
    swiftSynchronizationAlarm(status);
}
extern void c_get_notice_status(int8_t notice,int8_t status,int8_t errorCode){
    swiftGetNoticeStatus(notice,status,errorCode);
}

#pragma mark 设置时间
extern void c_send_set_time(){
     swiftSendSetTime();
}
#pragma mark 处理C返回的数据
void manageData(VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,void * __nonnull data,uint32_t size,uint32_t * __nonnull error_code){
    DEBUG_INFO("VBUS EVT , base = %s,type = %s",protocol_util_vbus_base_to_str(evt_base),protocol_util_vbus_evt_to_str(evt_type));
     uint32_t ret_code;
    
    if (evt_base == VBUS_EVT_BASE_NOTICE_APP) {
        switch (evt_type) {
            case VBUS_EVT_APP_APP_GET_MAC:
                c_get_macAddress(data);
                break;
            case VBUS_EVT_APP_GET_DEVICE_INFO:{
                c_get_device_info(data);
            }
                break;
            case VBUS_EVT_APP_GET_FUNC_TABLE_USER:{
                c_get_func_table(data);
            }
                break;
            case VBUS_EVT_APP_GET_LIVE_DATA:{
                c_get_live_data(data);
            }
                break;
            case VBUS_EVT_APP_BLE_TO_APP_PHOTO_SINGLE_SHOT:{
                c_get_camera_signal(VBUS_EVT_APP_BLE_TO_APP_PHOTO_SINGLE_SHOT);
            }
                break;
            case SYNC_EVT_HEALTH_PROGRESS:{
                c_synchronization_health_data(false, (uint32_t)data);
            }
                 break;
            case SYNC_EVT_HEALTH_SYNC_COMPLETE:{
                c_synchronization_health_data(true, 100);
            }
                break;
            case SYNC_EVT_CONFIG_SYNC_COMPLETE:{
                c_synchronization_config(true);
            }
                break;
            case SYNC_EVT_ALRM_SYNC_COMPLETE:{
                c_synchronization_alarm(true);
            }
                break;
            case VBUS_EVT_APP_GET_NOTICE_STATUS:{
                if (data) {
                    struct protocol_set_notice_ack *notice = data;
                    c_get_notice_status(notice->notify_switch, notice->status_code, notice->err_code);
                }
                else{
                 c_get_notice_status(0x55, 0 , 0);
                }
            }
                break;
            default:
                break;
        }
    }
    else if(evt_base == VBUS_EVT_BASE_REQUEST){
        switch (evt_type) {
            case VBUS_EVT_APP_SET_TIME:{
                c_send_set_time();
            }
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
                vbus_tx_evt(VBUS_EVT_BASE_APP_SET, VBUS_EVT_APP_APP_TO_BLE_OPEN_ANCS, &ret_code);
                break;
            default:
                break;
        }
    }
}

