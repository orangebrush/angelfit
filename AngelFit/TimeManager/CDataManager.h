//
//  CDataManager.h
//  AngelFit
//
//  Created by aiju_huangjing1 on 2016/11/16.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

#include "vbus_evt_app.h"
#include <stdio.h>
#include <stdbool.h>
#pragma mark 获取mac地址
void manageData(VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,void * __nonnull data,uint32_t size,uint32_t * __nonnull error_code);


#pragma mark 获取mac地址
extern void (^ __nonnull swiftMacAddress)(void * __nonnull);
extern void (^ __nonnull swiftTempMacAddress)(void * __nonnull);
extern void c_get_macAddress(void * __nonnull data);

#pragma mark 获取设备信息
extern void (^ __nonnull swiftDeviceInfo)(void * __nonnull);
extern void c_get_device_info(void * __nonnull data);

#pragma 获取功能列表
extern void (^ __nonnull swiftFuncTable)(void * __nonnull);
extern void c_get_func_table(void * __nonnull data);

#pragma 获取实时数据
extern void (^ __nonnull swiftLiveData)(void * __nonnull data);
extern void c_get_live_data(void * __nonnull);

#pragma 收到拍照信号
extern void (^ __nonnull swiftGetCameraSignal)(VBUS_EVT_TYPE type);
extern void c_get_camera_signal(VBUS_EVT_TYPE type);

#pragma 收到同步数据
extern void (^ __nonnull swiftSynchronizationHealthData)(bool status , int percent);
extern void c_synchronization_health_data(bool status , int percent);

#pragma 收到同步配置状态
extern void (^ __nonnull swiftSynchronizationConfig)(bool status);
extern void c_synchronization_config(bool status);

#pragma 收到同步闹钟状态
extern void (^ __nonnull swiftSynchronizationAlarm)(bool status);
extern void c_synchronization_alarm(bool status);

#pragma 收到总开关状态
extern void (^ __nonnull swiftGetNoticeStatus)(int8_t notice,int8_t status,int8_t errorCode);
extern void c_get_notice_status(int8_t notice,int8_t status,int8_t errorCode);

#pragma mark 收到C库请求
#pragma mark 设置时间
extern void (^ __nonnull swiftSendSetTime)(void);
extern void c_send_set_time();

#pragma mark 同步闹钟
extern void (^ __nonnull swiftSyncAlarm)(void);
extern void c_send_sync_alarm();

#pragma mark 设置久坐
extern void (^ __nonnull swiftSetLongSit)(void);
extern void c_send_set_long_sit();

#pragma mark 设置个人信息
extern void (^ __nonnull swiftSetUserInfo)(void);
extern void c_send_set_user_info();

#pragma mark 设置单位
extern void (^ __nonnull swiftSetUnit)(void);
extern void c_send_set_unit();

#pragma mark 获取交换数据reply
extern void (^ __nonnull swiftSwitchStartReply)(void * __nonnull);
extern void c_switch_start_reply(void * __nonnull);

extern void (^ __nonnull swiftSwitchingReply)(void * __nonnull);
extern void c_switching_reply(void * __nonnull);

extern void (^ __nonnull swiftSwitchPauseReply)(void * __nonnull);
extern void c_swich_pause_reply(void * __nonnull);

extern void (^ __nonnull swiftSwitchRestartReply)(void * __nonnull);
extern void c_swich_restart_reply(void * __nonnull);

extern void (^ __nonnull swiftSwitchEndReply)(void * __nonnull);
extern void c_swich_end_reply(void * __nonnull);

#pragma mark app发起交换数据，手环控制暂停继续结束
extern void (^ __nonnull swiftSwitchBlePause)(void * __nonnull);
extern void c_swich_ble_pause(void * __nonnull);

extern void (^ __nonnull swiftSwitchBleRestart)(void * __nonnull);
extern void c_swich_ble_restart(void * __nonnull);

extern void (^ __nonnull swiftSwitchBleEnd)(void * __nonnull);
extern void c_swich_ble_end(void * __nonnull);
//extern uint32_t sendSyncLongSit();
//extern uint32_t sendSyncLostFind();
//extern uint32_t sendSetGoal();

//extern uint32_t sendSetUint();


