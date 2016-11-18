/*
 * protocol_sync_config.c
 *
 *  Created on: 2016年1月8日
 *      Author: Administrator
 */

#define DEBUG_STR "[PROTOCOL_SYNC_CONFIG]"

#include "include.h"
#include "protocol_sync_config.h"
#include "protocol_func_table.h"
#include "protocol_set_alarm.h"
#include "app_timer.h"
#include "config.h"
/*
 * 同步配置信息过程
 * 1.蓝牙所有app发送给设备的命令，放入队列
 * 2.执行队列
 *
 * */

#define SYNC_CONFIG_TIME_OUT_MS		5000

static volatile bool sync_config_is_start = false;
static volatile bool need_sync_config = false;
static volatile uint16_t cur_sync_index = 0; //当前同步的索引

static uint32_t sync_timer_id;
static uint32_t delay_sync_timer_id;


#define SYNC_CONFIG_INIT_SUPPORT_TRUE(evt)      {evt,true,false}
#define SYNC_CONFIG_INIT_SUPPORT_FALSE(evt)     {evt,false,false}

struct sync_config_table_s
{
    VBUS_EVT_TYPE evt;
    bool is_support;
    bool is_sync;
};

static struct sync_config_table_s sync_config_evt_table[] = {

		/*必须要同步的,先获得设备信息,再同步配置*/
        SYNC_CONFIG_INIT_SUPPORT_TRUE(VBUS_EVT_APP_GET_DEVICE_INFO),
        SYNC_CONFIG_INIT_SUPPORT_TRUE(VBUS_EVT_APP_SET_TIME),
    
        /**/
        SYNC_CONFIG_INIT_SUPPORT_TRUE(VBUS_EVT_APP_GET_FUNC_TABLE),

        SYNC_CONFIG_INIT_SUPPORT_FALSE(VBUS_EVT_APP_APP_TO_BLE_OPEN_ANCS),
        SYNC_CONFIG_INIT_SUPPORT_TRUE(VBUS_EVT_APP_APP_GET_MAC),

    
		SYNC_CONFIG_INIT_SUPPORT_TRUE(VBUS_EVT_APP_SET_USER_INFO),
		SYNC_CONFIG_INIT_SUPPORT_TRUE(VBUS_EVT_APP_SET_UINT),
		SYNC_CONFIG_INIT_SUPPORT_TRUE(VBUS_EVT_APP_SET_SPORT_GOAL),

		/*根据功能表同步的*/
		SYNC_CONFIG_INIT_SUPPORT_FALSE(VBUS_EVT_APP_SET_LOST_FIND),
		SYNC_CONFIG_INIT_SUPPORT_FALSE(VBUS_EVT_APP_SET_LONG_SIT),
        SYNC_CONFIG_INIT_SUPPORT_FALSE(VBUS_EVT_APP_SET_FIND_PHONE),

        SYNC_CONFIG_INIT_SUPPORT_FALSE(VBUS_EVT_APP_SET_HEART_RATE_MODE),
        SYNC_CONFIG_INIT_SUPPORT_FALSE(VBUS_EVT_APP_SET_UP_HAND_GESTURE),
        SYNC_CONFIG_INIT_SUPPORT_FALSE(VBUS_EVT_APP_SET_DO_NOT_DISTURB),
        SYNC_CONFIG_INIT_SUPPORT_FALSE(VBUS_EVT_APP_SET_MUISC_ONOFF),
        SYNC_CONFIG_INIT_SUPPORT_FALSE(VBUS_EVT_APP_SET_DISPLAY_MODE),
        SYNC_CONFIG_INIT_SUPPORT_FALSE(VBUS_EVT_APP_SET_ONEKEY_SOS),

};

static uint32_t set_sync_timer_out(uint32_t ms)
{
	app_timer_stop(sync_timer_id);
	app_timer_start(sync_timer_id,ms,NULL);
    return SUCCESS;
}

static uint32_t stop_sync_timer_out()
{
	app_timer_stop(sync_timer_id);
    return SUCCESS;
}


uint32_t protocol_sync_config_set_func_table()
{
    struct protocol_func_table func_table;
    protocol_func_table_get(&func_table);
    int index = 0;
    for(index = 0; index < ARRAY_LEN(sync_config_evt_table); index ++)
    {
        
        switch (sync_config_evt_table[index].evt)
        {
            case VBUS_EVT_APP_SET_LOST_FIND:
                sync_config_evt_table[index].is_support = func_table.other.antilost;
                break;
            case VBUS_EVT_APP_SET_LONG_SIT :
                sync_config_evt_table[index].is_support = func_table.other.sedentariness;
                
                break;
            case VBUS_EVT_APP_APP_TO_BLE_OPEN_ANCS :
				#if PROTOCOL_ANDROID==1  //android 不支持
            	sync_config_evt_table[index].is_support = false;
				#else
                sync_config_evt_table[index].is_support = func_table.main.Ancs;
				#endif
                break;
            case VBUS_EVT_APP_SET_FIND_PHONE :
                sync_config_evt_table[index].is_support = func_table.other.findPhone;
                break;
            case VBUS_EVT_APP_SET_HEART_RATE_MODE :
            	sync_config_evt_table[index].is_support = func_table.ohter2.heartRateMonitor;
            	break;
            case VBUS_EVT_APP_SET_UP_HAND_GESTURE :
            	sync_config_evt_table[index].is_support = func_table.other.upHandGesture;

            	break;
            case VBUS_EVT_APP_SET_DO_NOT_DISTURB :
            	sync_config_evt_table[index].is_support = func_table.ohter2.doNotDisturb;
            	break;
            case VBUS_EVT_APP_SET_DISPLAY_MODE :
            	sync_config_evt_table[index].is_support = func_table.ohter2.displayMode;
            	break;
            case VBUS_EVT_APP_SET_ONEKEY_SOS :
            	sync_config_evt_table[index].is_support = func_table.other.onetouchCalling;
            	break;
            case VBUS_EVT_APP_SET_MUISC_ONOFF :
            	sync_config_evt_table[index].is_support = func_table.control.music;
            	break;
                
            default:
                break;
        }
    }
    
    return SUCCESS;
}

uint32_t protocol_sync_config_check()
{
    uint32_t err;
    DEBUG_INFO("protocol_sync_config_check");
    sync_config_is_start = true;
    need_sync_config = false;
    cur_sync_index = 0;
    set_sync_timer_out(SYNC_CONFIG_TIME_OUT_MS);
    //vbus_tx_evt(VBUS_EVT_BASE_REQUEST,sync_config_evt_table[cur_sync_index]);
    err = app_timer_start(delay_sync_timer_id,20,NULL);
    APP_ERROR_CHECK(err);
    return SUCCESS;
}


uint32_t protocol_sync_config_start()
{
	uint32_t err;
    DEBUG_INFO("sync config start ,cur status = %d",sync_config_is_start);
	if(sync_config_is_start == true)
	{
		return SUCCESS;
	}

	if(ARRAY_LEN(sync_config_evt_table) == 0)
	{
		return ERROR_NOT_SUPPORTED;
	}

	sync_config_is_start = true;
	cur_sync_index = 0;
    need_sync_config = true;
	set_sync_timer_out(SYNC_CONFIG_TIME_OUT_MS);
	//vbus_tx_evt(VBUS_EVT_BASE_REQUEST,sync_config_evt_table[cur_sync_index]);
	err = app_timer_start(delay_sync_timer_id,20,NULL);
	APP_ERROR_CHECK(err);
	return SUCCESS;
}

uint32_t protocol_sync_config_stop()
{
    app_timer_stop(delay_sync_timer_id);
	sync_config_is_start = false;
    stop_sync_timer_out();
	return SUCCESS;
}

bool protocol_sync_config_get_is_run()
{
	return sync_config_is_start;
}

static bool find_next_need_sync()
{
    int index;
    for(index = cur_sync_index; index < ARRAY_LEN(sync_config_evt_table); index ++)
    {
        if(sync_config_evt_table[index].is_support == true)
        {
            return true;
        }
    }
    
    return false;
}



static uint32_t protocol_sync_config_evt_handle(VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,void *data,uint32_t size,uint32_t *err_code)
{

	uint32_t err;
    uint32_t ret_code = SUCCESS;
	if(sync_config_is_start == false)
	{
		return SUCCESS;
	}

	if(evt_base == VBUS_EVT_BASE_BLE_REPLY)
	{
		if(evt_type == sync_config_evt_table[cur_sync_index - 1].evt)
		{
            set_sync_timer_out(SYNC_CONFIG_TIME_OUT_MS);
            if(need_sync_config == false) //检查信息
            {
                if(evt_type == VBUS_EVT_APP_APP_GET_MAC) //同步自动位置
                {
                    protocol_sync_config_stop(); //
                    return SUCCESS;
                }
            }
    
            
            //准备同步闹钟
            if(cur_sync_index >= ARRAY_LEN(sync_config_evt_table) || (find_next_need_sync() == false)) //列表同步完成
            {
                DEBUG_INFO("start sync config....,start sync alarm");
                set_sync_timer_out(20000);
                vbus_tx_evt(VBUS_EVT_BASE_REQUEST,VBUS_EVT_APP_SET_ALARM,&ret_code);
                protocol_set_alarm_start_sync();
            }
            else
            {
                set_sync_timer_out(SYNC_CONFIG_TIME_OUT_MS);
                err = app_timer_start(delay_sync_timer_id,20,NULL);
                APP_ERROR_CHECK(err);
            }
        

		}
	
	}else if(evt_base == VBUS_EVT_BASE_NOTICE_APP)
    {
        //闹钟同步完成,
        if((evt_type == SYNC_EVT_ALRM_SYNC_COMPLETE) && (sync_config_is_start == true))
        {
            protocol_sync_config_stop();
            vbus_tx_evt(VBUS_EVT_BASE_NOTICE_APP,SYNC_EVT_CONFIG_SYNC_COMPLETE,&ret_code);
            return SUCCESS;
        }
        //同步完成中出现同步错误
        if(sync_config_is_start == true)
        {
            uint32_t index;
            for(index = 0; index < ARRAY_LEN(sync_config_evt_table); index ++)
            {
                if((sync_config_evt_table[index].evt == evt_type) && (*err_code != SUCCESS))
                {
                    protocol_sync_config_stop();
                    vbus_tx_evt(VBUS_EVT_BASE_NOTICE_APP,SYNC_EVT_CONFIG_SYNC_COMPLETE,err_code);
                }
            }
        }
    }

	return SUCCESS;
}

static void sync_timer_handle(void *data)
{
    DEBUG_INFO("sync config time out,stop sync");
    protocol_sync_config_stop();
}

static void delay_sync_next_timer_handle()
{
	DEBUG_INFO("sync config index = %d,all = %d",cur_sync_index,(int)ARRAY_LEN(sync_config_evt_table));
    uint32_t ret_code = SUCCESS;
    uint32_t index;
    for(index = cur_sync_index; index < ARRAY_LEN(sync_config_evt_table); index ++)
    {
        if(sync_config_evt_table[index].is_support == true)
        {
            break;
        }
        else
        {
            cur_sync_index ++;
        }
    }
    
    vbus_tx_evt(VBUS_EVT_BASE_REQUEST,sync_config_evt_table[cur_sync_index].evt,&ret_code);
    
	cur_sync_index ++;

}

static uint32_t protocol_sync_config_vbus_control(VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,void *data,uint32_t size,uint32_t *err_code)
{
    uint32_t ret_code = SUCCESS;
    if(evt_base == VBUS_EVT_BASE_SET)
    {
        if(evt_type == SET_BLE_EVT_DISCONNECT) //断线后停止同步
        {
            protocol_sync_config_stop();
        }
    }
    else if(evt_base == VBUS_EVT_BASE_BLE_REPLY)
    {
        if(evt_type == VBUS_EVT_APP_GET_FUNC_TABLE)
        {
            struct protocol_get_func_table *func_table = (struct protocol_get_func_table *)data;
            DEBUG_INFO("update func table");
            protocol_func_table_set(func_table);
            vbus_tx_evt(VBUS_EVT_BASE_NOTICE_APP,VBUS_EVT_APP_GET_FUNC_TABLE_USER,&ret_code);
            protocol_sync_config_set_func_table();
        }
    }
    
    return SUCCESS;
}

static uint32_t protocol_sync_config_vbus_init()
{
    struct vbus_t vbus;
    uint32_t id;
    uint32_t err_code;
    vbus.control = protocol_sync_config_vbus_control;
    vbus.name = "protocol sync config";
    err_code = vbus_reg(vbus,&id);
    APP_ERROR_CHECK(err);
    return SUCCESS;
}

uint32_t protocol_sync_config_init()
{
	uint32_t id;
	uint32_t err;
	struct vbus_t dev;
	dev.name = "sync_config";
	dev.control = protocol_sync_config_evt_handle;
	vbus_reg(dev,&id);

	err = app_timer_create(&sync_timer_id,sync_timer_handle);
	if(err != SUCCESS)
		return err;
	err = app_timer_create(&delay_sync_timer_id,delay_sync_next_timer_handle);
	if(err != SUCCESS)
		return err;
    protocol_sync_config_vbus_init();
	return SUCCESS;
}

