/*
 * app_timer.h
 *
 *  Created on: 2016年2月16日
 *      Author: Administrator
 */

#ifndef APP_TIMER_H_
#define APP_TIMER_H_

#include "include.h"




typedef void (*app_timer_timeout_evt)(void *data);
typedef uint32_t (*app_timer_create_st)(uint32_t *timer_id,app_timer_timeout_evt func); //创建定时器
typedef uint32_t (*app_timer_start_st)(uint32_t timer_id,uint32_t ms,void *data); //开始定时器
typedef uint32_t (*app_timer_stop_st)(uint32_t timer_id); //停止定时器


#ifdef __cplusplus
extern "C" {
#endif

extern uint32_t app_timer_init(app_timer_create_st create_func,app_timer_start_st start_func,app_timer_stop_st stop_func); //初始化定时器

//库使用
extern uint32_t app_timer_create(uint32_t *timer_id,app_timer_timeout_evt func);
extern uint32_t app_timer_start(uint32_t timer_id,uint32_t ms,void *data);
extern uint32_t app_timer_stop(uint32_t timer_id);

#ifdef __cplusplus
}
#endif

#endif /* APP_TIMER_H_ */
