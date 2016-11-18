/*
 * protocol_sync_activity.c
 *
 *  Created on: 2016年10月13日
 *      Author: Administrator
 */



#include "protocol.h"
#include "protocol_sync_activity.h"
#include "app_timer.h"



static struct activity_packet_data rx_packet_buf[PROTOCOL_ACTIVITY_DATA_MAX_PACKET_NUM + 2];
static protocol_sync_activiey_get_packet_count_t get_packet_count_handle = NULL;
static protocol_sync_activity_data_cb_t sync_activity_rx_data_handle = NULL;
static volatile uint16_t rx_packet_count = 0;
static volatile bool sync_is_start = false;


static uint32_t sync_timer;
static uint32_t delay_restart_timer;
static uint32_t sync_timeout_timer;


static uint32_t protocol_activity_write_data(const uint8_t *data,uint16_t length)
{
	return protocol_write_data(data,length);
}

uint32_t protocol_sync_activity_start()
{

	if(sync_is_start == true)
	{
		DEBUG_INFO("protocol_sync_activity_start is start");
		return SUCCESS;
	}

	struct protocol_activity_head data;
	memset(&data,0,sizeof(data));
	memset(&rx_packet_buf,0,sizeof(rx_packet_buf));
	DEBUG_INFO("protocol_sync_activity_start");
	data.head.cmd = PROTOCOL_CMD_NEW_HEALTH_DATA;
	data.head.key = PROTOCOL_KEY_NEW_HEALTH_DATA_ACTIVITY_DATA;
	data.serial = 1;
	protocol_activity_write_data((uint8_t *)&data,sizeof(data));
	sync_is_start = true;
	rx_packet_count = 0;

	app_timer_start(sync_timeout_timer,5000,NULL);

	return SUCCESS;
}

uint32_t protocol_sync_activity_stop()
{
	DEBUG_INFO("protocol_sync_activity_stop");
	struct protocol_activity_head data;
	memset(&data,0,sizeof(data));
	memset(&rx_packet_buf,0,sizeof(rx_packet_buf));
	DEBUG_INFO("protocol_sync_activity_start");
	data.head.cmd = PROTOCOL_CMD_NEW_HEALTH_DATA;
	data.head.key = PROTOCOL_KEY_NEW_HEALTH_DATA_ACTIVITY_DATA;
	data.serial = 0;
	protocol_activity_write_data((uint8_t *)&data,sizeof(data));
	sync_is_start = false;
	app_timer_stop(sync_timeout_timer);
	return SUCCESS;
}

uint32_t protocol_sync_activity_restart()
{
	DEBUG_INFO("protocol_sync_activity_restart");
	sync_is_start = false;
	protocol_sync_activity_start();
	return SUCCESS;
}

bool protocol_sync_activity_get_sync_status()
{
	return sync_is_start;
}


static bool check_packet_data_and_exec()
{
	uint16_t need_packet_count = 0 ;
	int i;
	if(get_packet_count_handle != NULL)
	{
		need_packet_count = get_packet_count_handle(rx_packet_buf[1].hr_data,rx_packet_buf[1].length);
	}

	if(rx_packet_count != 0)
	{
		for(i = 1; i <= need_packet_count; i ++)
		{
			if(rx_packet_buf[i].length == 0)
			{
				DEBUG_INFO("check_packet_data_and_exec fail : packet = %d,%d = 0",need_packet_count,i);
				return false;
			}
		}
	}
	else //没有数据
	{
		memset(rx_packet_buf,0,sizeof(rx_packet_buf));
	}


	if(sync_activity_rx_data_handle != NULL)
	{
		DEBUG_INFO("check_packet_data_and_exec,packet count = %d",need_packet_count);
		sync_activity_rx_data_handle(rx_packet_buf,need_packet_count);
	}


	return true;


}

uint32_t protocol_sync_activity_exec(const uint8_t *data,uint16_t length)
{
	uint32_t ret_code = SUCCESS;
	struct protocol_activity_hr_data *hr_data = (struct protocol_activity_hr_data *)data;

	if(data == NULL)
	{
		return ERROR_NULL;
	}

	if((hr_data->head.cmd != PROTOCOL_CMD_NEW_HEALTH_DATA) || (hr_data->head.key != PROTOCOL_KEY_NEW_HEALTH_DATA_ACTIVITY_DATA))
	{
		return SUCCESS;
	}



	if(hr_data->serial > PROTOCOL_ACTIVITY_DATA_MAX_PACKET_NUM)
	{
		return ERROR_INVALID_DATA;
	}

	if(hr_data->length > PROTOCOL_ACTIVITY_DATA_MAX_PACKET_LENGTH)
	{
		return ERROR_INVALID_LENGTH;
	}

	if(hr_data->serial == 0)	//同步完成
	{
		if(check_packet_data_and_exec() == false)	//校验错误,重新同步
		{
			//protocol_sync_activity_restart();
			app_timer_start(sync_timer,50,(uint32_t *)3);
		}
		else
		{
			//protocol_sync_activity_stop();
			app_timer_start(sync_timer,50,(uint32_t *)2);

			if(rx_packet_count != 0)		//继续同步
			{
				DEBUG_INFO("rx_packet_count =%d,need continue start",rx_packet_count);
				app_timer_start(delay_restart_timer,100,NULL);
				//protocol_sync_activity_start();
			}
			else
			{
				DEBUG_INFO("protocol_sync_activity_exec : VBUS_EVT_APP_ACTIVITY_SYNC_COMPLETE");
				vbus_tx_evt(VBUS_EVT_BASE_NOTICE_APP,VBUS_EVT_APP_ACTIVITY_SYNC_COMPLETE,&ret_code);
			}

		}

		return SUCCESS;
	}
	DEBUG_INFO("protocol_sync_activity_exec serial = %d,length = %d",hr_data->serial,hr_data->length);
	rx_packet_buf[hr_data->serial].serial = hr_data->serial;
	rx_packet_buf[hr_data->serial].length = hr_data->length;
	rx_packet_count ++;
	memcpy(rx_packet_buf[hr_data->serial].hr_data,data,PROTOCOL_TRANSPORT_MAX_SIZE);
	//重新启动定时器
	app_timer_stop(sync_timeout_timer);
	app_timer_start(sync_timeout_timer,5000,NULL);
	return SUCCESS;


}


uint32_t protocol_sync_activity_rx_data_reg(protocol_sync_activity_data_cb_t func)
{
	sync_activity_rx_data_handle = func;
	return SUCCESS;
}


uint32_t protocol_sync_cativity_get_packet_reg(protocol_sync_activiey_get_packet_count_t func)
{
	get_packet_count_handle = func;
	return SUCCESS;
}

static void sync_timer_handle(void *p)
{
	switch((uint32_t)p)
	{
	case 1 :
		protocol_sync_activity_start();
		break;
	case 2 :
		protocol_sync_activity_stop();
		break;
	case 3 :
		protocol_sync_activity_restart();
		break;
	}

}

static void sync_timeout_timer_handle(void *p)
{
	sync_is_start = false;
	uint32_t ret_code = SUCCESS;
	vbus_tx_evt(VBUS_EVT_BASE_NOTICE_APP,VBUS_EVT_APP_ACTIVITY_SYNC_TIMEOUT,&ret_code);
}

static void delay_restart_timer_handle(void *p)
{
	protocol_sync_activity_start();
}

uint32_t protocol_sync_activity_init()
{
	uint32_t err_code;
	rx_packet_count = 0;
	sync_is_start = false;

	err_code = app_timer_create(&sync_timer,sync_timer_handle)
	APP_ERROR_CHECK(err_code);
	err_code = app_timer_create(&sync_timeout_timer,sync_timeout_timer_handle);
	APP_ERROR_CHECK(err_code);

	err_code = app_timer_create(&delay_restart_timer,delay_restart_timer_handle);
	APP_ERROR_CHECK(err_code);
	return SUCCESS;
}

