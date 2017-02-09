/*
 * protocol_sync_activity.c
 *
 *  Created on: 2016年10月13日
 *      Author: Administrator
 */



#include "protocol.h"
#include "protocol_sync_activity.h"
#include "app_timer.h"
#include "protocol_write.h"

#define PROTOCOL_SYNC_ACTIVITY_COMPLETE_FLAG_SEND_END        0x00
#define PROTOCOL_SYNC_ACTIVITY_COMPLETE_FLAG_STOP            0x01

static struct activity_packet_data rx_packet_buf[PROTOCOL_ACTIVITY_DATA_MAX_PACKET_NUM + 2];
static protocol_sync_activiey_get_packet_count_t get_packet_count_handle = NULL;
static protocol_sync_activity_data_cb_t sync_activity_rx_data_handle = NULL;
static protocol_sync_activity_progress sync_activiy_progres_handle = NULL;
static volatile uint16_t rx_packet_count = 0;
static volatile bool sync_is_start = false;
static volatile uint16_t timeout_count = 0;
static volatile bool stop_cmd_timer_star = false;
static volatile uint16_t stop_cmd_time_count = 0;





static uint32_t sync_timer;
static uint32_t delay_restart_timer;
static uint32_t sync_timeout_timer;
static uint32_t stop_cmd_resend_timer ;

//计算百分比
static volatile uint8_t need_sync_count = 0;
static volatile uint8_t sync_data_count = 0;
static volatile bool is_get_data_count = false;


static uint32_t protocol_activity_write_data(const uint8_t *data,uint16_t length)
{
	return protocol_write_data(data,length);
}

static void send_get_count_cmd()
{
	struct protocol_head head;
	head.cmd = PROTOCOL_CMD_NEW_HEALTH_DATA;
	head.key = PROTOCOL_KEY_NEW_HEALTH_DATA_ACTIVITY_COUNT;
	protocol_write_data(&head, sizeof(head));

}


static void send_start_cmd()
{
	struct protocol_activity_head data;
	memset(&data,0,sizeof(data));
	memset(&rx_packet_buf,0,sizeof(rx_packet_buf));
	DEBUG_INFO("send_start_cmd");
	data.head.cmd = PROTOCOL_CMD_NEW_HEALTH_DATA;
	data.head.key = PROTOCOL_KEY_NEW_HEALTH_DATA_ACTIVITY_DATA;
	data.serial = 1;
	protocol_activity_write_data((uint8_t *)&data,sizeof(data));
}

static uint32_t send_stop_cmd(uint8_t flag)
{
	struct protocol_activity_hr_tx_complete data;
	memset(&data,0,sizeof(data));
	data.length = 1;
	data.flag = flag;
	data.serial = 0;

	data.head.cmd = PROTOCOL_CMD_NEW_HEALTH_DATA;
	data.head.key = PROTOCOL_KEY_NEW_HEALTH_DATA_ACTIVITY_DATA;
	protocol_activity_write_data((uint8_t *)&data,sizeof(data));
	return SUCCESS;
}

static void notice_sync_progress(uint8_t progress)
{
	if(progress > 100)
	{
		progress = 100;
	}
	DEBUG_INFO("sync activity progress = %d",progress);
	if(sync_activiy_progres_handle != NULL)
	{
		sync_activiy_progres_handle(progress);
	}

}

static uint32_t protocol_sync_activity_sync_next()
{
	send_start_cmd();
	sync_is_start = true;
	rx_packet_count = 0;
	timeout_count = 0;
	app_timer_start(sync_timeout_timer,5000,NULL);
    return SUCCESS;
}

uint32_t protocol_sync_activity_start()
{

	if(sync_is_start == true)
	{
		DEBUG_INFO("protocol_sync_activity_start is start");
		return SUCCESS;
	}

	is_get_data_count = true;
	send_get_count_cmd();
	app_timer_start(sync_timer,3000,(uint32_t *)4);

	app_timer_start(sync_timeout_timer,5000,NULL);

	return SUCCESS;
}

uint32_t protocol_sync_activity_stop()
{
	DEBUG_INFO("protocol_sync_activity_stop");
	struct protocol_activity_head data;
	memset(&data,0,sizeof(data));
	memset(&rx_packet_buf,0,sizeof(rx_packet_buf));
	send_stop_cmd(PROTOCOL_SYNC_ACTIVITY_COMPLETE_FLAG_STOP);
	sync_is_start = false;
	app_timer_stop(sync_timeout_timer);
	app_timer_stop(sync_timer);
	if(stop_cmd_timer_star == false)
	{
		stop_cmd_timer_star = true;
		stop_cmd_time_count = 0;
	}
	app_timer_start(stop_cmd_resend_timer,4000,NULL);
	is_get_data_count = false;
	return SUCCESS;
}

uint32_t protocol_sync_activity_restart()
{
	DEBUG_INFO("protocol_sync_activity_restart");
	send_start_cmd();
	sync_is_start = true;
	rx_packet_count = 0;
	app_timer_start(sync_timeout_timer,5000,NULL);
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


static void protocol_exec_get_count(const uint8_t *data,uint16_t length)
{
	struct protocol_head *head = (struct protocol_head *)data;
	if(head->cmd == PROTOCOL_CMD_NEW_HEALTH_DATA && (head->key == PROTOCOL_KEY_NEW_HEALTH_DATA_ACTIVITY_COUNT))
	{
		struct protocol_new_health_activity_count *activity_count = (struct protocol_new_health_activity_count *)data;
		need_sync_count = activity_count->count;
		if(is_get_data_count == true)
		{
			protocol_sync_activity_sync_next();
		}
		app_timer_stop(sync_timer);
	}
}

uint32_t protocol_sync_activity_exec(const uint8_t *data,uint16_t length)
{
	uint32_t ret_code = SUCCESS;
	struct protocol_activity_hr_data *hr_data = (struct protocol_activity_hr_data *)data;

	if(data == NULL)
	{
		return ERROR_NULL;
	}

	protocol_exec_get_count(data,length);

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
		struct protocol_activity_hr_tx_complete *complete_data = (struct protocol_activity_hr_tx_complete *) data;
		uint32_t r_err = SUCCESS;


		if (complete_data->flag == PROTOCOL_SYNC_ACTIVITY_COMPLETE_FLAG_STOP)    //停止命令响应
		{
			if (stop_cmd_timer_star == true) {
				stop_cmd_timer_star = false;
				app_timer_stop(stop_cmd_resend_timer);
			}
			return SUCCESS;
		}
		else if (complete_data->flag == PROTOCOL_SYNC_ACTIVITY_COMPLETE_FLAG_SEND_END)
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

				if(need_sync_count != 0)
				{
					notice_sync_progress(sync_data_count * 100 / need_sync_count);
				}
				sync_data_count ++;
				if(rx_packet_count != 0)		//继续同步
				{
					DEBUG_INFO("rx_packet_count =%d,need continue start",rx_packet_count);
					app_timer_start(delay_restart_timer,800,NULL);
					//protocol_sync_activity_start();
				}
				else
				{
					DEBUG_INFO("protocol_sync_activity_exec : VBUS_EVT_APP_ACTIVITY_SYNC_COMPLETE");
					vbus_tx_evt(VBUS_EVT_BASE_NOTICE_APP,VBUS_EVT_APP_ACTIVITY_SYNC_COMPLETE,&ret_code);
				}

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


uint32_t protocol_sync_activity_get_packet_reg(protocol_sync_activiey_get_packet_count_t func)
{
	get_packet_count_handle = func;
	return SUCCESS;
}

static void sync_timer_handle(void *p)
{
	switch((uint32_t)p)
	{
	case 1 :
		protocol_sync_activity_sync_next();
		break;
	case 2 :
		protocol_sync_activity_stop();
		break;
	case 3 :
		protocol_sync_activity_restart();
		break;
	case 4 :
		send_get_count_cmd();
		break;
	}

}

static void sync_timeout_timer_handle(void *p)
{
	DEBUG_INFO("sync_activity_timeout_timer_handle");
	uint32_t ret_code = SUCCESS;
	if (timeout_count > 3)
	{
		sync_is_start = false;
		vbus_tx_evt(VBUS_EVT_BASE_NOTICE_APP,VBUS_EVT_APP_ACTIVITY_SYNC_TIMEOUT,&ret_code);
		return ;
	}
	protocol_sync_activity_restart();
	timeout_count ++;

}

static void delay_restart_timer_handle(void *p)
{
	protocol_sync_activity_sync_next();
}

static void stop_cmd_re_send_timer_handle(void *p)
{
	DEBUG_INFO("stop_cmd_re_send_timer_handle");
	if(stop_cmd_time_count ++ > 3)
	{
		stop_cmd_timer_star = false;
		return ;
	}
	protocol_sync_activity_stop();
}

static uint32_t protocol_sync_activity_vbus_control(VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,void *data,uint32_t size,uint32_t *err_code)
{

	if (evt_base == VBUS_EVT_BASE_SET)
	{
		switch (evt_type)
		{
			case SET_BLE_EVT_DISCONNECT :
			{
				if(sync_is_start == true)
				{
					uint32_t ret_code = ERROR_INVALID_STATE;
					protocol_sync_activity_stop();
					stop_cmd_timer_star = false;
					app_timer_stop(stop_cmd_resend_timer);
					is_get_data_count = false;
					vbus_tx_evt(VBUS_EVT_BASE_NOTICE_APP, VBUS_EVT_APP_ACTIVITY_SYNC_COMPLETE,&ret_code);
				}

			}
				break;
		}
	}


	return SUCCESS;

}

static uint32_t protocol_sync_config_vbus_init()
{
	struct vbus_t vbus;
	uint32_t id;
	uint32_t err_code;
	vbus.control = protocol_sync_activity_vbus_control;
	vbus.name = "sync activity";
	err_code = vbus_reg(vbus,&id);
	APP_ERROR_CHECK(err);
	return SUCCESS;
}

uint32_t protocol_sync_activity_progress_reg(protocol_sync_activity_progress func)
{
	sync_activiy_progres_handle = func;
	return SUCCESS;
}

uint32_t protocol_sync_activity_init()
{
	uint32_t err_code;
	rx_packet_count = 0;
	sync_is_start = false;
	protocol_sync_config_vbus_init();
	err_code = app_timer_create(&sync_timer,sync_timer_handle)
	APP_ERROR_CHECK(err_code);
	err_code = app_timer_create(&sync_timeout_timer,sync_timeout_timer_handle);
	APP_ERROR_CHECK(err_code);

	err_code = app_timer_create(&delay_restart_timer,delay_restart_timer_handle);
	APP_ERROR_CHECK(err_code);

	err_code = app_timer_create(&stop_cmd_resend_timer,stop_cmd_re_send_timer_handle);
	APP_ERROR_CHECK(err_code);
	return SUCCESS;
}

