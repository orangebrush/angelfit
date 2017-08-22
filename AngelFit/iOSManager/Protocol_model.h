//
//  Protocol_model.h
//  BLEProject
//
//  Created by aiju_huangjing1 on 16/3/15.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
#import "MacAddModel.h"
#import "ProtocolDeviceInfoModel.h"
#import "ProtocolDeviceFuncModel.h"
#import "ProtocolLiveDataModel.h"

//获取功能列表
typedef void(^GetFuncListBlock)(ProtocolDeviceFuncModel *deviceFModel);

//获取mac地址
typedef void(^GetMacAddBlock)(MacAddModel *macModel);

//获取设备信息
typedef void(^GetDeviceInfoBlock)(ProtocolDeviceInfoModel *deviceModel);

//同步健康数据
typedef void(^ProtocolHealthSyncStart)(VBUS_EVT_TYPE type);

//同步闹钟数据
typedef void (^ProtocolAlarmSyncStart)(VBUS_EVT_TYPE type);

//获取实时数据
typedef void(^ProtocolLiveData)(ProtocolLiveDataModel *pModel);

//同步配置信息
typedef void (^ProtocolConfigStart)(VBUS_EVT_TYPE type);

//通知app进行拍照,防丢和音乐控制
typedef void (^ProtocolNoticeControlApp)(VBUS_EVT_TYPE type);

typedef void (^ProtocolNoticeBindRemove)(VBUS_EVT_TYPE type);

typedef void (^ProtocolSynProgress)(NSInteger persent);

//获取通知中心总开关状态
typedef void (^ProtocolGetNoticeState)(NSInteger,NSInteger,NSInteger);

//通知设备重连
typedef void (^ProtocolNoticeReconnect)(NSString *);

//交换数据应答手机端主动
typedef void (^ProtocolSwitchData)(VBUS_EVT_TYPE type,id object);

//交换数据应答手环端主动
typedef void (^ProtocolSwitchDataBack)(VBUS_EVT_TYPE vtype,NSString *startTime,NSInteger type);

//活动数据同步返回状态
typedef void (^ProtocolUpdateActivetyData)(VBUS_EVT_TYPE vtype);

@interface Protocol_model : NSObject
@property (nonatomic,copy) GetFuncListBlock gflBlock;
@property (nonatomic,copy) GetMacAddBlock gmaBlock;
@property (nonatomic,copy) GetDeviceInfoBlock gdiBlock;
@property (nonatomic,copy) ProtocolHealthSyncStart phssBlock;
@property (nonatomic,copy) ProtocolLiveData pldBlock;
@property (nonatomic,copy) ProtocolConfigStart pcsBlock;
@property (nonatomic,copy) ProtocolNoticeControlApp pncBlock;
@property (nonatomic,copy) ProtocolNoticeControlApp findPhoneBlock;
@property (nonatomic,copy) ProtocolAlarmSyncStart pasBlock;
@property (nonatomic,copy) ProtocolNoticeBindRemove pnbBlock;
@property (nonatomic,copy) ProtocolSynProgress pspBlock;
@property (nonatomic,copy) ProtocolGetNoticeState pgnBlock;
@property (nonatomic,copy) ProtocolNoticeReconnect pnrBlock;
@property (nonatomic,copy) ProtocolSwitchData psdBlock;
@property (nonatomic,copy) ProtocolSwitchDataBack psdbBlock;
@property (nonatomic,copy)ProtocolUpdateActivetyData puaBlock;

- (void)didAlarmBlock:(ProtocolAlarmSyncStart)block;

- (void)didBandingRemove:(ProtocolNoticeBindRemove)block;
- (void)didUpdateActiveData:(ProtocolUpdateActivetyData)block;
+ (Protocol_model *)shareProtocolModel;
*/
@interface Protocol_model : NSObject
@end
