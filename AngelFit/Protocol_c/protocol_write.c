/*
 * protocol_write.c
 *
 *  Created on: 2016年1月8日
 *      Author: Administrator
 */
//写蓝牙命令在这里,不包含健康数据
#define DEBUG_STR "[PROTOCOL_WRITE]"

#include "protocol.h"
#include "protocol_val.h"
#include "protocol_write.h"
#include "vbus.h"
#include "mem.h"
#include "app_timer.h"
#include "protocol_status.h"

#define RESEND_TIMER_INTERVAL       2000
#define RESEND_TIMEOUT_COUNT_MAX    4	//最大重发4次
#define RESEND_BUF_SIZE				7	//最大缓存7个命令

struct re_send_data_s
{
    uint8_t m_resend_buf[PROTOCOL_TRANSPORT_MAX_SIZE];
    uint8_t m_resend_buf_length;
    VBUS_EVT_TYPE evt_type;
};

static volatile bool is_tx_ok = true;
static uint8_t re_tx_mem_id ;
static volatile uint8_t m_resend_count = 0;

static uint32_t send_timer_id;

static struct re_send_data_s m_re_send_data;

static uint32_t auto_re_send_data(uint8_t *data,uint8_t length,VBUS_EVT_TYPE evt_type)
{
    uint32_t err_code;
    memcpy(m_re_send_data.m_resend_buf,data,sizeof(m_re_send_data.m_resend_buf));
    m_re_send_data.m_resend_buf_length = length;
    m_re_send_data.evt_type = evt_type;
    protocol_write_data(data,length);
    is_tx_ok = false;
    err_code = app_timer_start(send_timer_id, RESEND_TIMER_INTERVAL, NULL);
    APP_ERROR_CHECK(err_code);
    
    return SUCCESS;
}

static uint32_t protocol_write_process()
{
    
    struct re_send_data_s get_data;
    
    if(is_tx_ok == false)
    {
        return SUCCESS;
    }
  
    if(mem_pop(re_tx_mem_id,&get_data) == true)
    {
        auto_re_send_data(get_data.m_resend_buf,get_data.m_resend_buf_length,get_data.evt_type);
    }
    return SUCCESS;
    
    
}

static void send_timer_handle(void *data)
{
    m_resend_count ++;
    if((m_resend_count > RESEND_TIMEOUT_COUNT_MAX) || (is_tx_ok == true))
    {
        
        if(m_resend_count > RESEND_TIMEOUT_COUNT_MAX) //发送超时
        {
            uint32_t ret_code = ERROR_TIMEOUT;
            vbus_tx_evt(VBUS_EVT_BASE_NOTICE_APP, m_re_send_data.evt_type, &ret_code);
        }
        
        m_resend_count = 0;
        is_tx_ok = true;
        protocol_write_process();
        return ;
    }
    app_timer_start(send_timer_id, RESEND_TIMER_INTERVAL, NULL);
    protocol_write_data(m_re_send_data.m_resend_buf,m_re_send_data.m_resend_buf_length);
}

static uint32_t protocol_write_data_add(uint8_t *data,uint8_t length,VBUS_EVT_TYPE evt_type)
{
    struct re_send_data_s  save_data;
    
    
    if(mem_isfull(re_tx_mem_id) == true) //发送队列满,丢弃旧的数据
    {
        mem_pop(re_tx_mem_id, &save_data);
    }
    
    memcpy(save_data.m_resend_buf,data,sizeof(save_data.m_resend_buf));
    save_data.m_resend_buf_length = length;
    save_data.evt_type = evt_type;
    
    mem_push(re_tx_mem_id, &save_data);
    protocol_write_process();
    return SUCCESS;
}

static uint32_t clean_resend_buf()
{
	uint8_t tmp_buf[sizeof(struct re_send_data_s)];
	for(;;)
	{
		if(mem_isempty(re_tx_mem_id) == true)
		{
			break;
		}
		mem_pop(re_tx_mem_id, tmp_buf);

	}
    
    return SUCCESS;

};

//这里的data 不能包含协议头
uint32_t protocol_write_set_cmd_key(uint8_t cmd,uint8_t key,const void *data,uint32_t size,bool need_resend,VBUS_EVT_TYPE evt_type)
{
	uint8_t data_buf[PROTOCOL_TX_MAX_SIZE] = {0};
	data_buf[0] = cmd;
	data_buf[1] = key;

	if(size > PROTOCOL_TX_MAX_SIZE)
	{
		DEBUG_INFO("write cmd ,size error > %d",PROTOCOL_TX_MAX_SIZE);
		return ERROR_DATA_SIZE;
	}

	if((data != NULL) && ( size >= 2))
	{
		memcpy(data_buf + 2,data,size - 2);
	}
    if(need_resend == true)
    {
        return protocol_write_data_add(data_buf,size,evt_type);
    }
	return protocol_write_data(data_buf,size);
}

uint32_t protocol_write_set_head(struct protocol_head head,const void *data,uint32_t size,bool need_resend,VBUS_EVT_TYPE evt_type)
{
	return protocol_write_set_cmd_key(head.cmd,head.key,data,size,need_resend,evt_type);
}

static uint32_t protocol_write_vbus_control(VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,void *data,uint32_t size,uint32_t *error_code)
{
	struct protocol_head head;
    struct protocol_cmd cmd;
    bool data_is_cmd = false;
    memset(&cmd,0, sizeof(cmd));
	if(evt_base == VBUS_EVT_BASE_SET)
	{
		switch(evt_type)
		{
		case VBUS_EVT_APP_SET_LONG_SIT :
			head.cmd = PROTOCOL_CMD_SET;
			head.key = PROTOCOL_KEY_SET_LONG_SIT;
			break;
		case VBUS_EVT_APP_SET_LOST_FIND :
			head.cmd = PROTOCOL_CMD_SET;
			head.key = PROTOCOL_KEY_SET_LOST_FIND;
			break;
		case VBUS_EVT_APP_SET_TIME :
			head.cmd = PROTOCOL_CMD_SET;
			head.key = PROTOCOL_KEY_SET_DEVICE_TIME;
			break;
		case VBUS_EVT_APP_SET_SPORT_GOAL :
			head.cmd = PROTOCOL_CMD_SET;
			head.key = PROTOCOL_KEY_SET_SPORT_GOAL;
			break;
		case VBUS_EVT_APP_SET_SLEEP_GOAL :
			head.cmd = PROTOCOL_CMD_SET;
			head.key = PROTOCOL_KEY_SET_SLEEP_GOAL;
			break;
		case VBUS_EVT_APP_SET_USER_INFO :
			head.cmd = PROTOCOL_CMD_SET;
			head.key = PROTOCOL_KEY_SET_USER_INFO;
			break;
		case VBUS_EVT_APP_SET_UINT :
			head.cmd = PROTOCOL_CMD_SET;
			head.key = PROTOCOL_KEY_SET_UNIT;
			break;
		case VBUS_EVT_APP_SET_HAND :
			head.cmd = PROTOCOL_CMD_SET;
			head.key = PROTOCOL_KEY_SET_HAND;
			break;
		case VBUS_EVT_APP_SET_APP_OS :
			head.cmd = PROTOCOL_CMD_SET;
			head.key = PROTOCOL_KEY_SET_SYS_OS;
			break;
		case VBUS_EVT_APP_SET_NOTICE :
			head.cmd = PROTOCOL_CMD_SET;
			head.key = PROTOCOL_KEY_SET_NOTIF;
			break;
		case VBUS_EVT_APP_SET_HEART_RATE_INTERVAL :
			head.cmd = PROTOCOL_CMD_SET;
			head.key = PROTOCOL_KEY_SET_HEART_RATE_INTERVAL;
			break;
		case VBUS_EVT_APP_SET_HEART_RATE_MODE :
			head.cmd = PROTOCOL_CMD_SET;
			head.key = PROTOCOL_KEY_SET_HEART_RATE_MODE;
			break;
		case VBUS_EVT_APP_SET_DEFAULT_CONFIG :
			head.cmd = PROTOCOL_CMD_SET;
			head.key = PROTOCOL_KEY_SET_DEFAULT_CONFIG;
			break;
		case VBUS_EVT_APP_BIND_START :
			head.cmd = PROTOCOL_CMD_BIND;
			head.key = PROTOCOL_KEY_BIND_ENABLE;
			break;
		case VBUS_EVT_APP_BIND_REMOVE :
			head.cmd = PROTOCOL_CMD_BIND;
			head.key = PROTOCOL_KEY_BIND_DISENABLE;
			break;
		case VBUS_EVT_APP_OTA_START :
			head.cmd = PROTOCOL_CMD_OTA;
			head.key = PROTOCOL_KEY_OTA_START;
			break;
		case VBUS_EVT_APP_OTA_DIRECT_START  :
			head.cmd = PROTOCOL_CMD_OTA;
			head.key = PROTOCOL_KEY_OTA_DIRECT_START;
			break;
		case VBUS_EVT_APP_SYSTEM_OFF :
			break;
		case VBUS_EVT_APP_REBOOT :
			head.cmd = PROTOCOL_CMD_RESET;
			head.key = PROTOCOL_KEY_RESET_REBOOT;
			break;
		case VBUS_EVT_APP_SET_ALARM :
			head.cmd = PROTOCOL_CMD_SET;
			head.key = PROTOCOL_KEY_SET_ALARM;
			break;
        case VBUS_EVT_APP_APP_TO_BLE_MUSIC_START :
            cmd.head.cmd = PROTOCOL_CMD_APP_CONTROL;
            cmd.head.key = PROTOCOL_KEY_CONTROL_MUSIC;
            cmd.cmd1 = PROTOCOL_VAL_APP_CONTROL_MUSIC_START;
            protocol_status_set_music_status(VBUS_EVT_APP_APP_TO_BLE_MUSIC_START);
            data_is_cmd = true;
            break;
        case VBUS_EVT_APP_APP_TO_BLE_MUSIC_STOP :
            cmd.head.cmd = PROTOCOL_CMD_APP_CONTROL;
            cmd.head.key = PROTOCOL_KEY_CONTROL_MUSIC;
            cmd.cmd1 = PROTOCOL_VAL_APP_CONTROL_MUSIC_STOP;
            protocol_status_set_music_status(VBUS_EVT_APP_APP_TO_BLE_MUSIC_STOP);
            data_is_cmd = true;
            break;
        case VBUS_EVT_APP_APP_TO_BLE_PHOTO_START :
            cmd.head.cmd = PROTOCOL_CMD_APP_CONTROL;
            cmd.head.key = PROTOCOL_KEY_CONTROL_PHOTO;
            cmd.cmd1 = PROTOCOL_VAL_APP_CONTROL_PHOTO_START;
            protocol_status_set_photo_status(VBUS_EVT_APP_APP_TO_BLE_PHOTO_START);
            data_is_cmd = true;
            break;
        case VBUS_EVT_APP_APP_TO_BLE_PHOTO_STOP :
            cmd.head.cmd = PROTOCOL_CMD_APP_CONTROL;
            cmd.head.key = PROTOCOL_KEY_CONTROL_PHOTO;
            cmd.cmd1 = PROTOCOL_VAL_APP_CONTROL_PHOTO_STOP;
            protocol_status_set_photo_status(VBUS_EVT_APP_APP_TO_BLE_PHOTO_STOP);
            data_is_cmd = true;
            break;
        case VBUS_EVT_APP_APP_TO_BLE_FIND_DEVICE_START :
            cmd.head.cmd = PROTOCOL_CMD_APP_CONTROL;
            cmd.head.key = PROTOCOL_KEY_CONTROL_FIND_DEVICE;
            cmd.cmd1 = PROTOCOL_VAL_APP_CONTROL_FIND_DEVICE_START;
            data_is_cmd = true;
            protocol_status_set_find_device_status(VBUS_EVT_APP_APP_TO_BLE_FIND_DEVICE_START);
            break;
        case VBUS_EVT_APP_APP_TO_BLE_FIND_DEVICE_STOP :
            cmd.head.cmd = PROTOCOL_CMD_APP_CONTROL;
            cmd.head.key = PROTOCOL_KEY_CONTROL_FIND_DEVICE;
            cmd.cmd1 = PROTOCOL_VAL_APP_CONTROL_FIND_DEVICE_STOP;
            data_is_cmd = true;
            protocol_status_set_find_device_status(VBUS_EVT_APP_APP_TO_BLE_FIND_DEVICE_STOP);
            break;
        case VBUS_EVT_APP_APP_TO_BLE_OPEN_ANCS :
            cmd.head.cmd = PROTOCOL_CMD_APP_CONTROL;
            cmd.head.key = PROTOCOL_KEY_CONTROL_OPEN_ANCS;
            data_is_cmd = true;
            break;
        case VBUS_EVT_APP_SET_UP_HAND_GESTURE:
            head.cmd = PROTOCOL_CMD_SET;
            head.key = PROTOCOL_KEY_SET_UP_HAND_GESTURE;
            break;
        case VBUS_EVT_APP_SET_FIND_PHONE :
            {
            struct protocol_find_phone *find_phone = (struct protocol_find_phone *)data;
            
            cmd.head.cmd = PROTOCOL_CMD_SET;
            cmd.head.key = PROTOCOL_KEY_SET_FIND_PHONE;
            cmd.cmd1 = find_phone->status;
            data_is_cmd = true;
            }
            break;
        case VBUS_EVT_APP_SET_DO_NOT_DISTURB :
            head.cmd = PROTOCOL_CMD_SET;
            head.key = PROTOCOL_KEY_SET_DO_NOT_DISTURB;
        break;
        case VBUS_EVT_APP_SET_MUISC_ONOFF :
            head.cmd = PROTOCOL_CMD_SET;
            head.key = PROTOCOL_KEY_SET_MUISC_ONOFF;
            break;
        case VBUS_EVT_APP_SET_DISPLAY_MODE :
            head.cmd = PROTOCOL_CMD_SET;
            head.key = PROTOCOL_KEY_SET_DISPLAY_MODE;
            break;
        case VBUS_EVT_APP_SET_HR_SENSOR_PARAM :
        	head.cmd = PROTOCOL_CMD_SET;
        	head.key = PROTOCOL_KEY_SET_HEART_SENSOR_PARAM;
        	break;
        case VBUS_EVT_APP_SET_GSENSOR_PARAM :
        	head.cmd = PROTOCOL_CMD_SET;
        	head.key = PROTOCOL_KEY_SET_GSENSOR_PARAM ;
        	break;
        case VBUS_EVT_APP_SET_REAL_TIME_SENSOR_DATA :
        	head.cmd = PROTOCOL_CMD_SET;
        	head.key = PROTOCOL_KEY_SET_REAL_TIME_SENSOR_DATA;
        	break;
        case VBUS_EVT_APP_SET_START_MOTOT:
        	head.cmd = PROTOCOL_CMD_SET;
        	head.key = PROTOCOL_KEY_SET_START_MOTOR;
        	break;
        case VBUS_EVT_APP_SET_ONEKEY_SOS :
        	head.cmd = PROTOCOL_CMD_SET;
        	head.key = PROTOCOL_KEY_SET_ONEKEY_SOS;
        	break;
        case VBUS_EVT_APP_SET_WEATHER_SWITCH :
        	head.cmd = PROTOCOL_CMD_SET;
        	head.key = PROTOCOL_KEY_SET_WEATHER_SWITCH;
        	break;
        case VBUS_EVT_APP_SET_SPORT_MODE_SELECT :
        	head.cmd = PROTOCOL_CMD_SET;
        	head.key = PROTOCOL_KEY_SET_SPORT_MODE_SELECT;
        	break;
        case VBUS_EVT_APP_WEATCHER_DATA :
        	head.cmd = PROTOCOL_CMD_WEATHER;
        	head.key = PROTOCOL_KEY_WEATHER_SET_DATA ;
        	break;
		
        case VBUS_EVT_APP_SET_NOTICE_STOP_CALL :
			cmd.head.cmd = PROTOCOL_CMD_MSG;
			cmd.head.key = PROTOCOL_KEY_MSG_CALL_STATUS;
			cmd.cmd1 = 0x01;
			data_is_cmd = true;
        	break;
        case SET_BLE_EVT_CONNECT :
            return SUCCESS;
        case SET_BLE_EVT_DISCONNECT : //断开连接
		{
			app_timer_stop(send_timer_id);
			is_tx_ok = true;
			m_resend_count = 0;
			clean_resend_buf();
		}
            return SUCCESS;
        case VBUS_EVT_APP_PROTOCOL_TEST_CMD_1 :
            head.cmd = 0xFF;
            head.key = 0x01;
            break;
		default :
			DEBUG_INFO("protocol write invalid evt, = %d",evt_type);
			return SUCCESS;

		}
        //对事件的长度进行修正
        if(size == 0)
        {
            size = sizeof(struct protocol_head);
        }
        
        if(data_is_cmd == true)
        {
            *error_code = protocol_write_set_head(cmd.head,((uint8_t *)&cmd) + 2,sizeof(struct protocol_cmd),true,evt_type);
        }
        else
        {
            if(data != NULL)
            {
                *error_code = protocol_write_set_head(head,((uint8_t *)data) + 2,size,true,evt_type);
            }
            else
            {
                *error_code = protocol_write_set_head(head,data,size,true,evt_type);
            }
        }
        


	}
	else if(evt_base == VBUS_EVT_BASE_GET)
	{
		switch(evt_type)
		{
		case VBUS_EVT_APP_APP_GET_MAC :
			head.cmd = PROTOCOL_CMD_GET;
			head.key = PROTOCOL_KEY_GET_DEVICE_MAC;
			break;
		case VBUS_EVT_APP_GET_DEVICE_INFO :
			head.cmd = PROTOCOL_CMD_GET;
			head.key = PROTOCOL_KEY_GET_DEVICE_INFO;
			break;
		case VBUS_EVT_APP_GET_FUNC_TABLE :
			head.cmd = PROTOCOL_CMD_GET;
			head.key = PROTOCOL_KEY_GET_FUNC_TALBE;
			break;
        case VBUS_EVT_APP_GET_LIVE_DATA :
            head.cmd = PROTOCOL_CMD_GET;
            head.key = PROTOCOL_KEY_GET_LIVE_DATA;
			*error_code = protocol_write_set_head(head,NULL,2,false,evt_type);
            return SUCCESS;
        case VBUS_EVT_APP_GET_NOTICE_STATUS :
        	head.cmd = PROTOCOL_CMD_GET;
        	head.key = PROTOCOL_KEY_GET_NOTICE_STATUS;
        	break;
        case VBUS_EVT_APP_GET_HR_SENSOR_PARAM :
        	head.cmd = PROTOCOL_CMD_GET;
        	head.key = PROTOCOL_KEY_GET_HEART_RATE_SENSOR_PARAM;
        	break;
        case VBUS_EVT_APP_GET_GSENSOR_PARAM :
        	head.cmd = PROTOCOL_CMD_GET ;
        	head.key = PROTOCOL_KEY_GET_GSENSOR_PARAM;
        	break;
				default :
			return SUCCESS;
		}
		*error_code = protocol_write_set_head(head,NULL,2,true,evt_type);
	}
    else if(evt_base == VBUS_EVT_BASE_BLE_REPLY)
    {
        struct protocol_head *rx_head = (struct protocol_head *)data;
        if((rx_head->cmd == m_re_send_data.m_resend_buf[0]) && (rx_head->key == m_re_send_data.m_resend_buf[1]))
        {
            DEBUG_INFO("find last send cmd,stop resend,evt = %s",protocol_util_vbus_evt_to_str(m_re_send_data.evt_type));
            app_timer_stop(send_timer_id);
            is_tx_ok = true;
            m_resend_count = 0;
            *error_code = protocol_write_process();
        }
        else
        {
            DEBUG_INFO("not find last cmd,evt= %s",protocol_util_vbus_evt_to_str(m_re_send_data.evt_type));
        }
    }

	return SUCCESS;
}



static uint32_t protocol_write_vbus_init()
{
	uint32_t err_code;
	struct vbus_t vbus_id;
	uint32_t id;
	vbus_id.name = "protocol write";
	vbus_id.control = protocol_write_vbus_control;
	err_code = vbus_reg(vbus_id,&id);
	APP_ERROR_CHECK(err_code);
    

	return err_code;
}


uint32_t protocol_write_init()
{
    uint32_t err_code;
    static uint8_t re_tx_buf[sizeof(struct re_send_data_s) * RESEND_BUF_SIZE];
	err_code = protocol_write_vbus_init();
    APP_ERROR_CHECK(error_code);
    mem_init(re_tx_buf,sizeof(re_tx_buf),sizeof(struct re_send_data_s),&re_tx_mem_id);
    err_code = app_timer_create(&send_timer_id, send_timer_handle);
    APP_ERROR_CHECK(err_code);
	return SUCCESS;
}
