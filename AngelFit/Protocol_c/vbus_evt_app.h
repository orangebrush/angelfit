/*
 * vbus_evt_app.h
 *
 *  Created on: 2016年1月8日
 *      Author: Administrator
 */
 

#ifndef VBUS_EVT_APP_H_
#define VBUS_EVT_APP_H_

//事件的方向
typedef enum
{
	VBUS_EVT_BASE_SET 			= 0x2000,  //内部使用
	VBUS_EVT_BASE_GET 			= 0x2100,
	VBUS_EVT_BASE_BLE_REPLY 	= 0x2200, //内部使用
	VBUS_EVT_BASE_NOTICE_APP 	= 0x2300, //通知
	VBUS_EVT_BASE_APP_SET 		= 0x2400, //设置
	VBUS_EVT_BASE_APP_GET   	= 0x2500,//获取
	VBUS_EVT_BASE_REQUEST		= 0x2600 // C库请求

}VBUS_EVT_BASE;

typedef enum {
    VBUS_EVT_NONE,
	SET_BLE_EVT_CONNECT = 1, 			//连接成功
	SET_BLE_EVT_DISCONNECT, 		    //断开连接
	SYNC_EVT_ALRM_SYNC_COMPLETE,		//闹钟同步完成
	SYNC_EVT_CONFIG_SYNC_COMPLETE,		//配置同步完成
	SYNC_EVT_HEALTH_SYNC_COMPLETE,		//健康数据同步完成

	SYNC_EVT_HEALTH_PROGRESS,			//健康数据同步进度,进度在data (0-100) (uint32_t)data
	SYNC_EVT_ALARM_PROGRESS,			//闹钟同步进度 struct protocol_set_alarm_progress_s
    
    SYNC_EVT_HEALTH_PROCESSING,
    SYNC_EVT_ALARM_PROCESSING,
    SYNC_EVT_CONFIG_PROCESSING,
	SYNC_EVT_CONFIG_FAST_SYNC_COMPLETE,		//连接以后,快速同步完成
	SYNC_EVT_ACTIVITY_STOP_ONCE,				//中间状态	重发控制
	SYNC_EVT_ACTIVITY_START_ONCE,

	VBUS_EVT_APP_SET_ALARM  = 100,		//设置闹钟
	VBUS_EVT_APP_SET_LONG_SIT ,			//设置久坐 struct protocol_long_sit
	VBUS_EVT_APP_SET_LOST_FIND ,		//设置防丢 struct protocol_lost_find
	VBUS_EVT_APP_SET_FIND_PHONE,		//设置寻找手机 struct protocol_find_phone
	VBUS_EVT_APP_SET_TIME,				//设置时间 struct protocol_set_time
	VBUS_EVT_APP_SET_SPORT_GOAL,		//设置运动目标 struct protocol_set_sport_goal
	VBUS_EVT_APP_SET_SLEEP_GOAL,
	VBUS_EVT_APP_SET_USER_INFO,			//设置用户信息 struct protocol_set_user_info
	VBUS_EVT_APP_SET_UINT,				//设置单位 struct protocol_set_uint
	VBUS_EVT_APP_SET_HAND,				//设置左右手 struct protocol_set_handle
	VBUS_EVT_APP_SET_APP_OS,			//110
	VBUS_EVT_APP_SET_NOTICE,			//设置通知中心 struct protocol_set_notice
	VBUS_EVT_APP_SET_HEART_RATE_INTERVAL,	//设置心率 struct protocol_heart_rate_interval
    VBUS_EVT_APP_SET_HEART_RATE_MODE,       //心率模式 struct protocol_heart_rate_mode
    VBUS_EVT_APP_SET_UP_HAND_GESTURE,       //抬手 struct protocol_set_up_hand_gesture
	VBUS_EVT_APP_SET_DEFAULT_CONFIG,		//恢复模式设置
    VBUS_EVT_APP_SET_DO_NOT_DISTURB,           //勿扰模式 protocol_do_not_disturb
    VBUS_EVT_APP_SET_MUISC_ONOFF,            //音乐开关 struct protocol_music_onoff
    VBUS_EVT_APP_SET_DISPLAY_MODE,           //显示模式 struct protocol_display_mode
    VBUS_EVT_APP_SET_ONEKEY_SOS,			 //设置一键呼叫 struct protocol_set_onekey_sos

    VBUS_EVT_APP_SET_HR_SENSOR_PARAM,		 //设置心率传感器参数 struct protocol_heart_rate_sensor_param
    VBUS_EVT_APP_SET_GSENSOR_PARAM,			//设置加速度传感器参数 struct protocol_gsensor_param
    VBUS_EVT_APP_SET_REAL_TIME_SENSOR_DATA,	//设置传感器实时数据 struct protocol_set_real_time_health_data_status
    VBUS_EVT_APP_SET_START_MOTOT,			//设置马达 struct protocol_set_start_motor
    VBUS_EVT_APP_SET_WEATHER_SWITCH  = 150,		//设置开关	struct protocol_cmd,cmd1
    VBUS_EVT_APP_SET_SPORT_MODE_SELECT,		//设置运动模式选择    protocol_sport_mode_select_bit或者 struct protocol_sport_mode_select

    VBUS_EVT_APP_WEATCHER_DATA,				//设置天气数据  struct protocol_weatch_data



	VBUS_EVT_APP_BIND_START = 200,			//绑定
	VBUS_EVT_APP_BIND_REMOVE,				//解绑
	VBUS_EVT_APP_BIND_CONFIRM,				//绑定确认

	VBUS_EVT_APP_APP_GET_MAC = 300,			//获得mac struct protocol_device_mac
	VBUS_EVT_APP_GET_DEVICE_INFO,			//获得设备信息 struct protocol_device_info
    
	VBUS_EVT_APP_GET_FUNC_TABLE,			//(内部使用)
    VBUS_EVT_APP_GET_FUNC_TABLE_USER,       //获取功能表 struct protocol_get_func_table
    VBUS_EVT_APP_GET_LIVE_DATA,             //获得实时数据 struct protocol_start_live_data
    VBUS_EVT_APP_GET_DEVICE_TIME,           //获取设备时间 struct protocol_device_time
    VBUS_EVT_APP_GET_NOTICE_STATUS,         //获取通知中心的状态 struct protocol_set_notice_ack
    
    VBUS_EVT_APP_GET_HR_SENSOR_PARAM,		//获取心率传感器参数 struct protocol_heart_rate_sensor_param
    VBUS_EVT_APP_GET_GSENSOR_PARAM,			//加速度传感器  struct protocol_gsensor_param

    
	VBUS_EVT_APP_OTA_START = 400,			//进入升级模式
	VBUS_EVT_APP_OTA_DIRECT_START,			//直接进入升级模式(忽略电量)
	VBUS_EVT_APP_SYSTEM_OFF,				//进入关机模式
	VBUS_EVT_APP_REBOOT,					//重启设备
    
    
    VBUS_EVT_APP_SET_NOTICE_CALL = 410,           //发送来电事件，android
    VBUS_EVT_APP_SET_NOTICE_MSG,            //通知app
    VBUS_EVT_APP_SET_NOTICE_STOP_CALL,		//结束来电

    VBUS_EVT_APP_SET_NOTICE_CALL_PROCESSING, //处理中,内部事件
    VBUS_EVT_APP_SET_NOTICE_MSG_PROCESSING,
    //app控制手环
    VBUS_EVT_APP_APP_TO_BLE_MUSIC_START = 500,        //开始
    VBUS_EVT_APP_APP_TO_BLE_MUSIC_STOP,         //停止
	VBUS_EVT_APP_APP_TO_BLE_PHOTO_START,       //开始拍照
	VBUS_EVT_APP_APP_TO_BLE_PHOTO_STOP,        //结束拍照
	VBUS_EVT_APP_APP_TO_BLE_FIND_DEVICE_START, //寻找设备
	VBUS_EVT_APP_APP_TO_BLE_FIND_DEVICE_STOP,  
	VBUS_EVT_APP_APP_TO_BLE_OPEN_ANCS,
    VBUS_EVT_APP_APP_TO_BLE_CLOSE_ANCS,
    
    //手环控制app
    VBUS_EVT_APP_BLE_TO_APP_EVT_BASE = 550,
    VBUS_EVT_APP_BLE_TO_APP_MUSIC_START,        //开始
    VBUS_EVT_APP_BLE_TO_APP_MUSIC_PAUSE,        //暂停
    VBUS_EVT_APP_BLE_TO_APP_MUSIC_STOP,         //停止
    VBUS_EVT_APP_BLE_TO_APP_MUSIC_LAST,         //上一首
    VBUS_EVT_APP_BLE_TO_APP_MUSIC_NEXT,         //下一首
    VBUS_EVT_APP_BLE_TO_APP_PHOTO_SINGLE_SHOT,  //单拍
    VBUS_EVT_APP_BLE_TO_APP_PHOTO_BURST,        //连拍
    VBUS_EVT_APP_BLE_TO_APP_VOLUME_UP,          //音量+
    VBUS_EVT_APP_BLE_TO_APP_VOLUME_DOWN,        //音量-
	VBUS_EVT_APP_BLE_TO_APP_OPEN_CAMERA,		//打开相机
	VBUS_EVT_APP_BLE_TO_APP_CLOSE_CAMERA,		//关闭相机
	VBUS_EVT_APP_BLE_TO_APP_PHONE_ANSWER,		//接听电话
	VBUS_EVT_APP_BLE_TO_APP_PHONE_REJECT,		//拒接电话
    
    VBUS_EVT_APP_BLE_TO_APP_FIND_PHONE_START = 570,   //寻找手机开始
    VBUS_EVT_APP_BLE_TO_APP_FIND_PHONE_STOP,    //寻找手机结束
    
    VBUS_EVT_APP_BLE_TO_APP_ANTI_LOST_START,    //防丢启动
    VBUS_EVT_APP_BLE_TO_APP_ANTI_LOST_STOP,     //防丢结束
    VBUS_EVT_APP_BLE_TO_APP_ONEKEY_SOS_START,		//一键
    VBUS_EVT_APP_BLE_TO_APP_SENSOR_DATA_NOTICE,	//传感器数据通知 struct protocol_sensor_data_notice
    VBUS_EVT_APP_BLE_TO_APP_DEVICE_OPERATE,		//设备操作  struct protocol_device_operate


    //交换数据
    VBUS_EVT_APP_SWITCH_APP_STAERT  = 600,				//app发送开始 struct protocol_switch_app_start
    VBUS_EVT_APP_SWITCH_APP_START_REPLY,		//app 开始应答	struct protocol_switch_app_start_reply
    VBUS_EVT_APP_SWITCH_APP_ING,				//交换过程中	struct protocol_switch_app_ing
    VBUS_EVT_APP_SWITCH_APP_ING_REPLY,			//交换应答	struct protocol_switch_app_ing_reply
    VBUS_EVT_APP_SWITCH_APP_END,				//结束		struct protocol_switch_app_end
    VBUS_EVT_APP_SWITCH_APP_END_REPLY,			//struct protocol_switch_app_end_reply
    VBUS_EVT_APP_SWITCH_APP_PAUSE,				//struct protocol_switch_app_pause
    VBUS_EVT_APP_SWITCH_APP_PAUSE_REPLY,		//struct protocol_switch_app_pause_reply
    VBUS_EVT_APP_SWITCH_APP_RESTORE,			//struct protocol_switch_app_restore
    VBUS_EVT_APP_SWITCH_APP_RESTORE_REPLY,		//struct protocol_switch_app_restore_reply
	VBUS_EVT_APP_SWITCH_APP_BLE_PAUSE,				//struct protocol_switch_app_ble_pause
	VBUS_EVT_APP_SWITCH_APP_BLE_PAUSE_REPLY,		//struct protocol_switch_app_ble_pause_reply
	VBUS_EVT_APP_SWITCH_APP_BLE_RESTORE,			//struct protocol_switch_app_ble_restore
	VBUS_EVT_APP_SWITCH_APP_BLE_RESTORE_REPLY,	//struct protocol_switch_app_ble_restore_reply
	VBUS_EVT_APP_SWITCH_APP_BLE_END,				//struct struct protocol_switch_app_ble_end
	VBUS_EVT_APP_SWITCH_APP_BLE_END_REPLY,		//struct struct protocol_switch_app_ble_end_reply


    VBUS_EVT_APP_SWITCH_BLE_START = 620,				//ble 发送	struct protocol_switch_ble_start
    VBUS_EVT_APP_SWITCH_BLE_START_REPLY,		//ble 发送应答	struct protocol_switch_ble_start_reply
    VBUS_EVT_APP_SWITCH_BLE_ING,				//交换过程中	struct protocol_switch_ble_ing
    VBUS_EVT_APP_SWITCH_BLE_ING_REPLY,			//		struct protocol_switch_ble_ing_reply
    VBUS_EVT_APP_SWITCH_BLE_END,				//结束	struct protocol_switch_ble_end
    VBUS_EVT_APP_SWITCH_BLE_END_REPLY,
    VBUS_EVT_APP_SWITCH_BLE_PAUSE,				//struct protocol_switch_ble_pause
    VBUS_EVT_APP_SWITCH_BLE_PAUSE_REPLY,		//struct protocol_switch_ble_pause_reply
    VBUS_EVT_APP_SWITCH_BLE_RESTORE,			//struct protocol_switch_ble_restore
    VBUS_EVT_APP_SWITCH_BLE_RESTORE_REPLY,		//struct protocol_switch_ble_restore_reply


    //新的同步项
    VBUS_EVT_APP_ACTIVITY_SYNC_TIMEOUT = 650,				//活动项同步超时
    VBUS_EVT_APP_ACTIVITY_SYNC_COMPLETE,					//所有活动项目同步完成
    VBUS_EVT_APP_ACTIVITY_SYNC_ONCE_COMPLETE_JSON_NOTEICE,  //单次数据同步完成通知,android 使用


	VBUS_EVT_APP_PROTOCOL_TEST_CMD_1   = 700, //内部测试

	//ibecon
	VBUS_EVT_IBEACON_WRITE_HEAD	= 1000,				//struct protocol_beacon_head_set
	VBUS_EVT_IBEACON_WRITE_HEAD_REPLY,				//struct protocol_beacon_retcode
	VBUS_EVT_IBEACON_WRITE_UUID,					//struct protocol_beacon_uuid_set
	VBUS_EVT_IBEACON_WRITE_UUID_REPLY,				//struct protocol_beacon_retcode
	VBUS_EVT_IBEACON_WRITE_PASSWORD,				//struct protocol_beacon_write_passwd
	VBUS_EVT_IBEACON_WRITE_PASSWORD_REPLY,		//struct protocol_beacon_retcode
	VBUS_EVT_IBEACON_GET_HEAD,
	VBUS_EVT_IBEACON_GET_HEAD_REPY,				//struct protocol_beacon_ret_head
	VBUS_EVT_IBEACON_GET_UUID,
	VBUS_EVT_IBEACON_GET_UUID_REPLY,				//struct protocol_beacon_ret_uuid




}VBUS_EVT_TYPE;


#endif /* VBUS_EVT_APP_H_ */
