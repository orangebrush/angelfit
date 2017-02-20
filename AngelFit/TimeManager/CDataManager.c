//
//  CDataManager.c
//  AngelFit
//
//  Created by aiju_huangjing1 on 2016/11/16.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

#include "CDataManager.h"
#include "protocol_func_table.h"
void (^ __nonnull swiftTempMacAddress)(void * __nonnull) = NULL;
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
void (^ __nonnull swiftSyncAlarm)(void) = NULL;
void (^ __nonnull swiftSetLongSit)(void) = NULL;
void (^ __nonnull swiftSetUserInfo)(void) = NULL;
void (^ __nonnull swiftSetUnit)(void) = NULL;
void (^ __nonnull swiftSwitchStartReply)(void * __nonnull) = NULL;
void (^ __nonnull swiftSwitchingReply)(void * __nonnull) = NULL;
void (^ __nonnull swiftSwitchPauseReply)(void * __nonnull) = NULL;
void (^ __nonnull swiftSwitchRestoreReply)(void * __nonnull) = NULL;
void (^ __nonnull swiftSwitchEndReply)(void * __nonnull) = NULL;
void (^ __nonnull swiftSwitchBlePause)(void * __nonnull) = NULL;
void (^ __nonnull swiftSwitchBleRestore)(void * __nonnull) = NULL;
void (^ __nonnull swiftSwitchBleEnd)(void * __nonnull) = NULL;
void (^ __nonnull swiftBleSwitchStart)(void * __nonnull) = NULL;
void (^ __nonnull swiftBleSwitching)(void * __nonnull) = NULL;
void (^ __nonnull swiftBleSwitchPause)(void * __nonnull) = NULL;
void (^ __nonnull swiftBleSwitchRestore)(void * __nonnull) = NULL;
void (^ __nonnull swiftBleSwitchEnd)(void * __nonnull) = NULL;
void (^ __nonnull swiftGetActiveCount)(void * __nonnull) = NULL;
void (^ __nonnull swiftSyncActiveTimeOut)() = NULL;
void (^ __nonnull swiftSyncActiveProgress)(int) = NULL;
void (^ __nonnull swiftSyncActiveComplete)() = NULL;
void (^ __nonnull swiftSyncActiveData)(void * __nonnull) = NULL;
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

extern void c_send_sync_alarm(){
    swiftSyncAlarm();
}
extern void c_send_set_time(){
     swiftSendSetTime();
}
extern void c_send_set_long_sit(){
    swiftSetLongSit();
}
extern void c_send_set_user_info(){
    swiftSetUserInfo();
}
extern void c_send_set_unit(){
    swiftSetUnit();
}

extern void c_switch_start_reply(void * __nonnull data){
    swiftSwitchStartReply(data);
}
extern void c_switching_reply(void * __nonnull data){
    swiftSwitchingReply(data);
}
extern void c_swich_pause_reply(void * __nonnull data){
    swiftSwitchPauseReply(data);
}
extern void c_swich_restore_reply(void * __nonnull data){
    swiftSwitchRestoreReply(data);
}
extern void c_swich_end_reply(void * __nonnull data){
    swiftSwitchEndReply(data);
}
extern void c_swich_ble_pause(void * __nonnull data){
    swiftSwitchBlePause(data);
}
extern void c_swich_ble_restore(void * __nonnull data){
    swiftSwitchBleRestore(data);
}
extern void c_swich_ble_end(void * __nonnull data){
    swiftSwitchBleEnd(data);
}
extern void c_ble_swich_start(void * __nonnull data){
    swiftBleSwitchStart(data);
}
extern void c_ble_swich_ing(void * __nonnull data){
    swiftBleSwitching(data);
}
extern void c_ble_swich_pause(void * __nonnull data){
    swiftBleSwitchPause(data);
}
extern void c_ble_swich_restore(void * __nonnull data){
    swiftBleSwitchRestore(data);
}
extern void c_ble_swich_end(void * __nonnull data){
    swiftBleSwitchEnd(data);
}
extern void c_get_active_count(void * __nonnull data){
    swiftGetActiveCount(data);
}
extern void c_sync_active_timeout(){
    swiftSyncActiveTimeOut();
}
extern void c_sync_active_progress(int progress){
    swiftSyncActiveProgress(progress);
}
extern void c_sync_active_complete(){
    swiftSyncActiveComplete();
}
extern void c_sync_active_data(void * __nonnull data){
    swiftSyncActiveData(data);
}


#pragma mark 处理C返回的数据
void manageData(VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,void * __nonnull data,uint32_t size,uint32_t * __nonnull error_code){
    
    DEBUG_INFO("VBUS EVT , base = %s,type = %s",protocol_util_vbus_base_to_str(evt_base),protocol_util_vbus_evt_to_str(evt_type));
     uint32_t ret_code;
    
    if (evt_base == VBUS_EVT_BASE_NOTICE_APP) {
        switch (evt_type) {
            case VBUS_EVT_APP_APP_GET_MAC:
                printf("获取mac地址 ：%s",data);
                c_get_macAddress(data);
                break;
            case VBUS_EVT_APP_GET_DEVICE_INFO:{
                c_get_device_info(data);
            }
                break;
            case VBUS_EVT_APP_GET_FUNC_TABLE_USER:{
                struct protocol_func_table func_table;
                protocol_func_table_get(&func_table);
                c_get_func_table(&func_table);
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
                //收到交换数据开始回调
            case VBUS_EVT_APP_SWITCH_APP_START_REPLY:{
                c_switch_start_reply(data);
            }
                break;
            case VBUS_EVT_APP_SWITCH_APP_ING_REPLY:{
                c_switching_reply(data);
            }
                break;
            case VBUS_EVT_APP_SWITCH_APP_PAUSE_REPLY:{
                c_swich_pause_reply(data);
            }
                break;
            case VBUS_EVT_APP_SWITCH_APP_RESTORE_REPLY:{
                c_swich_restore_reply(data);
            }
                break;
            case VBUS_EVT_APP_SWITCH_APP_END_REPLY:{
                c_swich_end_reply(data);
            }
                break;
            case VBUS_EVT_APP_SWITCH_APP_BLE_PAUSE:{
                c_swich_ble_pause(data);
            }
                break;
            case VBUS_EVT_APP_SWITCH_APP_BLE_RESTORE:{
                c_swich_ble_restore(data);
            }
                break;
            case VBUS_EVT_APP_SWITCH_APP_BLE_END:{
                c_swich_ble_end(data);
            }
                break;
            case VBUS_EVT_APP_SWITCH_BLE_START:{
                c_ble_swich_start(data);
            }
                break;
            case VBUS_EVT_APP_SWITCH_BLE_ING:{
                c_ble_swich_ing(data);
            }
                break;
            case VBUS_EVT_APP_SWITCH_BLE_END:{
                c_ble_swich_end(data);
            }
                break;
            case VBUS_EVT_APP_SWITCH_BLE_PAUSE:{
                c_ble_swich_pause(data);
            }
                break;
            case VBUS_EVT_APP_SWITCH_BLE_RESTORE:{
                c_ble_swich_restore(data);
            }
                break;
            case VBUS_EVT_APP_ACTIVITY_SYNC_TIMEOUT:{
                c_sync_active_timeout();
            }
                break;
            case VBUS_EVT_APP_GET_ACTIVITY_COUNT:{
                c_get_active_count(data);
            }
                break;
            case VBUS_EVT_APP_ACTIVITY_SYNC_COMPLETE:{
                c_sync_active_complete();
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
            case VBUS_EVT_APP_SET_ALARM :{
                c_send_sync_alarm();
            }
                break;
            case VBUS_EVT_APP_SET_USER_INFO :
                c_send_set_user_info();
                break;
            case VBUS_EVT_APP_SET_UINT:{
                c_send_set_unit();
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

