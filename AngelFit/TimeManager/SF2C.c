//
//  SF2C.c
//  AngelFit
//
//  Created by aiju_huangjing1 on 2016/11/14.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

#include "SF2C.h"
#include "CFunc.h"
#include "protocol.h"
#include "Protocol_ios_port.h"
#include "Protocol_ios.h"
#include "protocol_health_resolve_sport.h"
#include "protocol_health_resolve_sleep.h"
#include "protocol_health_resolve_heart_rate.h"
#include "protocol_sync_activity_resolve.h"

#include "CDataManager.h"
int32_t (^ __nonnull swiftTimeCreateClosure)(void) = NULL;
int32_t (^ __nonnull swiftTimerOnClosure)(int32_t identify,double during_time_interval) = NULL;
int32_t (^ __nonnull swiftTimerOffClosure)(int32_t identify) = NULL;
int32_t (^ __nonnull swiftSendHealthDataClosure)(uint8_t * _Nonnull data,uint8_t length) = NULL;
int32_t (^ __nonnull swiftSendCommandDataClosure)(uint8_t * _Nonnull data,uint8_t length) = NULL;


#pragma mark 创建定时器
extern int32_t c_create_timer(){
  return swiftTimeCreateClosure();
}
#pragma mark 启动定时器
extern int32_t c_start_timer(uint32_t identify,double during_time_interval){
    return swiftTimerOnClosure(identify, during_time_interval);
}
#pragma mark 停止定时器
extern int32_t c_stop_time(uint32_t identify){
    return swiftTimerOffClosure(identify);
}
#pragma mark 发送健康数据
extern int32_t send_health_data( uint8_t * _Nonnull data,uint8_t length){
    return swiftSendHealthDataClosure(data,length);
}
#pragma mark 发送命令
extern uint32_t send_command_data(uint8_t * _Nonnull data,uint8_t length){
    return swiftSendCommandDataClosure(data,length);
}





static uint32_t protocol_ios_vbus_control_asdk(VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,void *data,uint32_t size,uint32_t *error_code)
{
    manageData(evt_base, evt_type , data, size, error_code);
   // [ASDKShareControl Protocol_ios_vbusWith:evt_base and:evt_type andData:data andSize:size andRetCode:error_code];
    
    return SUCCESS;
}
static uint32_t protocol_ios_vbus_init()
{
    struct vbus_t vbus;
    uint32_t id;
    uint32_t err_code;
    vbus.control = protocol_ios_vbus_control_asdk;
    vbus.name = "protocol SDK";
    err_code = vbus_reg(vbus,&id);
    APP_ERROR_CHECK(err);
    
    return SUCCESS;
}


void protocol_health_resolve_sport_data_handle(struct protocol_health_resolve_sport_data_s *data)
{
    DEBUG_INFO("protocol_health_resolve_sport_data_handle");
    DEBUG_INFO("%d-%d-%d ",data->head1.date.year,data->head1.date.month,data->head1.date.day);
//    ProtocolSportDataModel *model = [[ProtocolSportDataModel alloc] initWith:*data];
//    /*
//     先删除，在插入
//     */
//    if ([model.items_count integerValue]>0) {
//        [model saveWith:model.date];
//        
//    }
    
    
}

void protocol_health_resolve_sleep_data_handle(struct protocol_health_resolve_sleep_data_s *data)
{
    DEBUG_INFO("protocol_health_resolve_sleep_data_handle ");
    DEBUG_INFO("%d-%d-%d",data->head1.date.year,data->head1.date.month,data->head1.date.day);
//    ProtocolSleepDataModel *model = [[ProtocolSleepDataModel alloc] initWith:*data];
//    /*
//     先删除，在插入
//     */
//    if ([model.itmes_count integerValue]>0) {
//        [model saveWith:model.date];
//    }
    
    
    
}

void protocol_health_resolve_heart_rate_data_handle(struct protocol_health_resolve_heart_rate_data_s *data)
{
    DEBUG_INFO("protocol_health_resolve_heart_rate_data_handle ");
    DEBUG_INFO("%d-%d-%d",data->head1.year,data->head1.month,data->head1.day);
   // ProtocolHeartRateModel *model = [[ProtocolHeartRateModel alloc] initWith:*data];
    /*
     先删除，在插入
     */
//    if ([model.itmes_count integerValue]>0) {
//        [model saveWith:model.date];
//    }
}
void protocol_sync_activity_resolve_data(const struct protocol_activity_data *data){
    DEBUG_INFO("protocol_active_resolve_data_handle ");
    DEBUG_INFO("%d-%d-%d",data->head.time.year,data->head.time.month,data->head.time.day);
//    ProtocolActivityModel *model = [[ProtocolActivityModel alloc] initWith:*data];
//    if ([model.time_string integerValue]>200) {
//        ProtocolActivityModel *model1 = [ProtocolActivityModel findFirstWithFormat:@"WHERE smart_device_id = '%@' AND time_string = '%@'",[ShareDataSdk shareInstance].smart_device_id,model.time_string];
//        if (model1) {
//            model.pk = model1.pk;
//        }
//        model.is_have_serial = NO;
//        
//        [model saveOrUpdate];
//    }
    
}
#pragma mark 初始化所需文件
void initialization_c_function(){
    timer_ios_init();
    protocol_init(protocol_ios_send_data);
    
    protocol_ios_port_init();
    protocol_ios_init();
    
    protocol_ios_vbus_init();
    protoocl_health_resolve_sport_reg_data_callback(protocol_health_resolve_sport_data_handle);
    protocol_health_resolve_sleep_reg_data_callback(protocol_health_resolve_sleep_data_handle);
    protocol_health_resolve_heart_rate_reg_data_callback(protocol_health_resolve_heart_rate_data_handle);
    protocol_sync_activity_resolve_data_cb_reg(protocol_sync_activity_resolve_data);
    
    vbus_print_info();

    
}
