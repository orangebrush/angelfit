/*
 * protocol_util.c
 *
 *  Created on: 2016年1月21日
 *      Author: Administrator
 */

//辅助工具类,

#define DEBUG_STR "[PROTOCOL_UTIL]"

#include "include.h"
#include "protocol_util.h"


char *protocol_util_vbus_evt_to_str(VBUS_EVT_TYPE type)
{
    static char strbuf[100];
    switch (type) {
        case SET_BLE_EVT_CONNECT:
            return NAME_TO_STR(SET_BLE_EVT_CONNECT);
        case SET_BLE_EVT_DISCONNECT :
            return NAME_TO_STR(SET_BLE_EVT_DISCONNECT);
        case SYNC_EVT_ALRM_SYNC_COMPLETE :
            return NAME_TO_STR(SYNC_EVT_ALRM_SYNC_COMPLETE);
        case SYNC_EVT_CONFIG_SYNC_COMPLETE:
            return NAME_TO_STR(SYNC_EVT_CONFIG_SYNC_COMPLETE);
        case SYNC_EVT_HEALTH_SYNC_COMPLETE :
            return NAME_TO_STR(SYNC_EVT_HEALTH_SYNC_COMPLETE);
        case SYNC_EVT_HEALTH_PROGRESS :
            return NAME_TO_STR(SYNC_EVT_HEALTH_PROGRESS);
        case SYNC_EVT_ALARM_PROGRESS :
            return NAME_TO_STR(SYNC_EVT_ALARM_PROGRESS);
        case VBUS_EVT_APP_SET_ALARM:
            return NAME_TO_STR(VBUS_EVT_APP_SET_ALARM);
        case VBUS_EVT_APP_SET_LONG_SIT :
            return NAME_TO_STR(VBUS_EVT_APP_SET_LONG_SIT);
        case VBUS_EVT_APP_SET_LOST_FIND :
            return NAME_TO_STR(VBUS_EVT_APP_SET_LOST_FIND);
        case VBUS_EVT_APP_SET_FIND_PHONE :
            return NAME_TO_STR(VBUS_EVT_APP_SET_FIND_PHONE);
        case VBUS_EVT_APP_SET_TIME :
            return NAME_TO_STR(VBUS_EVT_APP_SET_TIME);
        case VBUS_EVT_APP_SET_SPORT_GOAL :
            return NAME_TO_STR(VBUS_EVT_APP_SET_SPORT_GOAL);
        case VBUS_EVT_APP_SET_SLEEP_GOAL :
            return NAME_TO_STR(VBUS_EVT_APP_SET_SLEEP_GOAL);
        case VBUS_EVT_APP_SET_USER_INFO :
            return NAME_TO_STR(VBUS_EVT_APP_SET_USER_INFO);
        case VBUS_EVT_APP_SET_UINT :
            return NAME_TO_STR(VBUS_EVT_APP_SET_UINT);
        case VBUS_EVT_APP_SET_HAND :
            return NAME_TO_STR(VBUS_EVT_APP_SET_HAND);
        case VBUS_EVT_APP_SET_APP_OS :
            return NAME_TO_STR(VBUS_EVT_APP_SET_APP_OS);
        case VBUS_EVT_APP_SET_NOTICE :
            return NAME_TO_STR(VBUS_EVT_APP_SET_NOTICE);
        case VBUS_EVT_APP_SET_HEART_RATE_INTERVAL :
            return NAME_TO_STR(VBUS_EVT_APP_SET_HEART_RATE_INTERVAL);
        case VBUS_EVT_APP_SET_HEART_RATE_MODE :
        	return NAME_TO_STR(VBUS_EVT_APP_SET_HEART_RATE_MODE);
        case VBUS_EVT_APP_SET_DEFAULT_CONFIG :
            return NAME_TO_STR(VBUS_EVT_APP_SET_DEFAULT_CONFIG);
        case VBUS_EVT_APP_BIND_START :
            return NAME_TO_STR(VBUS_EVT_APP_BIND_START);
        case VBUS_EVT_APP_BIND_REMOVE :
            return NAME_TO_STR(VBUS_EVT_APP_BIND_REMOVE);
        case VBUS_EVT_APP_BIND_CONFIRM :
            return NAME_TO_STR(VBUS_EVT_APP_BIND_CONFIRM);
        case VBUS_EVT_APP_APP_GET_MAC :
            return NAME_TO_STR(VBUS_EVT_APP_APP_GET_MAC);
        case VBUS_EVT_APP_GET_DEVICE_INFO :
            return NAME_TO_STR(VBUS_EVT_APP_GET_DEVICE_INFO);
        case VBUS_EVT_APP_GET_FUNC_TABLE :
            return NAME_TO_STR(VBUS_EVT_APP_GET_FUNC_TABLE);
        case VBUS_EVT_APP_GET_FUNC_TABLE_USER :
            return NAME_TO_STR(VBUS_EVT_APP_GET_FUNC_TABLE_USER);
        case VBUS_EVT_APP_OTA_START :
            return NAME_TO_STR(VBUS_EVT_APP_OTA_START);
        case VBUS_EVT_APP_OTA_DIRECT_START :
            return NAME_TO_STR(VBUS_EVT_APP_OTA_DIRECT_START);
        case VBUS_EVT_APP_SYSTEM_OFF :
            return NAME_TO_STR(VBUS_EVT_APP_SYSTEM_OFF);
        case VBUS_EVT_APP_REBOOT :
            return NAME_TO_STR(VBUS_EVT_APP_REBOOT);
        case VBUS_EVT_APP_APP_TO_BLE_MUSIC_START :
            return NAME_TO_STR(VBUS_EVT_APP_APP_TO_BLE_MUSIC_START);
        case VBUS_EVT_APP_APP_TO_BLE_MUSIC_STOP :
            return NAME_TO_STR(VBUS_EVT_APP_APP_TO_BLE_MUSIC_STOP);
        case VBUS_EVT_APP_APP_TO_BLE_PHOTO_START :
            return NAME_TO_STR(VBUS_EVT_APP_APP_TO_BLE_PHOTO_START);
        case VBUS_EVT_APP_APP_TO_BLE_PHOTO_STOP :
            return NAME_TO_STR(VBUS_EVT_APP_APP_TO_BLE_PHOTO_STOP);
        case VBUS_EVT_APP_APP_TO_BLE_FIND_DEVICE_START :
            return NAME_TO_STR(VBUS_EVT_APP_APP_TO_BLE_FIND_DEVICE_START);
        case VBUS_EVT_APP_APP_TO_BLE_FIND_DEVICE_STOP :
            return NAME_TO_STR(VBUS_EVT_APP_APP_TO_BLE_FIND_DEVICE_STOP);
        case VBUS_EVT_APP_APP_TO_BLE_OPEN_ANCS :
            return NAME_TO_STR(VBUS_EVT_APP_APP_TO_BLE_OPEN_ANCS);
        case VBUS_EVT_APP_SET_UP_HAND_GESTURE :
            return NAME_TO_STR(VBUS_EVT_APP_SET_UP_HAND_GESTURE);
        case SYNC_EVT_HEALTH_PROCESSING :
            return NAME_TO_STR(SYNC_EVT_HEALTH_PROCESSING);
        case SYNC_EVT_CONFIG_PROCESSING :
            return NAME_TO_STR(SYNC_EVT_CONFIG_PROCESSING);
        case SYNC_EVT_ALARM_PROCESSING :
            return NAME_TO_STR(SYNC_EVT_ALARM_PROCESSING);
        case VBUS_EVT_APP_GET_LIVE_DATA :
        	return NAME_TO_STR(VBUS_EVT_APP_GET_LIVE_DATA);
        case VBUS_EVT_APP_SET_NOTICE_CALL :
        	return NAME_TO_STR(VBUS_EVT_APP_SET_NOTICE_CALL);
        case VBUS_EVT_APP_SET_NOTICE_MSG :
        	return NAME_TO_STR(VBUS_EVT_APP_SET_NOTICE_MSG);
        case VBUS_EVT_APP_SET_DO_NOT_DISTURB :
        	return NAME_TO_STR(VBUS_EVT_APP_SET_DO_NOT_DISTURB);
        case VBUS_EVT_APP_SET_MUISC_ONOFF :
        	return NAME_TO_STR(VBUS_EVT_APP_SET_MUISC_ONOFF);
        case VBUS_EVT_APP_SET_DISPLAY_MODE :
        	return NAME_TO_STR(VBUS_EVT_APP_SET_DISPLAY_MODE);
        case VBUS_EVT_APP_SET_HR_SENSOR_PARAM :
        	return NAME_TO_STR(VBUS_EVT_APP_SET_HR_SENSOR_PARAM);
        case VBUS_EVT_APP_SET_GSENSOR_PARAM :
        	return NAME_TO_STR(VBUS_EVT_APP_SET_GSENSOR_PARAM);
        case VBUS_EVT_APP_SET_REAL_TIME_SENSOR_DATA :
        	return NAME_TO_STR(VBUS_EVT_APP_SET_REAL_TIME_SENSOR_DATA);
        case VBUS_EVT_APP_SET_START_MOTOT :
        	return NAME_TO_STR(VBUS_EVT_APP_SET_START_MOTOT);
        case VBUS_EVT_APP_BLE_TO_APP_SENSOR_DATA_NOTICE :
        	return NAME_TO_STR(VBUS_EVT_APP_BLE_TO_APP_SENSOR_DATA_NOTICE);
        case VBUS_EVT_APP_BLE_TO_APP_ONEKEY_SOS_START :
        	return NAME_TO_STR(VBUS_EVT_APP_BLE_TO_APP_ONEKEY_SOS_START);
        case VBUS_EVT_APP_SET_ONEKEY_SOS :
        	return NAME_TO_STR(VBUS_EVT_APP_SET_ONEKEY_SOS);
        case VBUS_EVT_APP_SET_NOTICE_STOP_CALL :
        	return NAME_TO_STR(VBUS_EVT_APP_SET_NOTICE_STOP_CALL);
        case VBUS_EVT_APP_GET_NOTICE_STATUS :
        	return NAME_TO_STR(VBUS_EVT_APP_GET_NOTICE_STATUS);
        case VBUS_EVT_APP_BLE_TO_APP_DEVICE_OPERATE :
         	return NAME_TO_STR(VBUS_EVT_APP_BLE_TO_APP_DEVICE_OPERATE);
        case VBUS_EVT_APP_PROTOCOL_TEST_CMD_1 :
            return NAME_TO_STR(VBUS_EVT_APP_PROTOCOL_TEST_CMD_1);

            
        default:
            
            snprintf(strbuf, sizeof(strbuf), "to string error , type = %d",type);
            return strbuf;
    }
    return "";
}


char *protocol_util_vbus_base_to_str(VBUS_EVT_BASE base)
{
    static char strbuf[100];
    switch(base)
    {
        case VBUS_EVT_BASE_SET :
            return NAME_TO_STR(VBUS_EVT_BASE_SET);
        case VBUS_EVT_BASE_GET :
            return NAME_TO_STR(VBUS_EVT_BASE_GET);
        case VBUS_EVT_BASE_BLE_REPLY :
            return NAME_TO_STR(VBUS_EVT_BASE_BLE_REPLY);
        case VBUS_EVT_BASE_NOTICE_APP :
            return NAME_TO_STR(VBUS_EVT_BASE_NOTICE_APP);
        case VBUS_EVT_BASE_APP_SET :
            return NAME_TO_STR(VBUS_EVT_BASE_APP_SET);
        case VBUS_EVT_BASE_APP_GET :
            return NAME_TO_STR(VBUS_EVT_BASE_APP_GET);
        case VBUS_EVT_BASE_REQUEST :
            return NAME_TO_STR(VBUS_EVT_BASE_REQUEST);
        default :
            snprintf(strbuf, sizeof(strbuf), "to string error ,type = %d",base);
            return strbuf;
    }
}

char *protocol_util_error_to_str(uint32_t error_code)
{
    static char strbuf[100];
    switch (error_code) {
        case SUCCESS:
            return NAME_TO_STR(SUCCESS);
            break;
        case ERROR_NO_MEM :
            return NAME_TO_STR(ERROR_NO_MEM);
        case ERROR_NOT_FIND :
            return NAME_TO_STR(ERROR_NOT_FIND);
        case ERROR_NOT_SUPPORTED :
            return NAME_TO_STR(ERROR_NOT_SUPPORTED);
        case ERROR_INVALID_PARAM :
            return NAME_TO_STR(ERROR_INVALID_PARAM);
        case ERROR_INVALID_STATE :
            return NAME_TO_STR(ERROR_INVALID_STATE);
        case ERROR_INVALID_LENGTH :
            return NAME_TO_STR(ERROR_INVALID_LENGTH);
        case ERROR_INVALID_FLAGS :
            return NAME_TO_STR(ERROR_INVALID_FLAGS);
        case ERROR_INVALID_DATA :
            return NAME_TO_STR(ERROR_INVALID_DATA);
        case ERROR_DATA_SIZE :
            return NAME_TO_STR(ERROR_DATA_SIZE);
        case ERROR_TIMEOUT :
            return NAME_TO_STR(ERROR_TIMEOUT);
        case ERROR_NULL :
            return NAME_TO_STR(ERROR_NULL);
        case ERROR_FORBIDDEN :
            return NAME_TO_STR(ERROR_FORBIDDEN);
        case ERROR_BUSY :
            return NAME_TO_STR(ERROR_BUSY);
        case ERROR_LOW_BATT :
            return NAME_TO_STR(ERROR_LOW_BATT);
        default:
            snprintf(strbuf, sizeof(strbuf), "not find string,errcode = %d",error_code);
            break;
    }
    return strbuf;
}

