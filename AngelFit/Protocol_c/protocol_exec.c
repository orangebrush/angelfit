/*
 * protocol_exec.c
 *
 *  Created on: 2016年1月8日
 *      Author: Administrator
 */

//蓝牙命令解析器，不包含健康数据

#define DEBUG_STR "[PROTOCOL_EXEC]"

#include "protocol_exec.h"
#include "protocol_val.h"
#include "protocol_status.h"
static uint32_t protocol_exec_reset(uint8_t const *data,uint8_t size)
{
    
     struct protocol_head *head = (struct protocol_head *)data;
     uint32_t ret_code = SUCCESS;
     if(head->key == PROTOCOL_KEY_RESET_REBOOT)
     {
         vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY, VBUS_EVT_APP_REBOOT,data,size, &ret_code);
     }
    return SUCCESS;
}

static uint32_t protocol_exec_ota(uint8_t const *data,uint8_t size)
{
	uint32_t err_code = SUCCESS;
    uint32_t ret_code = SUCCESS;
    struct protocol_head *head = (struct protocol_head *)data;
    struct protocol_cmd *cmd = (struct protocol_cmd *)data;
    if(head->key == PROTOCOL_KEY_OTA_START)
    {
        
        if(cmd->cmd1 == PROTOCOL_VAL_OTA_SUCCESS)
        {
            err_code = vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_OTA_START,data,size,&ret_code);
        }
        else if(cmd->cmd1 == PROTOCOL_VAL_OTA_REPLY_LOW_BATT)
        {
            ret_code = ERROR_LOW_BATT;
            err_code = vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_OTA_START,data,size,&ret_code);
        }
        else if(cmd->cmd1 == PROTOCOL_VAL_OTA_REPLY_NOT_SUPPORT)
        {
            ret_code = ERROR_NOT_SUPPORTED;
            err_code = vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_OTA_START,data,size,&ret_code);
        }
    }
    else if(head->key == PROTOCOL_KEY_OTA_DIRECT_START)
    {
    	err_code = vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_OTA_DIRECT_START,data,size,SUCCESS);
    }
    return err_code;
}

static uint32_t protocol_exec_get(uint8_t const *data,uint32_t size)
{
	uint32_t err_code = SUCCESS;
    uint32_t ret_code = SUCCESS;
    struct protocol_head *head = (struct protocol_head *)data;
    switch(head->key)
    {
        case PROTOCOL_KEY_GET_DEVICE_INFO :
            {
                err_code = vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_GET_DEVICE_INFO,(void *)data,size,&ret_code);
            }
            break;
        case PROTOCOL_KEY_GET_FUNC_TALBE :
            {
            	err_code = vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_GET_FUNC_TABLE,(void *)data,size,&ret_code);
            }
            break;
        case PROTOCOL_KEY_GET_DEVICE_TIME :
            {
                err_code = vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_GET_DEVICE_TIME,(void *)data,size,&ret_code);
            }
            break;
        case PROTOCOL_KEY_GET_DEVICE_MAC :
            {
            	err_code = vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_APP_GET_MAC,(void *)data,size,&ret_code);
            }
            break;
        case PROTOCOL_KEY_GET_BATT_INFO :
            {

            }
            break;
        case PROTOCOL_KEY_GET_SN_INFO :
            {

            }
            break;
        case PROTOCOL_KEY_GET_LIVE_DATA :
            {
                err_code = vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY, VBUS_EVT_APP_GET_LIVE_DATA, (void *)data, size, &ret_code);
            }
            break;
        case PROTOCOL_KEY_GET_NOTICE_STATUS:
            {
                err_code = vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_GET_NOTICE_STATUS,(void *)data,size,&ret_code);
            }
            break;
        case PROTOCOL_KEY_GET_HEART_RATE_SENSOR_PARAM :
        	{
        		err_code = vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_GET_HR_SENSOR_PARAM,(void *)data,size,&ret_code);
        	}
        	break;
        case  PROTOCOL_KEY_GET_GSENSOR_PARAM :
        	{
        		err_code = vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_GET_GSENSOR_PARAM,(void *)data,size,&ret_code);
        	}
        	break;
    }

    return err_code;
}

static uint32_t protocol_exec_set(uint8_t const *data,uint32_t size)
{
	uint32_t err_code = SUCCESS;
    uint32_t ret_code = SUCCESS;
    struct protocol_head *head = (struct protocol_head *)data;
    switch(head->key)
    {
        case PROTOCOL_KEY_SET_DEVICE_TIME :
            {
               vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SET_TIME,data,size,&ret_code);
            }
            break;
        case PROTOCOL_KEY_SET_ALARM :
            {
               vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SET_ALARM,data,size,&ret_code);
            }
            break;
        case PROTOCOL_KEY_SET_SPORT_GOAL :
            {
               vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SET_SPORT_GOAL,data,size,&ret_code);
            }
            break;
        case PROTOCOL_KEY_SET_SLEEP_GOAL :
            {
               vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SET_SLEEP_GOAL,data,size,&ret_code);
            }
            break;
        case PROTOCOL_KEY_SET_USER_INFO :
            {
            	vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SET_USER_INFO,data,size,&ret_code);
            }
            break;
        case PROTOCOL_KEY_SET_UNIT :
            {
               vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SET_UINT,data,size,&ret_code);
            }
            break;
        case PROTOCOL_KEY_SET_LONG_SIT :
            {
               vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SET_LONG_SIT,data,size,&ret_code);
            }
            break;
        case PROTOCOL_KEY_SET_LOST_FIND :
            {
            	vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SET_LOST_FIND,data,size,&ret_code);

            }
            break;
        case PROTOCOL_KEY_SET_LOST_FIND_MODE :
            {

            }
            break;
		case PROTOCOL_KEY_SET_FIND_PHONE:
			{
                vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY, VBUS_EVT_APP_SET_FIND_PHONE,data,size, &ret_code);
			}
		break;
        case PROTOCOL_KEY_SET_HAND :
            {
               vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SET_HAND,data,size,&ret_code);
            }
            break;
        case PROTOCOL_KEY_SET_SYS_OS :
            {
            	vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SET_APP_OS,data,size,&ret_code);
            }
            break;
        case PROTOCOL_KEY_SET_NOTIF :
            {
               vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SET_NOTICE,data,size,&ret_code);

            }
            break;
		case PROTOCOL_KEY_SET_DEFAULT_CONFIG:
			{
				vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SET_DEFAULT_CONFIG,data,size,&ret_code);
			}
		break;
        case PROTOCOL_KEY_SET_HEART_RATE_INTERVAL :
       	   {
       		   vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SET_HEART_RATE_INTERVAL,data,size,&ret_code);
       	   }
        break;
        case PROTOCOL_KEY_SET_HEART_RATE_MODE :
            vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY, VBUS_EVT_APP_SET_HEART_RATE_MODE, data, size, &ret_code);
            break;
        case PROTOCOL_KEY_SET_UP_HAND_GESTURE :
            vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY, VBUS_EVT_APP_SET_UP_HAND_GESTURE, data, size, &ret_code);
            break;
        case PROTOCOL_KEY_SET_DO_NOT_DISTURB :
            vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY, VBUS_EVT_APP_SET_DO_NOT_DISTURB, data, size, &ret_code);
            break;
        case PROTOCOL_KEY_SET_MUISC_ONOFF :
            vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY, VBUS_EVT_APP_SET_MUISC_ONOFF, data, size, &ret_code);
            break;
        case PROTOCOL_KEY_SET_DISPLAY_MODE :
            vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY, VBUS_EVT_APP_SET_DISPLAY_MODE, data, size, &ret_code);
            break;
        case PROTOCOL_KEY_SET_HEART_SENSOR_PARAM :
        	vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SET_HR_SENSOR_PARAM,data,size,&ret_code);
        	break;
        case PROTOCOL_KEY_SET_GSENSOR_PARAM :
        	vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SET_GSENSOR_PARAM,data,size,&ret_code);
        	break;
        case PROTOCOL_KEY_SET_REAL_TIME_SENSOR_DATA :
        	vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SET_REAL_TIME_SENSOR_DATA,data,size,&ret_code);
        	break;
        case PROTOCOL_KEY_SET_START_MOTOR :
        	vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SET_START_MOTOT,data,size,&ret_code);
        	break;
        case PROTOCOL_KEY_SET_ONEKEY_SOS :
        	vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SET_ONEKEY_SOS,data,size,&ret_code);
        	break;
        case PROTOCOL_KEY_SET_SPORT_MODE_SELECT :
        	vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SET_SPORT_MODE_SELECT,data,size,&ret_code);
        	break;
        case PROTOCOL_KEY_SET_WEATHER_SWITCH :
        	vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SET_WEATHER_SWITCH,data,size,&ret_code);
        	break;
    
    }

    return err_code;
}


static uint32_t protocol_exec_bind(uint8_t const *data,uint32_t size)
{
	uint32_t err_code = SUCCESS;
    uint32_t ret_code = SUCCESS;
    struct protocol_head *head = (struct protocol_head *)data;
    switch(head->key)
    {
        case PROTOCOL_KEY_BIND_ENABLE :
            DEBUG_INFO("app request bind");
            vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_BIND_START,data,size,&ret_code);

            break;
        case PROTOCOL_KEY_BIND_DISENABLE :
            DEBUG_INFO("app bind remove");
            vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_BIND_REMOVE,data,size,&ret_code);
            break;
    }
    return err_code;
}



static uint32_t protocol_exec_control(uint8_t const *data,uint32_t size)
{
	uint32_t err_code = SUCCESS;
    uint32_t ret_code = SUCCESS;
    struct protocol_head *head = (struct protocol_head *)data;
    switch(head->key)
    {
        case PROTOCOL_KEY_CONTROL_MUSIC :
            {
                struct protocol_cmd *cmd = (struct protocol_cmd *)data;
                /*
                if(cmd->cmd1 == PROTOCOL_VAL_APP_CONTROL_MUSIC_START) //进入音乐
                {
                    err_code = vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_APP_TO_BLE_MUSIC_START,data,size,&ret_code);
                }
                else if(cmd->cmd1 == PROTOCOL_VAL_APP_CONTROL_MUSIC_STOP) //退出
                {
                    err_code = vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_APP_TO_BLE_MUSIC_STOP,data,size,&ret_code);
                }
                */

                if((protocol_status_get_music_status() == VBUS_EVT_APP_APP_TO_BLE_MUSIC_START) || (protocol_status_get_music_status() == VBUS_EVT_APP_APP_TO_BLE_MUSIC_STOP))
                {
                	err_code = vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,protocol_status_get_music_status(),data,size,&ret_code);
                }

            }
            break;
        case PROTOCOL_KEY_CONTROL_PHOTO :
            {
                struct protocol_cmd *cmd = (struct protocol_cmd *)data;
                /*
                if(cmd->cmd1 == 0x00) //进入拍照
                {
                    err_code = vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_APP_TO_BLE_PHOTO_START,data,size,&ret_code);

                }else if(cmd->cmd1 == 0x01) //退出拍照
                {
                    err_code = vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_APP_TO_BLE_PHOTO_STOP,data,size,&ret_code);
                }
                */
                if((protocol_status_get_photo_status() == VBUS_EVT_APP_APP_TO_BLE_PHOTO_START) || (protocol_status_get_photo_status() == VBUS_EVT_APP_APP_TO_BLE_PHOTO_STOP))
                {
                	err_code = vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,protocol_status_get_photo_status(),data,size,&ret_code);
                }
            }
            break;
        case PROTOCOL_KEY_CONTROL_SINGLE_SPORT :
            {
                //struct protocol_cmd *cmd = (struct protocol_cmd *)data;

            }
            break;
        case PROTOCOL_KEY_CONTROL_FIND_DEVICE :
            {
                struct protocol_cmd *cmd = (struct protocol_cmd *)data;
                if(protocol_status_get_find_device_status() == VBUS_EVT_APP_APP_TO_BLE_FIND_DEVICE_START || (protocol_status_get_find_device_status() == VBUS_EVT_APP_APP_TO_BLE_FIND_DEVICE_STOP))
                {
                	err_code = vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,protocol_status_get_find_device_status(),data,size,&ret_code);
                }
                /*
                if(cmd->cmd1 == 0x00) //进入
                {
                    vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_APP_TO_BLE_FIND_DEVICE_START,data,size,&ret_code);

                }else if(cmd->cmd1 == 0x01)
                {
                    vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_APP_TO_BLE_FIND_DEVICE_STOP,data,size,&ret_code);
                }
                 */
            }
            break;
         case PROTOCOL_KEY_CONTROL_OPEN_ANCS :
            {
                vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_APP_TO_BLE_OPEN_ANCS,data,size,&ret_code);
            }
             break;
         case PROTOCOL_KEY_CONTROL_CLOSE_ANCS :
            {
                vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_APP_TO_BLE_CLOSE_ANCS,data,size,&ret_code);
            }
             break;
    }

    return err_code;

}

static uint32_t protocol_exec_ble_control(uint8_t const *data,uint32_t size)
{
    struct protocol_head *head = (struct protocol_head *)data;
    struct protocol_cmd *cmd = (struct protocol_cmd *)data;
    uint32_t err_code = SUCCESS;
    uint32_t ret_code = SUCCESS;
    if(head->key == PROTOCOL_KEY_BLE_CONTROL_EVT)
    {
        vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY, VBUS_EVT_APP_BLE_TO_APP_EVT_BASE + cmd->cmd1,data,size, &ret_code);
    }
    else if(head->key == PROTOCOL_KEY_BLE_CONTROL_FIND_PHONE)
    {
        vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY, VBUS_EVT_APP_BLE_TO_APP_FIND_PHONE_START,data,size, &ret_code);
    }
    else if(head->key == PROTOCOL_KEY_BLE_CONTROL_ONEKEY_SOS)
    {
    	vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_BLE_TO_APP_ONEKEY_SOS_START,data,size,&ret_code);
    }
    else if(head->key == PROTOCOL_KEY_BLE_CONTROL_LOST_FIND)
    {
        vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY, VBUS_EVT_APP_BLE_TO_APP_ANTI_LOST_START,data,size, &ret_code);
    }
    else if(head->key == PROTOCOL_KEY_BLE_CONTORL_SENSOR_NOTCIE)
    {
    	vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_BLE_TO_APP_SENSOR_DATA_NOTICE,data,size,&ret_code);
    }
    else if(head->key == PROTOCOL_KEY_BLE_CONTORL_OPERATE)
    {
    	vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_BLE_TO_APP_DEVICE_OPERATE,data,size,&ret_code);
    }

    return err_code;
}


static uint32_t protocol_exec_weather(const uint8_t *data,uint32_t size)
{
	uint32_t ret_codes = SUCCESS;
	uint32_t err_code = SUCCESS;
	struct protocol_head *head = (struct protocol_head *)data;
	switch(head->key)
	{
	case PROTOCOL_KEY_WEATHER_SET_DATA :
		vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_WEATCHER_DATA,data,size,&ret_codes);
		break;
	}

	return err_code;

}

static uint32_t protocol_exec_msg(uint8_t const *data,uint32_t size)
{
	uint32_t err_code = SUCCESS;
	uint32_t ret_code = SUCCESS;
    struct protocol_head *head = (struct protocol_head *)data;
    switch(head->key)
    {
        case PROTOCOL_KEY_MSG_CALL :
            {
            	vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SET_NOTICE_CALL_PROCESSING,data,sizeof(data),&ret_code);
            }
            break;
        case PROTOCOL_KEY_MSG_CALL_STATUS :
            {
            	vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SET_NOTICE_STOP_CALL,data,sizeof(data),&ret_code);
            }
            break;
        case PROTOCOL_KEY_MSG_SMS :
            {
            	vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SET_NOTICE_MSG_PROCESSING,data,sizeof(data),&ret_code);

            }
            break;
		case PROTOCOL_KEY_MSG_UNREAD :
            {

            }
            break;
    }

    return err_code;
}


uint32_t protocol_cmd_exec( uint8_t const *data,uint16_t length)
{
	uint32_t err_code = SUCCESS;
	struct protocol_head *head = (struct protocol_head *)data;
    switch(head->cmd)
    {
        case PROTOCOL_CMD_OTA :
        	err_code = protocol_exec_ota(data,length);
            break;
        case PROTOCOL_CMD_GET :
        	err_code = protocol_exec_get(data,length);
            break;
        case PROTOCOL_CMD_SET :
        	err_code = protocol_exec_set(data,length);
            break;
        case PROTOCOL_CMD_BIND :
        	err_code = protocol_exec_bind(data,length);
            break;
        case PROTOCOL_CMD_MSG :
        	err_code = protocol_exec_msg(data,length);
            break;
        case PROTOCOL_CMD_APP_CONTROL :
        	err_code = protocol_exec_control(data,length);
            break;
        case PROTOCOL_CMD_WEATHER :
        	err_code = protocol_exec_weather(data,length);
        	break;
        case PROTOCOL_CMD_BLE_CONTROL :
        	err_code = protocol_exec_ble_control(data,length);
            break;

        case PROTOCOL_CMD_DUMP_STACK :
            break;
        case PROTOCOL_CMD_LOG :
           // protocol_exec_log(data,length);
            break;
        case PROTOCOL_CMD_TEST :
          //  protocol_exec_test_mode(data,length);
            break;
        case PROTOCOL_CMD_RESET :
            protocol_exec_reset(data,length);
            break;
    }

    return err_code;
}
