/*
 * protocol_func_table.c
 *
 *  Created on: 2016年1月8日
 *      Author: Administrator
 */

//功能表解析

#define DEBUG_STR "[PROTOCOL_FUNC_TABLE]"

#include "protocol_func_table.h"


//这是表格总固件里面复制就可以了
//功能表 主功能
#define USER_FUNC_TABLE_MAIN_HAVE_SPORT()        (1 << 0)  //运动
#define USER_FUNC_TABLE_MAIN_HAVE_SLEEP()        (1 << 1)  //睡眠
#define USER_FUNC_TABLE_MAIN_HAVE_ONCE_SPORT()   (1 << 2)  //单次运动
#define USER_FUNC_TABLE_MAIN_HAVE_LIVE_DATA()    (1 << 3)  //实时数据
#define USER_FUNC_TABLE_MAIN_HAVE_OTA()          (1 << 4)  //升级功能
#define USER_FUNC_TABLE_MAIN_HAVE_HEART_RATE()   (1 << 5)  //心率
#define USER_FUNC_TABLE_MAIN_HAVE_ANCS()         (1 << 6)  //苹果通知中心
#define USER_FUNC_TABLE_MAIN_HAVE_TIMELINE()     (1 << 7)  //时间线
//功能表 闹钟类型
#define USER_FUCN_TABLE_ALRM_TYPE_GET_UP()        (1 << 0)  //起床闹钟
#define USER_FUCN_TABLE_ALRM_TYPE_SLEEP()         (1 << 1)  //睡眠
#define USER_FUCN_TABLE_ALRM_TYPE_WORK_OUT()      (1 << 2)  //锻炼
#define USER_FUCN_TABLE_ALRM_TYPE_MEDICATION()    (1 << 3)  //吃药
#define USER_FUCN_TABLE_ALRM_TYPE_APPOINTMENT()   (1 << 4)  //约会
#define USER_FUCN_TABLE_ALRM_TYPE_MEET()          (1 << 5)  //聚会
#define USER_FUCN_TABLE_ALRM_TYPE_CONFERENCE()    (1 << 6)  //会议
#define USER_FUCN_TABLE_ALRM_TYPE_CUSTOM()        (1 << 7)  //自定义
#define USER_FUNC_TABLE_ALARM_TYPE_ALL            (0xFF)   //全部

//功能表 控制功能
#define USER_FUNC_TABLE_CONTROL_PHOTO()           (1 << 0)  //控制拍照
#define USER_FUNC_TABLE_CONTROL_MUSIC()           (1 << 1)  //控制音乐

//来电提醒
#define USER_FUNC_TABLE_CALL_INCOMING()           (1 << 0)  //来电提醒
#define USER_FUNC_TABLE_CALL_CONTACTS()           (1 << 1)  //来电联系人
#define USER_FUNC_TABLE_CALL_ID()                 (1 << 2)  //来电号码

//消息提醒
#define USER_FUNC_TABLE_MSG_SMS()                 (1 << 0) //短信
#define USER_FUNC_TABLE_MSG_MAIL()                (1 << 1) //邮箱
#define USER_FUNC_TABLE_MSG_QQ()                  (1 << 2) //QQ
#define USER_FUNC_TABLE_MSG_WECHAT()              (1 << 3) //微信
#define USER_FUNC_TABLE_MSG_WEIBO()               (1 << 4) //微博
#define USER_FUNC_TABLE_MSG_FACEBOOK()            (1 << 5) //FACEBOOK
#define USER_FUNC_TABLE_MSG_TWITTER()             (1 << 6) //TWITTER


#define USER_FUNC_TABLE_MSG2_NONE()               (0)
#define USER_FUNC_TABLE_MSG2_WHATSAPP()           (1 << 0)
#define USER_FUNC_TABLE_MSG2_MESSENGER()          (1 << 1)
#define USER_FUNC_TABLE_MSG2_INSTAGRAM()          (1 << 2)
#define USER_FUNC_TABLE_MSG2_LINKED_IN()          (1 << 3)
#define USER_FUNC_TABLE_MSG2_CALENDAR()           (1 << 4)
#define USER_FUNC_TABLE_MSG2_SKYPE()              (1 << 5)
#define USER_FUNC_TABLE_MSG2_ALARM_CLOCK()        (1 << 6)
#define USER_FUNC_TABLE_MSG2_POKEMAM()            (1 << 7)

//其他功能
#define USER_FUNC_TABLE_OHTER_NONE 				  (0)
#define USER_FUNC_TABLE_OHTER_LONG_SIT()          (1 << 0) //久坐
#define USER_FUNC_TABLE_OHTER_LOST_FIND()         (1 << 1) //防丢
#define USER_FUNC_TABLE_OHTER_ONE_KEY_SOS()       (1 << 2) //一键呼叫
#define USER_FUNC_TABLE_OHTER_FIND_PHONE()        (1 << 3) //寻找手机
#define USER_FUNC_TABLE_OHTER_FIND_DEVICE()       (1 << 4) //寻找设备
#define USER_FUNC_TABLE_OHTER_ONE_KEY_REBACK_CONFIG()  (1 << 5)
#define USER_FUNC_TABLE_OHTER_UP_HAND_GESTURE()   (1 << 6)
#define USER_FUNC_TABLE_OTHER_WEATHER()			  (1 << 7)
//其他功能2
#define USER_FUNC_TABLE_OHTER2_NONE() 			  (0)
#define USER_FUNC_TABLE_OHTER2_HR_STATIC()         (1 << 0) //静态心率
#define USER_FUNC_TABLE_OHTER2_DISTURB()           (1 << 1) //防打扰模式
#define USER_FUNC_TABLE_OHTER2_SHOW_MODE()         (1 << 2) //显示模式
//#define USER_FUNC_TABLE_OHTER_CONTROL_MUSIC()     (1 << 3) //控制音乐
#define USER_FUNC_TABLE_OHTER2_HREAT_MONITOR()     (1 << 3) //心率监测

//消息提醒配置

#define USER_FUNC_TABLE_MSG_CFG_CONTACTS()         (1 << 0) //短信联系人
#define USER_FUNC_TABLE_MSG_CFG_ID()               (1 << 1) //短信号码
#define USER_FUNC_TABLE_MSG_CFG_DATA()             (1 << 2) //短信内容



#define USER_FUNC_TABLE_SPORT_TYPE1_WALK()		   (1 << 0)
#define USER_FUNC_TABLE_SPORT_TYPE1_RUN()		   	   (1 << 1)
#define USER_FUNC_TABLE_SPORT_TYPE1_BY_BIKE()		   (1 << 2)
#define USER_FUNC_TABLE_SPORT_TYPE1_ON_FOOT()		   (1 << 3)
#define USER_FUNC_TABLE_SPORT_TYPE1_SWIM()		   (1 << 4)
#define USER_FUNC_TABLE_SPORT_TYPE1_MOUNTAIN_CLIMBING()		   (1 << 5)
#define USER_FUNC_TABLE_SPORT_TYPE1_BADMINTON()	   (1 << 6)
#define USER_FUNC_TABLE_SPORT_TYPE1_OTHER()		   (1 << 7)


#define USER_FUNC_TABLE_SPORT_TYPE2_FITNESS()		   (1 << 0)
#define USER_FUNC_TABLE_SPORT_TYPE2_SPINNING()	   (1 << 1)
#define USER_FUNC_TABLE_SPORT_TYPE2_ELLIPSOID()	   (1 << 2)
#define USER_FUNC_TABLE_SPORT_TYPE2_TREADMILL()	   (1 << 3)
#define USER_FUNC_TABLE_SPORT_TYPE2_SIT_UP()		   (1 << 4)
#define USER_FUNC_TABLE_SPORT_TYPE2_PUSH_UP()		   (1 << 5)
#define USER_FUNC_TABLE_SPORT_TYPE2_DUMBBELL()	   (1 << 6)
#define USER_FUNC_TABLE_SPORT_TYPE2_WEIGHTLIFTING()  (1 << 7)


#define USER_FUNC_TABLE_SPORT_TYPE3_BODYBUILDING_EXERCISE()		   (1 << 0)
#define USER_FUNC_TABLE_SPORT_TYPE3_YOGA()		    (1 << 1)
#define USER_FUNC_TABLE_SPORT_TYPE3_ROPE_SKIPPING()	(1 << 2)
#define USER_FUNC_TABLE_SPORT_TYPE3_TABLE_TENNIS()	(1 << 3)
#define USER_FUNC_TABLE_SPORT_TYPE3_BASKETBALL()		(1 << 4)
#define USER_FUNC_TABLE_SPORT_TYPE3_FOOTBALLL()		(1 << 5)
#define USER_FUNC_TABLE_SPORT_TYPE3_VOLLEYBALL()		(1 << 6)
#define USER_FUNC_TABLE_SPORT_TYPE3_TENNIS()		    (1 << 7)

#define USER_FUNC_TABLE_SPORT_TYPE4_GOLF()		    (1 << 0)
#define USER_FUNC_TABLE_SPORT_TYPE4_BASEBALL()		(1 << 1)
#define USER_FUNC_TABLE_SPORT_TYPE4_SKIING() 	   		(1 << 2)
#define USER_FUNC_TABLE_SPORT_TYPE4_ROLLER_SKATIN()	(1 << 3)
#define USER_FUNC_TABLE_SPORT_TYPE4_DANCE() 	   		(1 << 4)
#define USER_FUNC_TABLE_SPORT_TYPE4_WALK()		    (1 << 5)


#define USER_FUNC_TABLE_MAIN1_LOG_IN()				(1 << 0)


//生产测试功能表
#define USER_HW_MAP1_HAVE_MOTOR()                  (1 << 0)
#define USER_HW_MAP1_HAVE_KEY()                    (1 << 1)
#define USER_HW_MAP1_HAVE_OLED()                   (1 << 2)
#define USER_HW_MAP1_HAVE_LED()                    (1 << 3)
#define USER_HW_MAP1_HAVE_BELL()                   (1 << 4)  //蜂鸣器
#define USER_HW_MAP1_HAVE_ACC()                    (1 << 5)  //加速度传感器
#define USER_HW_MAP1_HAVE_TAP()                    (1 << 6)  //敲打

static struct protocol_func_table func_table;


uint32_t protocol_func_table_init()
{
	memset(&func_table,0,sizeof(func_table));
	return SUCCESS;
}

uint32_t protocol_func_table_set(struct protocol_get_func_table *protocol_data)
{
	func_table.main.stepCalculation = (protocol_data->main_func & USER_FUNC_TABLE_MAIN_HAVE_SPORT()) != 0;
	func_table.main.sleepMonitor = (protocol_data->main_func & USER_FUNC_TABLE_MAIN_HAVE_SLEEP()) != 0;
	func_table.main.singleSport = (protocol_data->main_func & USER_FUNC_TABLE_MAIN_HAVE_ONCE_SPORT()) != 0;
	func_table.main.realtimeData = (protocol_data->main_func & USER_FUNC_TABLE_MAIN_HAVE_LIVE_DATA()) != 0;
	func_table.main.deviceUpdate = (protocol_data->main_func & USER_FUNC_TABLE_MAIN_HAVE_OTA()) != 0;
	func_table.main.heartRate = (protocol_data->main_func & USER_FUNC_TABLE_MAIN_HAVE_HEART_RATE()) != 0;
    func_table.main.Ancs = (protocol_data->main_func & USER_FUNC_TABLE_MAIN_HAVE_ANCS()) != 0;
    func_table.main.timeLine = (protocol_data->main_func & USER_FUNC_TABLE_MAIN_HAVE_TIMELINE()) != 0;

	func_table.alarm_count = protocol_data->alarm_num;

	func_table.type.wakeUp = (protocol_data->alarm_type & USER_FUCN_TABLE_ALRM_TYPE_GET_UP()) != 0;
	func_table.type.sleep = (protocol_data->alarm_type & USER_FUCN_TABLE_ALRM_TYPE_SLEEP()) != 0;
	func_table.type.sport = (protocol_data->alarm_type & USER_FUCN_TABLE_ALRM_TYPE_WORK_OUT()) != 0;
	func_table.type.medicine = (protocol_data->alarm_type & USER_FUCN_TABLE_ALRM_TYPE_MEDICATION()) != 0;
	func_table.type.dating = (protocol_data->alarm_type & USER_FUCN_TABLE_ALRM_TYPE_APPOINTMENT()) != 0;
	func_table.type.party = (protocol_data->alarm_type & USER_FUCN_TABLE_ALRM_TYPE_MEET()) != 0;
	func_table.type.metting = (protocol_data->alarm_type & USER_FUCN_TABLE_ALRM_TYPE_CONFERENCE()) != 0;
	func_table.type.custom = (protocol_data->alarm_type & USER_FUCN_TABLE_ALRM_TYPE_CUSTOM()) != 0;

	func_table.control.music = (protocol_data->control & USER_FUNC_TABLE_CONTROL_MUSIC()) != 0;
	func_table.control.takePhoto = (protocol_data->control & USER_FUNC_TABLE_CONTROL_PHOTO()) != 0;

	func_table.call.calling = (protocol_data->call & USER_FUNC_TABLE_CALL_INCOMING()) != 0;
	func_table.call.callingContact = (protocol_data->call & USER_FUNC_TABLE_CALL_CONTACTS()) != 0;
	func_table.call.callingNum = (protocol_data->call & USER_FUNC_TABLE_CALL_ID()) != 0;

	func_table.notify.message = (protocol_data->msg & USER_FUNC_TABLE_MSG_SMS()) != 0;
	func_table.notify.email = (protocol_data->msg & USER_FUNC_TABLE_MSG_MAIL()) != 0;
	func_table.notify.qq = (protocol_data->msg & USER_FUNC_TABLE_MSG_QQ()) != 0;
	func_table.notify.weixin = (protocol_data->msg & USER_FUNC_TABLE_MSG_WECHAT()) != 0;
	func_table.notify.sinaWeibo = (protocol_data->msg & USER_FUNC_TABLE_MSG_WEIBO()) != 0;
	func_table.notify.facebook = (protocol_data->msg & USER_FUNC_TABLE_MSG_FACEBOOK()) != 0;
	func_table.notify.twitter = (protocol_data->msg & USER_FUNC_TABLE_MSG_TWITTER()) != 0;
    
    func_table.ontify2.whatsapp = (protocol_data->msg2 & USER_FUNC_TABLE_MSG2_WHATSAPP()) != 0;
    func_table.ontify2.messengre = (protocol_data->msg2 & USER_FUNC_TABLE_MSG2_MESSENGER()) != 0;
    func_table.ontify2.instagram = (protocol_data->msg2 & USER_FUNC_TABLE_MSG2_INSTAGRAM()) != 0;
    func_table.ontify2.linked_in = (protocol_data->msg2 & USER_FUNC_TABLE_MSG2_LINKED_IN()) != 0;
	func_table.ontify2.calendar = (protocol_data->msg2 & USER_FUNC_TABLE_MSG2_CALENDAR()) != 0;
	func_table.ontify2.skype = (protocol_data->msg2 & USER_FUNC_TABLE_MSG2_SKYPE()) != 0;
	func_table.ontify2.alarmClock = (protocol_data->msg2 & USER_FUNC_TABLE_MSG2_ALARM_CLOCK()) != 0;

	func_table.other.sedentariness = (protocol_data->ohter & USER_FUNC_TABLE_OHTER_LONG_SIT()) != 0;
	func_table.other.antilost = (protocol_data->ohter & USER_FUNC_TABLE_OHTER_LOST_FIND()) != 0;
	func_table.other.onetouchCalling = (protocol_data->ohter & USER_FUNC_TABLE_OHTER_ONE_KEY_SOS()) != 0;
	func_table.other.findPhone = (protocol_data->ohter & USER_FUNC_TABLE_OHTER_FIND_PHONE()) != 0;
	func_table.other.findDevice = (protocol_data->ohter & USER_FUNC_TABLE_OHTER_FIND_DEVICE()) != 0;
    func_table.other.configDefault = (protocol_data->ohter & USER_FUNC_TABLE_OHTER_ONE_KEY_REBACK_CONFIG()) != 0;
    func_table.other.upHandGesture = (protocol_data->ohter & USER_FUNC_TABLE_OHTER_UP_HAND_GESTURE()) != 0;
    func_table.other.weather = (protocol_data->ohter & USER_FUNC_TABLE_OTHER_WEATHER()) != 0;

    func_table.ohter2.staticHR = (protocol_data->ohter2 & USER_FUNC_TABLE_OHTER2_HR_STATIC()) != 0;
    func_table.ohter2.doNotDisturb = (protocol_data->ohter2 & USER_FUNC_TABLE_OHTER2_DISTURB()) != 0;
    func_table.ohter2.displayMode = (protocol_data->ohter2 & USER_FUNC_TABLE_OHTER2_SHOW_MODE()) != 0;
    func_table.ohter2.heartRateMonitor = (protocol_data->ohter2 & USER_FUNC_TABLE_OHTER2_HREAT_MONITOR()) != 0;

	func_table.sms.tipInfoContact = (protocol_data->msg_config & USER_FUNC_TABLE_MSG_CFG_CONTACTS()) != 0;
	func_table.sms.tipInfoNum = (protocol_data->msg_config & USER_FUNC_TABLE_MSG_CFG_ID()) != 0;
	func_table.sms.tipInfoContent = (protocol_data->msg_config & USER_FUNC_TABLE_MSG_CFG_DATA()) != 0;


	func_table.sport_type0.walk = (protocol_data->sport_type1 & USER_FUNC_TABLE_SPORT_TYPE1_WALK()) != 0;
	func_table.sport_type0.run = (protocol_data->sport_type1 & USER_FUNC_TABLE_SPORT_TYPE1_RUN()) != 0;
	func_table.sport_type0.by_bike = (protocol_data->sport_type1 & USER_FUNC_TABLE_SPORT_TYPE1_BY_BIKE()) != 0;
	func_table.sport_type0.on_foot = (protocol_data->sport_type1 & USER_FUNC_TABLE_SPORT_TYPE1_ON_FOOT()) != 0;
	func_table.sport_type0.swim = (protocol_data->sport_type1 & USER_FUNC_TABLE_SPORT_TYPE1_SWIM()) != 0;
	func_table.sport_type0.mountain_climbing = (protocol_data->sport_type1 & USER_FUNC_TABLE_SPORT_TYPE1_MOUNTAIN_CLIMBING()) != 0;
	func_table.sport_type0.badminton = (protocol_data->sport_type1 & USER_FUNC_TABLE_SPORT_TYPE1_BADMINTON()) != 0;
	func_table.sport_type0.other = (protocol_data->sport_type1 & USER_FUNC_TABLE_SPORT_TYPE1_OTHER()) != 0;

	func_table.sport_type1.fitness = (protocol_data->sport_type2 & USER_FUNC_TABLE_SPORT_TYPE2_FITNESS()) != 0;
	func_table.sport_type1.spinning = (protocol_data->sport_type2 & USER_FUNC_TABLE_SPORT_TYPE2_SPINNING()) != 0;
	func_table.sport_type1.ellipsoid = (protocol_data->sport_type2 & USER_FUNC_TABLE_SPORT_TYPE2_ELLIPSOID()) != 0;
	func_table.sport_type1.treadmill = (protocol_data->sport_type2 & USER_FUNC_TABLE_SPORT_TYPE2_TREADMILL()) != 0;
	func_table.sport_type1.sit_up = (protocol_data->sport_type2 & USER_FUNC_TABLE_SPORT_TYPE2_SIT_UP()) != 0;
	func_table.sport_type1.push_up = (protocol_data->sport_type2 & USER_FUNC_TABLE_SPORT_TYPE2_PUSH_UP()) != 0;
	func_table.sport_type1.dumbbell = (protocol_data->sport_type2 & USER_FUNC_TABLE_SPORT_TYPE2_DUMBBELL()) != 0;
	func_table.sport_type1.weightlifting = (protocol_data->sport_type2 & USER_FUNC_TABLE_SPORT_TYPE2_WEIGHTLIFTING()) != 0;



	func_table.sport_type2.bodybuilding_exercise = (protocol_data->sport_type3 & USER_FUNC_TABLE_SPORT_TYPE3_BODYBUILDING_EXERCISE()) != 0;
	func_table.sport_type2.yoga = (protocol_data->sport_type3 & USER_FUNC_TABLE_SPORT_TYPE3_YOGA()) != 0;
	func_table.sport_type2.rope_skipping = (protocol_data->sport_type3 & USER_FUNC_TABLE_SPORT_TYPE3_ROPE_SKIPPING()) != 0;
	func_table.sport_type2.table_tennis = (protocol_data->sport_type3 & USER_FUNC_TABLE_SPORT_TYPE3_TABLE_TENNIS()) != 0;
	func_table.sport_type2.basketball = (protocol_data->sport_type3 & USER_FUNC_TABLE_SPORT_TYPE3_BASKETBALL()) != 0;
	func_table.sport_type2.footballl = (protocol_data->sport_type3 & USER_FUNC_TABLE_SPORT_TYPE3_FOOTBALLL()) != 0;
	func_table.sport_type2.volleyball = (protocol_data->sport_type3 & USER_FUNC_TABLE_SPORT_TYPE3_VOLLEYBALL()) != 0;
	func_table.sport_type2.tennis = (protocol_data->sport_type3 & USER_FUNC_TABLE_SPORT_TYPE3_TENNIS()) != 0;


	func_table.sport_type3.golf = (protocol_data->sport_type4 & USER_FUNC_TABLE_SPORT_TYPE4_GOLF()) != 0;
	func_table.sport_type3.baseball = (protocol_data->sport_type4 & USER_FUNC_TABLE_SPORT_TYPE4_BASEBALL()) != 0;
	func_table.sport_type3.skiing = (protocol_data->sport_type4 & USER_FUNC_TABLE_SPORT_TYPE4_SKIING()) != 0;
	func_table.sport_type3.roller_skating = (protocol_data->sport_type4 & USER_FUNC_TABLE_SPORT_TYPE4_ROLLER_SKATIN()) != 0;
	func_table.sport_type3.dance = (protocol_data->sport_type4 & USER_FUNC_TABLE_SPORT_TYPE4_DANCE()) != 0;



	func_table.main1.logIn = (protocol_data->main_func1 & USER_FUNC_TABLE_MAIN1_LOG_IN() ) != 0;

	return SUCCESS;
}

uint32_t protocol_func_table_get(struct protocol_func_table *table)
{
	if(table == NULL)
	{
		return ERROR_NULL;
	}
	memcpy(table,&func_table,sizeof(struct protocol_func_table));
	return SUCCESS;
}

bool protocol_func_table_have_heart_rate()
{
	DEBUG_INFO("heart rate value = %d ",func_table.main.heartRate);
    return func_table.main.heartRate;
}

uint8_t protocol_func_table_get_alarm_number()
{
    return func_table.alarm_count;
}

