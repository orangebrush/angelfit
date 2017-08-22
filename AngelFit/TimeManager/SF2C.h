//
//  SF2C.h
//  AngelFit
//
//  Created by aiju_huangjing1 on 2016/11/14.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

#ifndef SF2C_h
#define SF2C_h
#include <stdio.h>

#pragma mark 创建定时器
extern int32_t (^ __nonnull swiftTimeCreateClosure)(void);
extern int32_t c_create_timer(void);

#pragma mark 启动定时器
extern int32_t (^ __nonnull swiftTimerOnClosure)(int32_t identify,double during_time_interval);
extern int32_t c_start_timer(uint32_t identify,double during_time_interval);

#pragma mark 停止定时器
extern int32_t (^ __nonnull swiftTimerOffClosure)(int32_t identify);
extern int32_t c_stop_time(uint32_t identify);

#pragma mark 发送健康数据
extern int32_t (^ __nonnull swiftSendHealthDataClosure)(uint8_t * _Nonnull data,uint8_t length);
extern int32_t send_health_data( uint8_t * _Nonnull data,uint8_t length);

#pragma mark 发送命令
extern int32_t (^ __nonnull swiftSendCommandDataClosure)(uint8_t * _Nonnull data,uint8_t length);
extern uint32_t send_command_data(uint8_t * _Nonnull data,uint8_t length);

#pragma mark 读取运动数据
extern void (^ __nonnull swiftReadSportData)(void * __nonnull data);
extern void c_read_sport_data(void * __nonnull data);

#pragma mark 读取睡眠数据
extern void (^ __nonnull swiftReadSleepData)(void * __nonnull data);
extern void c_read_sleep_data(void * __nonnull data);

#pragma mark 读取心率数据
extern void (^ __nonnull swiftReadHeartRateData)(void * __nonnull data);
extern void c_read_heart_rate_data(void * __nonnull data);

#pragma mark 初始化所需文件
void initialization_c_function();

#endif /* SF2C_h */
