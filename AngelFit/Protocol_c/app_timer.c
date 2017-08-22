/*
 * app_timer.c
 *
 *  Created on: 2016年1月8日
 *      Author: Administrator
 */

//协议使用的定时器,只有接口,没有实现



#include "app_timer.h"

static app_timer_create_st app_timer_create_handle = NULL;
static app_timer_start_st app_timer_start_handle = NULL;
static app_timer_stop_st app_timer_stop_handle = NULL;

uint32_t app_timer_init(app_timer_create_st create_func,app_timer_start_st start_func,app_timer_stop_st stop_func)
{
	app_timer_create_handle = create_func;
	app_timer_start_handle = start_func;
	app_timer_stop_handle = stop_func;

	if(create_func == NULL || (start_func == NULL) || (stop_func == NULL))
	{
		return ERROR_NULL;
	}
	return SUCCESS;

}

uint32_t app_timer_create(uint32_t *timer_id,app_timer_timeout_evt func)
{
	if(app_timer_create_handle != NULL)
	{
		return app_timer_create_handle(timer_id,func);
	}
	return ERROR_NULL;
}


uint32_t app_timer_start(uint32_t timer_id,uint32_t ms,void *data)
{
	if(app_timer_start_handle != NULL)
	{
		return app_timer_start_handle(timer_id,ms,data);
	}
	return ERROR_NULL;
}

uint32_t app_timer_stop(uint32_t timer_id)
{
	if(app_timer_stop_handle != NULL)
	{
		return app_timer_stop_handle(timer_id);
	}
	return ERROR_NULL;
}


