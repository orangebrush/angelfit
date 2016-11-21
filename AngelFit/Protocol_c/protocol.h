/*
 * protocol.h
 *
 *  Created on: 2016年1月8日
 *      Author: Administrator
 */

#ifndef PROTOCOL_H_
#define PROTOCOL_H_

#include "include.h"


	#define PROTOCOL_TRANSPORT_MAX_SIZE		20
	#define PROTOCOL_TX_MAX_SIZE			PROTOCOL_TRANSPORT_MAX_SIZE

 //命令
    #define PROTOCOL_CMD_OTA                0x01
    #define PROTOCOL_CMD_GET                0x02
    #define PROTOCOL_CMD_SET                0x03
    #define PROTOCOL_CMD_BIND               0x04
    #define PROTOCOL_CMD_MSG                0x05
    #define PROTOCOL_CMD_APP_CONTROL        0x06
    #define PROTOCOL_CMD_BLE_CONTROL        0x07
    #define PROTOCOL_CMD_HEALTH_DATA        0x08
	#define PROTOCOL_CMD_NEW_HEALTH_DATA	0x09
	#define PROTOCOL_CMD_WEATHER			0x0A
    #define PROTOCOL_CMD_DUMP_STACK         0x20
    #define PROTOCOL_CMD_LOG                0x21
    #define PROTOCOL_CMD_TEST               0xAA
    #define PROTOCOL_CMD_RESET              0xF0

    // ota
    #define PROTOCOL_KEY_OTA_START          0x01
    #define PROTOCOL_KEY_OTA_DIRECT_START   0x02 //直接升级

    //获取命令
    #define PROTOCOL_KEY_GET_DEVICE_INFO    0x01
    #define PROTOCOL_KEY_GET_FUNC_TALBE     0x02
    #define PROTOCOL_KEY_GET_DEVICE_TIME    0x03
    #define PROTOCOL_KEY_GET_DEVICE_MAC     0x04
    #define PROTOCOL_KEY_GET_BATT_INFO      0x05
    #define PROTOCOL_KEY_GET_SN_INFO        0x06
    #define PROTOCOL_KEY_GET_NOTICE_STATUS  0x10
    #define PROTOCOL_KEY_GET_LIVE_DATA      0xA0  //获取实时数据,和08A0一样

    #define PROTOCOL_KEY_GET_HEART_RATE_SENSOR_PARAM    0x20
    #define PROTOCOL_KEY_GET_GSENSOR_PARAM              0x21


    //设置命令
    #define PROTOCOL_KEY_SET_DEVICE_TIME    0x01
    #define PROTOCOL_KEY_SET_ALARM          0x02
    #define PROTOCOL_KEY_SET_SPORT_GOAL     0x03
    #define PROTOCOL_KEY_SET_SLEEP_GOAL     0x04
    #define PROTOCOL_KEY_SET_USER_INFO      0x10
    #define PROTOCOL_KEY_SET_UNIT           0x11
    #define PROTOCOL_KEY_SET_LONG_SIT       0x20
    #define PROTOCOL_KEY_SET_LOST_FIND      0x21
    #define PROTOCOL_KEY_SET_HAND           0x22
    #define PROTOCOL_KEY_SET_SYS_OS         0x23
    #define PROTOCOL_KEY_SET_HEART_RATE_INTERVAL     0x24
    #define PROTOCOL_KEY_SET_NOTIF          0x30
    #define PROTOCOL_KEY_SET_LOST_FIND_MODE 0x40
	#define PROTOCOL_KEY_SET_HEART_RATE_THRESHOLD 		0x24
	#define PROTOCOL_KEY_SET_HEART_RATE_MODE 			0x25
	#define PROTOCOL_KEY_SET_FIND_PHONE 				0x26
	#define PROTOCOL_KEY_SET_DEFAULT_CONFIG 			0x27
    #define PROTOCOL_KEY_SET_UP_HAND_GESTURE            0x28
    #define PROTOCOL_KEY_SET_DO_NOT_DISTURB             0x29 //勿扰模式
    #define PROTOCOL_KEY_SET_MUISC_ONOFF                0x2A
    #define PROTOCOL_KEY_SET_DISPLAY_MODE               0x2B
	#define PROTOCOL_KEY_SET_ONEKEY_SOS					0x2C

    #define PROTOCOL_KEY_SET_WEATHER_SWITCH             0x2D
    #define PROTOCOL_KEY_SET_SPORT_MODE_SELECT          0x2E


    #define PROTOCOL_KEY_SET_HEART_SENSOR_PARAM         0x50
    #define PROTOCOL_KEY_SET_GSENSOR_PARAM              0x51
    #define PROTOCOL_KEY_SET_REAL_TIME_SENSOR_DATA      0x52
	#define PROTOCOL_KEY_SET_START_MOTOR				0x53

    //控制
    #define PROTOCOL_KEY_CONTROL_MUSIC              0x01
    #define PROTOCOL_KEY_CONTROL_PHOTO              0x02
    #define PROTOCOL_KEY_CONTROL_SINGLE_SPORT       0x03
    #define PROTOCOL_KEY_CONTROL_FIND_DEVICE        0x04
    #define PROTOCOL_KEY_CONTROL_OPEN_ANCS          0x30
    #define PROTOCOL_KEY_CONTROL_CLOSE_ANCS         0x31

    //健康数据
    #define PROTOCOL_KEY_HEALTH_DATA_REQUEST        0x01
    #define PROTOCOL_KEY_HEALTH_DATA_STOP           0x02
    #define PROTOCOL_KEY_HEALTH_DATA_DAY_SPORT      0x03
    #define PROTOCOL_KEY_HEALTH_DATA_DAY_SLEEP      0x04
    #define PROTOCOL_KEY_HEALTH_DATA_HISTORY_SPORT  0x05
    #define PROTOCOL_KEY_HEALTH_DATA_HISTORY_SLEEP  0x06
    #define PROTOCOL_KEY_HEALTH_DATA_DAY_HEART_RATE 0x07
    #define PROTOCOL_KEY_HEALTH_DATA_HISTORY_HEART_RATE 0x08
    #define PROTOCOL_KEY_HEALTH_DATA_LIVE_DATA      0xA0    //获取实时数据,不可用
    #define PROTOCOL_KEY_HEALTH_DATA_DATA_END       0xEE


	//新的健康数据
	#define PROTOCOL_KEY_NEW_HEALTH_DATA_ACTIVITY_DATA		0x06


	#define PROTOCOL_KEY_WEATHER_SET_DATA			0x01



    //绑定命令
    #define PROTOCOL_KEY_BIND_ENABLE                0x01
    #define PROTOCOL_KEY_BIND_DISENABLE             0x02

    //消息提醒
    #define PROTOCOL_KEY_MSG_CALL                   0x01
    #define PROTOCOL_KEY_MSG_CALL_STATUS            0x02
    #define PROTOCOL_KEY_MSG_SMS                    0x03
	#define PROTOCOL_KEY_MSG_UNREAD                 0x04

     //设备控制 -> app
    #define PROTOCOL_KEY_BLE_CONTROL_EVT         0x01
    #define PROTOCOL_KEY_BLE_CONTROL_FIND_PHONE  0x02
    #define PROTOCOL_KEY_BLE_CONTROL_ONEKEY_SOS   0x03
    #define PROTOCOL_KEY_BLE_CONTROL_LOST_FIND   0x04
	#define PROTOCOL_KEY_BLE_CONTORL_SENSOR_NOTCIE	0x10
	#define PROTOCOL_KEY_BLE_CONTORL_OPERATE		0x11


    //日志log
    #define PROTOCOL_KEY_LOG_OPEN                0x01
    #define PROTOCOL_KEY_LOG_CLOSE               0x02
    #define PROTOCOL_KEY_LOG_SEND                0x03
    #define PROTOCOL_KEY_LOG_UART_OPEN           0x04
    #define PROTOCOL_KEY_LOG_UART_CLOSE          0x05
    #define PROTOCOL_KEY_LOG_GET                 0x06
    #define PROTOCOL_KEY_LOG_CLEAN               0x07
    #define PROTOCOL_KEY_LOG_VBUS_EVT            0xF1
    #define PROTOCOL_KEY_LOG_VBUS_EVT_GET        0xF2
    //测试命令
    #define PROTOCOL_KEY_TEST_MODE_START             0x01
    #define PROTOCOL_KEY_TEST_MODE_EXIT              0x02
    #define PROTOCOL_KEY_TEST_MODE_SENSOR            0x03
    #define PROTOCOL_KEY_TEST_MODE_MOTOR             0x04
    #define PROTOCOL_KEY_TEST_MODE_KEY               0x05
    #define PROTOCOL_KEY_TEST_MODE_TAP               0x06
    #define PROTOCOL_KEY_TEST_MODE_OLED              0x07
    #define PROTOCOL_KEY_TEST_MODE_LED               0x08
    #define PORTOCOL_KEY_TEST_MODE_BELL              0x09
    #define PROTOCOL_KEY_TEST_MODE_CHARGING          0x0A
    #define PORTOCOK_KEY_TEST_MODE_LONG_MOTOR        0x20
    #define PROTOCOL_KEY_TEST_MODE_LONG_OLED         0x21
    #define PROTOCOL_KEY_TEST_MODE_LONG_LED          0x22
    #define PROTOCOL_KEY_TEST_RSSI                   0xF0  //获取rssi ,生产测试使用


    #define PROTOCOL_KEY_RESET_REBOOT               0x01

    //这里的结构体是要按照成员对齐
    #pragma pack(1)

    struct protocol_head
    {
        uint8_t cmd;
        uint8_t key;
    };

    struct protocol_cmd
    {
    	struct protocol_head head;
    	uint8_t cmd1;
    	uint8_t cmd2;
    	uint8_t cmd3;
    };

    struct protocol_date
    {
        uint16_t year;
        uint8_t month;
        uint8_t day;
    };


    struct protocol_sync_head
    {
        struct protocol_head head;
        uint8_t serial;
        uint8_t length;
    };



    //获取信息类
    struct protocol_device_info
    {
        struct protocol_head head;
        uint16_t device_id;   //设备id
        uint8_t version;      //版本号
        uint8_t mode;         //模式
        uint8_t batt_status;  //电池状态
        uint8_t batt_level;   //电量等级
        uint8_t pair_flag;    //绑定状态
        uint8_t reboot_flag;  //是否重启

    };

    struct protocol_get_rssi
    {
        struct protocol_head head;
        int8_t rssi;
    };

    struct protocol_get_func_table
    {
        struct protocol_head head;
        uint8_t main_func;
        uint8_t alarm_num;
        uint8_t alarm_type;
        uint8_t control;
        uint8_t call;
        uint8_t msg;
        uint8_t ohter;
        uint8_t msg_config;
        uint8_t msg2;
        uint8_t ohter2;
        uint8_t sport_type1;
        uint8_t sport_type2;
        uint8_t sport_type3;
        uint8_t sport_type4;
        uint8_t main_func1;

    };

    struct protocol_device_time
    {
        struct protocol_head head;
        uint16_t year;
        uint8_t month;
        uint8_t day;
        uint8_t hour;
        uint8_t minute;
        uint8_t second;
        uint8_t week;
    };

    struct protocol_device_mac
    {
        struct protocol_head head;
        uint8_t mac_addr[6];
    };

    struct protocol_device_batt_info
    {
        struct protocol_head head;
        uint8_t type;
        uint16_t voltage;
        uint8_t status;
        uint8_t level;
        uint32_t batt_user_time;
        uint32_t user_time;
    };


    //系统时间
    struct protocol_set_time
    {
        struct protocol_head head;
        uint16_t year;
        uint8_t month;
        uint8_t day;
        uint8_t hour;
        uint8_t minute;
        uint8_t second;
        uint8_t week;
    };

    //设置闹钟
    struct protocol_set_alarm
    {
        struct protocol_head head;
        uint8_t alarm_id;
        uint8_t status;
        uint8_t type;
        uint8_t hour;
        uint8_t minute;
        uint8_t repeat; //重复
        uint8_t tsnooze_duration;//贪睡时长
    };

    //设置目标
    struct protocol_set_sport_goal
    {
        struct protocol_head head;
        uint8_t type; //00步数,01 卡路里,02 距离
        uint32_t data;  //数值
        uint8_t sleep_hour;
        uint8_t sleep_minute;
    };

    struct protocol_set_sleep_goal
    {
        struct protocol_head head;
        uint8_t hour;
        uint8_t minute;
    };
    //用户信息
    struct protocol_set_user_info
    {
        struct protocol_head head;
        uint8_t heigth;     //升高
        uint16_t weight;    //体重
        uint8_t gender;
        uint16_t year;      //生日
        uint8_t monute;
        uint8_t day;
    };

    struct protocol_bind_enable
    {
        struct protocol_head head;
        uint8_t os;
        uint8_t version;
        uint8_t arg1;
        uint8_t arg2;
    };
    //设置单位
    struct protocol_set_uint
    {
        struct protocol_head head;
        uint8_t dist_uint;// 0 无效,1 km, 2 mi
        uint8_t weight_uint; // 1 kg,2 lb
        uint8_t temp;  // 1 o,2 F
        uint8_t stride; // 步长 cm
        uint8_t language;
        uint8_t is_12hour_format;
    };


    //设置左右手
    struct protocol_set_handle
    {
    	struct protocol_head head;
    	uint8_t hand_type;
    };

    //设置久坐
    struct protocol_long_sit
    {
        struct protocol_head head;
        uint8_t start_hour;     //开始时间
        uint8_t start_minute;
        uint8_t end_hour;
        uint8_t end_minute;    //   结束时间
        uint16_t interval;     // 间隔
        uint8_t repetitions;       //重复
    };

    //防丢
    struct protocol_lost_find
    {
        struct protocol_head head;
        uint8_t mode;
    };

    //防丢参数
    struct protocol_lost_find_mode
    {
        struct protocol_head head;
        uint8_t mode;
        uint8_t rssi;
        uint8_t delay;
        uint8_t use_disconnect;
        uint8_t disconnect_delay;
        uint8_t repetitons;
    };

    //心率间隔
    struct protocol_heart_rate_interval
    {
        struct protocol_head head;
        uint8_t burn_fat_threshold;
        uint8_t aerobic_threshold;
        uint8_t limit_threshold;
    };

    struct protocol_heart_rate_mode
    {
    	struct protocol_head head;
    	uint8_t mode;
    };




    struct protocol_status
    {
        struct protocol_head head;
        uint8_t status;
    };
    //数据同步类

    struct protocol_start_sync
    {
        struct protocol_head head;
        uint8_t sync_flag;
        uint8_t safe_mode;
    };


    struct protocol_start_sync_return
    {
        struct protocol_head head;
        uint16_t pack_count;    //无效
        uint8_t sport_day;
        uint8_t sleep_day;
        uint8_t heart_rate_day;
        uint8_t reserved;
    };

    struct protocol_start_sync_sport
    {
        struct protocol_head head;
        uint8_t status;
        uint8_t serial;
        uint8_t reserved;
    };

    struct protocol_start_sync_sleep
    {
        struct protocol_head head;
        uint8_t status;
        uint8_t serial;
        uint8_t reserved;
    };

    struct protocol_start_heart_rate
    {
        struct protocol_head head;
        uint8_t status;
        uint8_t serial;
        uint8_t reserved;
    };


    //实时数据
    struct protocol_start_live_data
    {
        struct protocol_head head;
        uint32_t step;
        uint32_t calories;
        uint32_t distances;
        uint32_t active_time;
        uint8_t heart_rate;
    };

    //来电
    struct protocol_msg_call
    {
        struct protocol_head head;
        uint8_t total;
        uint8_t serial;
    	uint8_t data[16];
    };

    struct protocol_msg_call_status
    {
        struct protocol_head head;
        uint8_t status;

    };
    //短信
    struct protocol_msg_sms_start
    {
        struct protocol_head head;
        uint8_t total;
        uint8_t serial;
        uint8_t data[16];
    };

    struct protocol_msg_unread
    {
        struct protocol_head head;
        uint8_t type;
        uint8_t items;
    };
    //set os
    struct protocol_set_os
    {
        struct protocol_head head;
        uint8_t os;
        uint8_t version;
    };
    //通知中心开关
    struct protocol_set_notice
    {
        struct protocol_head head;
        uint8_t notify_switch;
        uint8_t notify_itme1;
        uint8_t notify_itme2;
        uint8_t call_switch;
        uint8_t call_delay;
    };
    //通知中心开关应答
    struct protocol_set_notice_ack
    {
        struct protocol_head head;
        uint8_t notify_switch;
        uint8_t status_code;
        uint8_t err_code;
    };


    struct protocol_find_phone
    {
        struct protocol_head head;
        uint8_t status;
        uint8_t timeout;
    };

    struct protocol_set_up_hand_gesture
    {
        struct protocol_head head;
        uint8_t on_off;
        uint8_t show_second;
    };

    struct protocol_onekey_sos
    {
        struct protocol_head head;
        uint8_t status;
        uint8_t timeout;
    };


    struct protocol_msg_call_content
    {
        uint8_t phone_number_len;
        uint8_t contact_len;
        uint8_t data[PROTOCOL_TX_MAX_SIZE-2];
    };

    //防打扰
    struct protocol_do_not_disturb
    {
        struct protocol_head head;
        uint8_t switch_flag;
        uint8_t start_hour;
        uint8_t start_minute;
        uint8_t end_hour;
        uint8_t end_minute;
    };

    //音乐开关
    struct protocol_music_onoff
    {
        struct protocol_head head;
        uint8_t switch_status;
    };
    //显示模式
    struct protocol_display_mode
    {
        struct protocol_head head;
        uint8_t mode;
    };

    //

    struct protocol_set_real_time_health_data_status
    {
        struct protocol_head head;
        uint8_t gsensor_status;
        uint8_t heart_rate_sensor_status;
    };

    struct protocol_heart_rate_sensor_param
    {
        struct protocol_head head;
        uint16_t rate;
        uint8_t led_select;
    };

    struct protocol_gsensor_param
    {
        struct protocol_head head;
        uint16_t rate;
        uint8_t range;
        uint16_t threshold;
    };


    struct protocol_set_start_motor
	{
    	struct protocol_head head;
    	uint8_t status;
    	uint16_t timeout;
	};

    struct protocol_sensor_data_notice
    {
    	struct protocol_head head;
    	uint8_t type;
    };

    struct protocol_set_onekey_sos
    {
    	struct protocol_head head;
    	uint8_t on_off;	//0xAA 开,0x55 关
    };

    struct protocol_sport_mode_select
    {
    	struct protocol_head head;
    	uint8_t sport_type1;
    	uint8_t sport_type2;
    	uint8_t sport_type3;
    	uint8_t sport_type4;
    };


    struct protocol_sport_mode_select_bit
    {
    	struct protocol_head head;
    	uint8_t type1_walk : 1;
    	uint8_t type1_run : 1;
    	uint8_t type1_by_bike : 1;
    	uint8_t type1_on_foot : 1;
    	uint8_t type1_swim : 1;
    	uint8_t type1_mountain_climbing : 1;
    	uint8_t type1_badminton : 1;
    	uint8_t type1_other : 1;


    	uint8_t type2_fitness : 1;
    	uint8_t type2_spinning : 1;
    	uint8_t type2_ellipsoid : 1;
    	uint8_t type2_treadmill : 1;
    	uint8_t type2_sit_up : 1;
    	uint8_t type2_push_up : 1;
    	uint8_t type2_dumbbell: 1;
    	uint8_t type2_weightlifting: 1;


    	uint8_t type3_bodybuilding_exercise : 1;
    	uint8_t type3_yoga : 1;
    	uint8_t type3_rope_skipping : 1;
    	uint8_t type3_table_tennis : 1;
    	uint8_t type3_basketball : 1;
    	uint8_t type3_footballl : 1;
    	uint8_t type3_volleyball : 1;
    	uint8_t type3_tennis : 1;


    	uint8_t type4_golf : 1;
    	uint8_t type4_baseball : 1;
    	uint8_t type4_skiing : 1;
    	uint8_t type4_roller_skating : 1;
    	uint8_t type4_dance : 1;

    };

    struct protocol_weatch_data_future_item
    {
    	uint8_t type;
    	uint8_t max_temp;
    	uint8_t min_temp;
    };

    struct protocol_weatch_data
    {
    	struct protocol_head head;
    	uint8_t today_type;
    	uint8_t today_tmp;
    	uint8_t today_max_temp;
    	uint8_t today_min_temp;
    	uint8_t humidity;
    	uint8_t today_uv_intensity;	//紫外线强度
    	uint8_t today_aqi;			//空气污染指数
    	struct protocol_weatch_data_future_item future[3];

    };

    struct protocol_device_operate
    {
    	struct protocol_head head;
    	uint8_t type;  //0x01 短按,0x02 长按,0x03 敲打,0x04 双敲
    	uint16_t timeout;

    };

    //生产测试

    struct protocol_dtm_start_send
    {
        struct protocol_head head;
        uint8_t status;
        uint16_t device_id;
        uint8_t version;
        uint8_t batt_status;
        uint8_t batt_levle;
        uint8_t hw_map1;

    };

    struct protocol_dtm_sensor
    {
        struct protocol_head head;
        uint8_t status;
        uint16_t x;
        uint16_t y;
        uint16_t z;
    };

    struct protocol_dtm_motor
    {
        struct protocol_head head;
    };

    struct protocol_dtm_key
    {
        struct protocol_head head;
        uint8_t id;
        uint8_t type;

    };

    struct protocol_dtm_tap
    {
        struct protocol_head head;
        uint8_t type;
    };

    struct protocol_dtm_charging
    {
        struct protocol_head head;
        uint8_t type;
    };


    struct protocol_log_get
    {
        struct protocol_head head;
        uint8_t flag;
        uint8_t data[17];
    };

    struct protocol_get_sn_send
    {
        struct protocol_head head;
        uint16_t company;     //企业
        uint16_t year;
        uint8_t month;
        uint8_t day;
        uint32_t sn;
        uint16_t device_id;
        uint16_t channel;//渠道
        uint16_t production_num; //生成批号
    };

    struct protocol_log_vbus_evt
    {
        struct protocol_head head;
        uint16_t vbus_evt;
        uint8_t len;
        uint8_t data[16];
    };

    #pragma pack()

    struct _protocol_version
    {
    	uint32_t major;
    	uint32_t minor;
    	uint32_t date;
    	bool release;
    };

    typedef uint32_t (*protocol_write_data_handle)(const uint8_t *data,uint16_t length);

#ifdef __cplusplus
extern "C" {
#endif


    extern uint32_t protocol_write_data(const uint8_t *data,uint16_t length); //协议库的发送函数
    extern uint32_t protocol_receive_data(uint8_t const *data,uint16_t length); //蓝牙接收到数据,调用此函数传递给协议库
    extern uint32_t protocol_init(protocol_write_data_handle func); //协议初始化,传入蓝牙发送函数
    extern uint32_t protocol_get_version(uint32_t *major,uint32_t *minor,uint32_t *date,bool *release); //获得版本号
    extern uint32_t protocol_get_version_st(struct _protocol_version *version);


#ifdef __cplusplus
}
#endif
#endif /* PROTOCOL_H_ */
