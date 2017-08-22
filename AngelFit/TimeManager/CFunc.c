//
//  CFunc.c
//  AngelFit
//
//  Created by aiju_huangjing1 on 2016/11/15.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

#include "CFunc.h"
#include "include.h"
#include "app_timer.h"
#include "SF2C.h"
#define TIMER_ITME_MAX_SIZE 10

typedef void (*timer_ios_timeout_evt)(void *data);

struct timer_ios_st
{
    bool is_start;
    uint32_t time_ms;
    timer_ios_timeout_evt handler;
    void *data;
};

static struct timer_ios_st timer_table[TIMER_ITME_MAX_SIZE];
static uint8_t cur_timer_max_size = 0;

uint32_t ProtocolLibcallBackTimerCrate(){
    return c_create_timer();
}
uint32_t ProtocolLibcallBackTimerStart(uint32_t id,uint32_t timeOutMs){
    
    return c_start_timer(id, timeOutMs);
}
uint32_t ProtocolLibcallBackTimerStop(uint32_t id){
    return c_stop_time(id);
}



uint32_t timer_ios_time_out_handler(uint32_t id)
{
    DEBUG_INFO(" timer ios timer handler , id = %d",id);
    if(id > cur_timer_max_size)
    {
        return ERROR_INVALID_PARAM;
    }
    
    if(timer_table[id].handler != NULL)
    {
        timer_table[id].handler(timer_table[id].data);
        timer_table[id].is_start = false;
    }
    return SUCCESS;
}

int ProtocolLibTimerHandler(uint32_t id){
    timer_ios_time_out_handler(id);
    return 0;
}

uint32_t timer_ios_create(uint32_t *timer_id,timer_ios_timeout_evt func)
{
    
    if(cur_timer_max_size >= TIMER_ITME_MAX_SIZE)
    {
        return ERROR_NO_MEM;
    }
    
    if(timer_id == NULL)
    {
        return ERROR_NULL;
    }
    
    
    // = cur_timer_max_size;
    cur_timer_max_size ++;
    
    *timer_id = ProtocolLibcallBackTimerCrate();
    DEBUG_INFO("timer_ios_create : %d",*timer_id);
    timer_table[*timer_id].handler = func;
    return SUCCESS;
    
}

uint32_t timer_ios_start(uint32_t timer_id,uint32_t ms,void *data)
{
    
    if(timer_id >= cur_timer_max_size)
    {
        return ERROR_INVALID_PARAM;
    }
    timer_table[timer_id].data = data;
    timer_table[timer_id].is_start = true;
    timer_table[timer_id].time_ms = ms;
    ProtocolLibcallBackTimerStart(timer_id,ms);
    return SUCCESS;
}


uint32_t timer_ios_stop(uint32_t timer_id)
{
    
    if(timer_id >= cur_timer_max_size)
    {
        return ERROR_INVALID_PARAM;
    }
    timer_table[timer_id].is_start = false;
    ProtocolLibcallBackTimerStop(timer_id);
    return SUCCESS;
}

uint32_t timer_ios_init()
{
    memset(timer_table,0,sizeof(timer_table));
    cur_timer_max_size = 0;
    
    app_timer_init(timer_ios_create, timer_ios_start, timer_ios_stop);
    
    return SUCCESS;
}



uint32_t ble_send_command_data(uint8_t *data,uint8_t length){
   send_command_data(data, length);
    return 1;
}
uint32_t ble_send_health_data(uint8_t *data,uint8_t length){
    send_health_data(data, length);
    return 1;
}

uint32_t ble_send_set_time(){
   // SendSetTime();
    return 1;
}
uint32_t ble_send_sync__alarm(){
   // SendSyncAlarm();
    return 1;
}
#pragma mark 设置久坐
uint32_t ble_send_long_sit(){
   // SendSyncLongSit();
    return 1;
}

#pragma mark 设置防丢
uint32_t ble_send_lost_find(){
   // SendSyncLostFind();
    return 1;
}

#pragma mark 设置目标
uint32_t ble_send_goal(){
   // SendSetGoal();
    return 1;
}

#pragma mark 设置用户信息
uint32_t ble_send_set_userinfo(){
   // SendSetUserInfo();
    return 1;
}
#pragma mark  设置到位
uint32_t ble_send_set_uint(){
   // SendSetUint();
    return 1;
}

