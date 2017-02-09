/*
 * protocol.c
 *
 *  Created on: 2016年1月8日
 *      Author: Administrator
 */

//初始化和收发的接口


#define DEBUG_STR "[PROTOCOL]"

#include "protocol.h"
#include "protocol_exec.h"
#include "protocol_health.h"

#include "protocol_sync_config.h"
#include "protocol_set_alarm.h"
#include "protocol_write.h"
#include "protocol_health_resolve_sport.h"
#include "protocol_health_resolve_sleep.h"
#include "protocol_health_resolve_heart_rate.h"
#include "protocol_func_table.h"
#include "protocol_status.h"
#include "protocol_data.h"
#include "config.h"
#include "protocol_switch_data.h"
#include "protocol_sync_activity_resolve.h"
#include "protocol_sync_activity.h"

static protocol_write_data_handle write_data_handle = NULL;

static bool hook_receive_data(uint8_t const *data,uint16_t length)
{
#if 0
    if(data[0] == PROTOCOL_CMD_HEALTH_DATA && (data[1] == PROTOCOL_KEY_HEALTH_DATA_DAY_SPORT))
    {
        return true;
    }
#endif
    
#if 0
    if(data[0] == PROTOCOL_CMD_HEALTH_DATA && (data[1] == PROTOCOL_KEY_HEALTH_DATA_STOP))
    {
        return true;
    }
#endif
    
    
#if 0
    if(data[0] == PROTOCOL_CMD_SET && (data[1] == PROTOCOL_KEY_SET_USER_INFO))
    {
        return true;
    }
#endif
    
#if 0
    if(data[0] == PROTOCOL_CMD_SET && (data[1] == PROTOCOL_KEY_SET_ALARM))
    {
        return true;
    }
#endif
    
    return false;
}


static bool hook_write_data(uint8_t const *data,uint16_t length)
{
    return false;
}


uint32_t protocol_write_data(const uint8_t *data,uint16_t length)
{
    
    if(hook_write_data(data,length) == true)
    {
        return SUCCESS;
    }
    
    if(protoocl_get_mode() == PROTOCOL_MODE_OTA)
    {
        return ERROR_INVALID_STATE;
    }
    /*
    DEBUG_PRINT("TX : ");
    int i;
    for(i = 0; i < length ; i ++)
    {
        DEBUG_PRINT("%02X " ,data[i]);
    }
    DEBUG_PRINT("\r\n");
    */
	if(write_data_handle != NULL)
	{
		return write_data_handle(data,length);
	}

	return SUCCESS;
}


uint32_t protocol_receive_data(uint8_t const *data,uint16_t length)
{
    
    if(data == NULL)
{
        return SUCCESS;
    }
    if(hook_receive_data(data,length) == true)
    {
        return SUCCESS;
    }
    
    if(protoocl_get_mode() == PROTOCOL_MODE_OTA)
    {
        return ERROR_INVALID_STATE;
    }
    /*
    DEBUG_PRINT("RX : ");
    int i;
    for(i = 0; i < length ; i ++)
    {
        DEBUG_PRINT("%02X ",data[i]);
    }
    DEBUG_PRINT("\r\n");
    */
	if(data[0] == PROTOCOL_CMD_HEALTH_DATA)
	{
		return protocol_health_exec(data,length);
	}
	protocol_switch_exec(data,length);
	protocol_sync_activity_exec(data,length);
	return protocol_cmd_exec(data,length);
}


uint32_t protocol_init(protocol_write_data_handle func)
{
    DEBUG_INFO("Protocol Init");
    DEBUG_INFO("VERSION_MAJOR = %d,VERSION_MINOR=%d,VERSION_DATE=%d,VERSION_IS_RELEASE=%d",VERSION_MAJOR,VERSION_MINOR,VERSION_DATE,VERSION_IS_RELEASE);
	write_data_handle = func;
    vbus_init();

	protocol_write_init();
	protocol_sync_config_init();
	protocol_set_alarm_init();
	protocol_func_table_init();
	protocol_health_init();


	protocol_health_resolve_sport_init();
	protocol_health_resolve_sleep_init();
	protocol_health_resolve_heart_rate_init();
    
    protocol_status_init();
    protocol_switch_init();
    
    protocol_sync_activity_init();
    protocol_sync_activity_resolve_init();
    vbus_print_info();
	return SUCCESS;
}

uint32_t protocol_get_version(uint32_t *major,uint32_t *minor,uint32_t *date,bool *release)
{
    if(major != NULL)
    {
        *major = VERSION_MAJOR;
    }
    if(minor != NULL)
    {
        *minor = VERSION_MINOR;
    }
    if(date != NULL)
    {
        *date = VERSION_DATE;
    }
    if(release != NULL)
    {
        *release = (VERSION_IS_RELEASE != 0);
    }
    return SUCCESS;
}

uint32_t protocol_get_version_st(struct _protocol_version *version)
{
	if(version != NULL)
	{
		version->major = VERSION_MAJOR;
		version->minor = VERSION_MINOR;
		version->date = VERSION_DATE;
		version->release =  (VERSION_IS_RELEASE != 0);
		return SUCCESS;
	}
	return ERROR_NULL;
}

