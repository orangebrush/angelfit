//
//  CDataManager.h
//  AngelFit
//
//  Created by aiju_huangjing1 on 2016/11/16.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

#ifndef CDataManager_h
#define CDataManager_h
#include "vbus_evt_app.h"
#include <stdio.h>
#include <stdbool.h>
#include "protocol.h"

#pragma mark 获取mac地址
void manageData(VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,void * __nonnull data,uint32_t size,uint32_t * __nonnull error_code);


#pragma mark 获取mac地址
extern void (^ __nonnull swiftMacAddress)(void * __nonnull);
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

//extern uint32_t sendSyncLongSit();
//extern uint32_t sendSyncLostFind();
//extern uint32_t sendSetGoal();

//extern uint32_t sendSetUint();

#endif /* CDataManager_h */
