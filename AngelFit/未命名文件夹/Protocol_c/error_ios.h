//
//  error_ios.h
//  BLEProject
//
//  Created by aiju_huangjing1 on 16/3/22.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

#ifndef error_ios_h
#define error_ios_h
#include "error.h"
//健康数据同步完成
#define ERROR_HEALTH_SYNC_COMPLETE 19
//同步闹钟完成
#define ERROR_ALARM_SYNC_COMPLETE 20
//同步配置完成
#define ERROR_CONFIG_SYNC_COMPLETE 25
//未保存该条数据
#define UN_SAVE_THE_DATA 500
//同步配置失败
#define SYSC_CONFIG_ERROR 600
//同步活动数据超时
#define SYSC_ACTIVE_DATA_TIME_OUT 700

//没有活动数据
#define NO_ACTIVE_DATA 800
//未保存个人信息
#define UN_SAVE_USER_INFO 1000
//闹钟数量超过最大
#define ALARM_COUNT_OUTDO 2000
//删除闹钟失败
#define ALARM_DELETE_ERROR 2100
//更新闹钟失败
#define ALARM_UPDATE_ERROR 2200

//未保存久坐提醒
#define UN_SAVE_LONG_SIT 3000

//未保存防丢模型
#define UN_SAVE_LOST_FIND 4000

//未保存设置目标
#define UN_SAVE_SET_GOAL 5000

//未保存实时数据
#define UN_SAVE_LIVE_DATA 6000

//未保存单位模型
#define UN_SAVE_UNIT_MODEL 7000

//未保存功能列表
#define UN_SAVE_FUNC_TABLE 8000

//未保存抬腕识别模型
#define UN_SAVE_HAND_GESTURE 9000

//未保存设备信息
#define UN_SAVE_DEVICE_INFO 10000

//未保存智能提醒信息
#define UN_SAVE_NOTICE_DATA 11000

//设备未连接
#define DEVIDE_DISCONNECTED 12000
#endif /* error_ios_h */
