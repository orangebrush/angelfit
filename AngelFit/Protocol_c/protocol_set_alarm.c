/*
 * protocol_set_alarm.c
 * protocol_set_alarm
 *
 *  Created on: 2016年1月18日
 *      Author: Administrator
 */
//闹钟同步处理
#define DEBUG_STR "[PROTOCOL_SET_ALARM]"

#define ALARM_MAX_SIZE		20

#include "debug.h"
#include "include.h"
#include "app_timer.h"
#include "vbus.h"
#include "vbus_evt_app.h"
#include "protocol_set_alarm.h"
#include "protocol_write.h"




static uint32_t sync_alarm_timer_id;
static volatile uint32_t cur_sync_index = 0;
static volatile uint32_t alarm_count = 0;
static volatile bool alarm_is_sync = false;
static struct protocol_set_alarm alarm_table[ALARM_MAX_SIZE];
static struct protocol_set_alarm sync_ok_alarm_table[ALARM_MAX_SIZE];


static protocol_set_alarm_sync_evt sync_evt_handle = NULL;

uint32_t protocol_set_alarm_add(struct protocol_set_alarm alarm)
{

	if(alarm.alarm_id >= ALARM_MAX_SIZE)
	{
		return ERROR_INVALID_LENGTH;
	}
	memcpy(&alarm_table[alarm_count],&alarm,sizeof(struct protocol_set_alarm));
	alarm_count ++;
	return SUCCESS;
}

uint32_t protocol_set_alarm_clean()
{
	protocol_set_alarm_stop_sync();
	alarm_count = 0;
	memset(alarm_table,0,sizeof(alarm_table));
	return SUCCESS;
}

uint32_t protocol_set_alarm_start_sync()
{
    uint32_t ret_code = SUCCESS;
    
	if(alarm_is_sync == true)
	{
		DEBUG_INFO("alarm is sync start");
		return ERROR_INVALID_STATE;
	}

	if(alarm_count == 0)
	{
		DEBUG_INFO("alarm count = %d",alarm_count);
        vbus_tx_evt(VBUS_EVT_BASE_NOTICE_APP,SYNC_EVT_ALRM_SYNC_COMPLETE,&ret_code);
		return SUCCESS;
	}

	cur_sync_index = 0;
	alarm_is_sync = true;

	app_timer_stop(sync_alarm_timer_id);
	app_timer_start(sync_alarm_timer_id,50,NULL);

	/*
	vbus_tx_data(VBUS_EVT_BASE_SET,VBUS_EVT_APP_SET_ALARM,&alarm_table[cur_sync_index],sizeof(struct protocol_set_alarm));
	cur_sync_index ++;
	*/

	return SUCCESS;
}

uint32_t protocol_set_alarm_stop_sync()
{
	alarm_is_sync = false;
    app_timer_stop(sync_alarm_timer_id);
	return SUCCESS;
}

static uint32_t protocol_set_alarm_vbus_control(VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,void *data,uint32_t size,uint32_t *error_code)
{
    uint32_t ret_code = SUCCESS;
	if(alarm_is_sync == false)
	{
		return SUCCESS;
	}
	if(evt_base == VBUS_EVT_BASE_BLE_REPLY)
	{
		switch((uint32_t)evt_type)
		{
		case VBUS_EVT_APP_SET_ALARM :

			if(cur_sync_index >= alarm_count)
			{
				DEBUG_INFO("alarm sync ok");
				vbus_tx_evt(VBUS_EVT_BASE_NOTICE_APP,SYNC_EVT_ALRM_SYNC_COMPLETE,&ret_code);
				alarm_is_sync = false;
                app_timer_stop(sync_alarm_timer_id);
			}
			else
			{
				//启动定时器,发送下一个数据
				app_timer_stop(sync_alarm_timer_id);
				app_timer_start(sync_alarm_timer_id,50,NULL);

			}
                struct protocol_set_alarm_progress_s progress;
                progress.sync_id = cur_sync_index;
			vbus_tx_data(VBUS_EVT_BASE_NOTICE_APP,SYNC_EVT_ALARM_PROGRESS,&progress,sizeof(progress),&ret_code);
			break;
		}
	}
    else if(evt_base == VBUS_EVT_BASE_SET)
    {
        if(evt_type == SET_BLE_EVT_DISCONNECT)
        {
			if(alarm_is_sync == true)
			{
				uint32_t ret_code = ERROR_INVALID_STATE;
				vbus_tx_evt(VBUS_EVT_BASE_NOTICE_APP,SYNC_EVT_ALRM_SYNC_COMPLETE,&ret_code);
			}

            protocol_set_alarm_stop_sync();
            vbus_tx_evt(VBUS_EVT_BASE_NOTICE_APP,SYNC_EVT_ALRM_SYNC_COMPLETE,&ret_code);
        }
    }
    else if(evt_base == VBUS_EVT_BASE_NOTICE_APP)
    {
        if(evt_type == VBUS_EVT_APP_SET_ALARM && (*error_code != SUCCESS))
        {
            protocol_set_alarm_stop_sync();
            vbus_tx_evt(VBUS_EVT_BASE_NOTICE_APP,SYNC_EVT_ALRM_SYNC_COMPLETE,error_code);
        }
    }

	return SUCCESS;
}

static uint32_t protocol_set_alarm_vbus_init()
{
	struct vbus_t alarm;
	uint32_t id;
	uint32_t err_code;
	alarm.control = protocol_set_alarm_vbus_control;
	alarm.name = "protocol alarm set";
	err_code = vbus_reg(alarm,&id);
	APP_ERROR_CHECK(err);

	return SUCCESS;
}

static void protoocl_set_alarm_timer_handle(void *data)
{
    uint32_t ret_code;
	DEBUG_INFO("alarm sync index = %d",cur_sync_index);
	vbus_tx_data(VBUS_EVT_BASE_SET,VBUS_EVT_APP_SET_ALARM,&alarm_table[cur_sync_index],sizeof(struct protocol_set_alarm),&ret_code);
	cur_sync_index ++;
}

uint32_t protocol_set_sync_evt(protocol_set_alarm_sync_evt func)
{
	sync_evt_handle = func;
    return SUCCESS;
}

uint32_t protocol_set_alarm_init()
{
	uint32_t err;
	protocol_set_alarm_vbus_init();
	memset(alarm_table,0,sizeof(alarm_table));
	alarm_is_sync = false;
	DEBUG_INFO("protocol_set_alarm_init");
	err = app_timer_create(&sync_alarm_timer_id,protoocl_set_alarm_timer_handle);
	DEBUG_INFO("protocol_set_alarm_init ok");
	return err;
}



