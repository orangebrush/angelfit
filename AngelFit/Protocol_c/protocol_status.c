/*
 * protoocl_status.c
 *
 *  Created on: 2016年1月22日
 *      Author: Administrator
 */

//蓝牙连接后的自动流程


#include "include.h"
#include "protocol.h"
#include "protocol_sync_config.h"
#include "protocol_data.h"

static volatile bool reboot_sync_config_is_start = false;
static VBUS_EVT_TYPE photo_status;
static VBUS_EVT_TYPE music_status;
static VBUS_EVT_TYPE find_device_status;

static uint32_t protocol_status_alarm_vbus_control(VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,void *data,uint32_t size,uint32_t *error_code)
{
    if(evt_base == VBUS_EVT_BASE_BLE_REPLY)
    {
        switch (evt_type)
        {
            case VBUS_EVT_APP_GET_DEVICE_INFO:
                {
                    struct protocol_device_info *device_info = (struct protocol_device_info *)data;
                    if(device_info->reboot_flag == 0x01) //设备重启
                    {
                        
                        if(reboot_sync_config_is_start == true)
                        {
                            break;
                        }
                        
                        reboot_sync_config_is_start = true;
                        //开始同步所有配置
                        protocol_sync_config_stop();
                        DEBUG_INFO("device is reboot,start sync config");
                        protocol_sync_config_start();
                    }
                    else
                    {
                        DEBUG_INFO("device no reboot");
                    }
                }
                break;
            default:
                break;
        }
    }
    else if(evt_base == VBUS_EVT_BASE_SET)
    {
        switch (evt_type)
        {
            case SET_BLE_EVT_CONNECT:
            {
                if(protoocl_get_mode() == PROTOCOL_MODE_BIND)
                {
                    protocol_sync_config_check();
                }
                
                /* 每次连接成功以后，都需要设置时间，并且检查设备信息*/
            }
                break;
            case SET_BLE_EVT_DISCONNECT :
                reboot_sync_config_is_start = false;
                break;
                
            default:
                break;
        }
    }
    else if(evt_base == VBUS_EVT_BASE_NOTICE_APP)
    {
        if(evt_type == SYNC_EVT_CONFIG_SYNC_COMPLETE)
        {
            reboot_sync_config_is_start = false;
        }
    }
    
    return SUCCESS;
}


static uint32_t protocol_status_vbus_init()
{
    
    struct vbus_t status;
    uint32_t id;
    uint32_t err_code;
    status.control = protocol_status_alarm_vbus_control;
    status.name = "protocol status";
    err_code = vbus_reg(status,&id);
    APP_ERROR_CHECK(err);
    return SUCCESS;
}

uint32_t protocol_status_init()
{
    protocol_status_vbus_init();
    return SUCCESS;
}


void protocol_status_set_photo_status(VBUS_EVT_TYPE type)
{
	photo_status = type;
}

VBUS_EVT_TYPE protocol_status_get_photo_status()
{
	return photo_status;
}

void protocol_status_set_music_status(VBUS_EVT_TYPE type)
{
	music_status = type;
}

VBUS_EVT_TYPE protocol_status_get_music_status()
{
	return music_status;
}

void protocol_status_set_find_device_status(VBUS_EVT_TYPE type)
{
	find_device_status = type;
}

VBUS_EVT_TYPE protocol_status_get_find_device_status()
{
	return find_device_status;
}







