/*
 * protocol_health.c
 *
 *  Created on: 2016年2月17日
 *
 *      Author: Administrator
 *
 * 用来获取健康数据,但是不解析
 */

#define DEBUG_STR "[PROTOCOL_HEALTH]"

#include "debug.h"
#include "include.h"
#include "app_timer.h"
#include "protocol.h"
#include "protocol_write.h"
#include "protocol_health.h"
#include "protocol_func_table.h"


#define PROTOCOL_HEALTH_DELAY_EXEC_PROCESS_MS		50
#define PROTOCOL_HEALTH_SYNC_MAX_DAY				7

#define PROTOCOL_HEALTH_RX_SPORT_ONEDAY_PACKET			(32 + 4) //(60/15*5*24/15)
#define PROTOCOL_HEALTH_RX_SLEEP_ONEDAY_PACKET			(10 + 4)  //80/8
#define PROTOCOL_HEALTH_RX_HR_ONEDAY_PAKCET				(36 + 4)//60/5*2*24/16

//当次同步状态
struct protocol_sync_status_st
{
	uint16_t total_packet_size; //当次同步的包的大小
	uint16_t rx_packet_count; //当次同步包统计
	uint16_t rx_data_byte_count; //接收到字节大小
	bool is_today; //是否为当天的同步
	bool rx_data_is_end; //当次接收是否结束
	bool rx_data_is_error; //当次数据发送错误
};

//当次同步数据
struct protocol_sync_data_st
{
	uint8_t head[PROTOCOL_TRANSPORT_MAX_SIZE * 2];
	uint8_t data[1024];
};


//所有同步的状态
struct protocol_sync_st
{
	bool all_sync_is_start;
	bool once_sync_complete_start;
	uint8_t sport_history_days;
	uint8_t sleep_history_days;
	uint8_t heart_rate_history_days;

	uint16_t need_rx_all_packet;	//需要接收的所有包
	uint16_t cur_rx_all_packet_count;		//当前接收的包
	uint8_t sync_progress_rate;				//同步进度

	protocol_sync_status status; //同步状态,在同步哪一种数据

};

static struct protocol_health_exec_st exec_func_table[PROTOOCL_EXEC_TABLE_INDEX_MAX_SIZE];//解析器分组
static struct protocol_sync_status_st cur_sync_status;
static struct protocol_sync_data_st cur_sync_data;
static struct protocol_sync_st cur_sync;


static uint32_t delay_exec_process_timer;
static uint32_t sync_guard_timer;  //守护定时器


static uint32_t protocol_health_next_process_sch(void);

static uint32_t write_data(uint8_t *data,uint8_t length)
{
	if(length < 2)
	{
		return ERROR_INVALID_LENGTH;
	}
	return protocol_write_set_cmd_key(data[0],data[1],data + 2,length,true,SYNC_EVT_HEALTH_PROCESSING);
}

static uint32_t write_data1(uint8_t cmd,uint8_t key,uint8_t data1)
{
	uint8_t data[3] = {0};
	data[0] = cmd;
	data[1] = key;
	data[2] = data1;
	return write_data(data,sizeof(data));
}

static uint32_t write_data2(uint8_t cmd,uint8_t key,uint8_t data1,uint8_t data2)
{
	uint8_t data[4] = {0};
	data[0] = cmd;
	data[1] = key;
	data[2] = data1;
	data[3] = data2;
	return write_data(data,sizeof(data));
}

static void clean_cur_sync_status()
{
	cur_sync_status.total_packet_size = 0;
	cur_sync_status.rx_packet_count = 0;
	cur_sync_status.rx_data_byte_count = 0;
	cur_sync_status.rx_data_is_end = false;
    DEBUG_INFO("clean_cur_sync_status");
}

static void sync_guard_timer_start()
{
    app_timer_start(sync_guard_timer, 15*1000, NULL); //15s 超时
}

static void sync_guard_timer_stop()
{
    app_timer_stop(sync_guard_timer);
}

static void get_sync_cmd_byte(protoocl_sync_cmd cmd,bool is_today,uint8_t buf[2])
{


	switch(cmd)
	{
	case PROTOCOL_WRITE_CMD_SPORT_START :
	case PROTOCOL_WRITE_CMD_SPORT_STOP :
		if(is_today == true)
		{
			buf[0] = PROTOCOL_CMD_HEALTH_DATA;
			buf[1] = PROTOCOL_KEY_HEALTH_DATA_DAY_SPORT;
		}
		else
		{
			buf[0] = PROTOCOL_CMD_HEALTH_DATA;
			buf[1] = PROTOCOL_KEY_HEALTH_DATA_HISTORY_SPORT;
		}
		break;
	case PROTOCOL_WRITE_CMD_SLEEP_START :
	case PROTOCOL_WRITE_CMD_SLEEP_STOP :
		if(is_today == true)
		{
			buf[0] = PROTOCOL_CMD_HEALTH_DATA;
			buf[1] = PROTOCOL_KEY_HEALTH_DATA_DAY_SLEEP;
		}
		else
		{
			buf[0] = PROTOCOL_CMD_HEALTH_DATA;
			buf[1] = PROTOCOL_KEY_HEALTH_DATA_HISTORY_SLEEP;
		}
		break;
	case PROTOCOL_WRITE_CMD_HEART_RATE_START :
	case PROTOCOL_WRITE_CMD_HEART_RATE_STOP :
		if(is_today == true)
		{
			buf[0] = PROTOCOL_CMD_HEALTH_DATA;
			buf[1] = PROTOCOL_KEY_HEALTH_DATA_DAY_HEART_RATE;
		}
		else
		{
			buf[0] = PROTOCOL_CMD_HEALTH_DATA;
			buf[1] = PROTOCOL_KEY_HEALTH_DATA_HISTORY_HEART_RATE;
		}
		break;
	}
	DEBUG_INFO("get_sync_cmd_byte = %d,byte[0] = %d,byte[1] = %d",cmd,buf[0],buf[1]);

}

static uint32_t write_sync_cmd(protoocl_sync_cmd cmd,bool is_today)
{
	uint8_t cmd_to_bytes[2] = {0};
	DEBUG_INFO("write_sync_cmd = %d,today = %d",cmd,is_today);
	switch(cmd)
	{
	case PROTOCOL_WRITE_CMD_START :
	{
		struct protocol_start_sync data;
		data.head.cmd = PROTOCOL_CMD_HEALTH_DATA;
		data.head.key = PROTOCOL_KEY_HEALTH_DATA_REQUEST;
		data.sync_flag = 0x01; //手动同步
		data.safe_mode = 0x00;	//安全模式不再支持
		write_data((uint8_t *)&data,sizeof(data));
	}

		break;
	case PROTOCOL_WRITE_CMD_STOP :
		write_data1(PROTOCOL_CMD_HEALTH_DATA,PROTOCOL_KEY_HEALTH_DATA_STOP,0);
		break;
	case PROTOCOL_WRITE_CMD_SPORT_START :
	{
		cur_sync_status.is_today = is_today;
		get_sync_cmd_byte(cmd,is_today,cmd_to_bytes);
		write_data1(cmd_to_bytes[0],cmd_to_bytes[1],PROTOCOL_HEALTH_SYNC_TYPE_START);
	}
		break;
	case PROTOCOL_WRITE_CMD_SPORT_STOP :
		cur_sync_status.is_today = is_today;
		get_sync_cmd_byte(cmd,is_today,cmd_to_bytes);
		write_data1(cmd_to_bytes[0],cmd_to_bytes[1],PROTOCOL_HEALTH_SYNC_TYPE_STOP);
		break;
	case PROTOCOL_WRITE_CMD_SLEEP_START :
		cur_sync_status.is_today = is_today;
		get_sync_cmd_byte(cmd,is_today,cmd_to_bytes);
		write_data1(cmd_to_bytes[0],cmd_to_bytes[1],PROTOCOL_HEALTH_SYNC_TYPE_START);

		break;
	case PROTOCOL_WRITE_CMD_SLEEP_STOP :
		cur_sync_status.is_today = is_today;
		get_sync_cmd_byte(cmd,is_today,cmd_to_bytes);
		write_data1(cmd_to_bytes[0],cmd_to_bytes[1],PROTOCOL_HEALTH_SYNC_TYPE_STOP);
		break;
	case PROTOCOL_WRITE_CMD_HEART_RATE_START :
		cur_sync_status.is_today = is_today;
		get_sync_cmd_byte(cmd,is_today,cmd_to_bytes);
		write_data1(cmd_to_bytes[0],cmd_to_bytes[1],PROTOCOL_HEALTH_SYNC_TYPE_START);
		break;
	case PROTOCOL_WRITE_CMD_HEART_RATE_STOP :
		cur_sync_status.is_today = is_today;
		get_sync_cmd_byte(cmd,is_today,cmd_to_bytes);
		write_data1(cmd_to_bytes[0],cmd_to_bytes[1],PROTOCOL_HEALTH_SYNC_TYPE_STOP);
		break;
	}

	return SUCCESS;
}


static void update_sync_progress_rate(bool is_sync_ok)
{
	uint32_t ret_code = SUCCESS;
	if(is_sync_ok == true)
	{
		cur_sync.sync_progress_rate = 100;
		DEBUG_INFO("sync progress = %d",cur_sync.sync_progress_rate);
		vbus_tx_data(VBUS_EVT_BASE_NOTICE_APP,SYNC_EVT_HEALTH_PROGRESS,(const void *)cur_sync.sync_progress_rate,sizeof(void *),&ret_code);
		return ;
	}
	if(cur_sync.need_rx_all_packet == 0)
	{
		return ;
	}

	if((cur_sync.cur_rx_all_packet_count * 100) / cur_sync.need_rx_all_packet > cur_sync.sync_progress_rate)
	{
		cur_sync.sync_progress_rate = (cur_sync.cur_rx_all_packet_count * 100) / cur_sync.need_rx_all_packet;
		if(cur_sync.sync_progress_rate > 99)
		{
			cur_sync.sync_progress_rate = 99;
		}
		DEBUG_INFO("sync progress = %d,cur packet = %d, need packet = %d",cur_sync.sync_progress_rate,cur_sync.cur_rx_all_packet_count,cur_sync.need_rx_all_packet);
		vbus_tx_data(VBUS_EVT_BASE_NOTICE_APP,SYNC_EVT_HEALTH_PROGRESS,(const void *)cur_sync.sync_progress_rate,sizeof(void *),&ret_code);
	}

}

static bool protocol_health_sync_data_check()
{
	uint8_t cmd_to_bytes[2] = {0};
	/*
	 *固件貌似在睡眠上对包的数量处理不对
	if(cur_sync_status.total_packet_size != cur_sync_status.rx_packet_count)
	{
		return false;
	}
	*/
	get_sync_cmd_byte(cur_sync.status,cur_sync_status.is_today,cmd_to_bytes);
	if((cur_sync_data.head[0] != cmd_to_bytes[0]) || (cur_sync_data.head[1] != cmd_to_bytes[1]))
	{
		DEBUG_INFO("sync check data error status = %d,today = %d,head[0] = %d,head[1] = %d,cmd_to_byte[0] =%d,cmd_to_byte[1] =%d",cur_sync.status,cur_sync_status.is_today,
				cur_sync_data.head[0],cur_sync_data.head[1],cmd_to_bytes[0],cmd_to_bytes[1]);
		return false;
	}
	return true;
}


static uint32_t protocol_set_sync_status(protocol_sync_status status)
{
	DEBUG_INFO("set sync status = %d",cur_sync.status);
	cur_sync.status = status;
	return SUCCESS;
}



static uint32_t protocol_health_next_process()
{
	switch((uint32_t)cur_sync.status)
	{
	case PROTOOCL_SYNC_STATUS_START :
		write_sync_cmd(PROTOCOL_WRITE_CMD_START,false);
		break;
	case PROTOOCL_SYNC_STATUS_STOP :
		write_sync_cmd(PROTOCOL_WRITE_CMD_STOP,false);
		break;
	case PROTOOCL_SYNC_STATUS_TAODAY_SPORT :

		if(cur_sync.once_sync_complete_start == true) //当次同步完成,切换到下一次任务
		{
			cur_sync.once_sync_complete_start = false;
			protocol_set_sync_status(PROTOOCL_SYNC_STATUS_TODAY_SLEEP);
			protocol_health_next_process_sch();
		}
		else
		{
			write_sync_cmd(PROTOCOL_WRITE_CMD_SPORT_START,true);
            sync_guard_timer_start();
		}
		break;
	case PROTOCOL_SYNC_STATUS_HISTORY_SPORT :

		if(cur_sync.once_sync_complete_start == true)
		{
			cur_sync.once_sync_complete_start = false;

		}

		if(cur_sync.sport_history_days != 0)
		{
			write_sync_cmd(PROTOCOL_WRITE_CMD_SPORT_START,false);
            sync_guard_timer_start();
            cur_sync.sport_history_days --;
		}
		else
		{
			protocol_set_sync_status(PROTOOCL_SYNC_STATUS_HISTORY_SLEEP); //运动同步完成开始同步睡眠
			protocol_health_next_process_sch();
		}
		break;
	case PROTOOCL_SYNC_STATUS_TODAY_SLEEP :
		if(cur_sync.once_sync_complete_start == true) //当次同步完成,切换到下一次任务
		{
			cur_sync.once_sync_complete_start = false;

            if(protocol_func_table_have_heart_rate() == true)
            {
            	DEBUG_INFO("start sync heart rate");
                protocol_set_sync_status(PROTOCOL_SYNC_STATUS_TODAY_HEART_RATE);
            }
            else
            {
            	DEBUG_INFO("no heart rate,start sync history sport");
                protocol_set_sync_status(PROTOCOL_SYNC_STATUS_HISTORY_SPORT);
            }
			protocol_health_next_process_sch();
		}
		else
		{
			write_sync_cmd(PROTOCOL_WRITE_CMD_SLEEP_START,true);
            sync_guard_timer_start();
		}
		break;
	case PROTOOCL_SYNC_STATUS_HISTORY_SLEEP :

		if(cur_sync.once_sync_complete_start == true)
		{
			cur_sync.once_sync_complete_start = false;
		}

		if(cur_sync.sleep_history_days != 0)
		{
			write_sync_cmd(PROTOCOL_WRITE_CMD_SLEEP_START,false);
            sync_guard_timer_start();
            cur_sync.sleep_history_days --;
		}
		else
		{
            if(protocol_func_table_have_heart_rate() == true)
            {
                protocol_set_sync_status(PROTOCOL_SYNC_STATUS_HISTORY_HEART_RATE);
            }
            else
            {
                protocol_set_sync_status(PROTOOCL_SYNC_STATUS_STOP);
            }
			protocol_health_next_process_sch();
		}
		break;
	case PROTOCOL_SYNC_STATUS_TODAY_HEART_RATE :
		if(cur_sync.once_sync_complete_start == true) //当次同步完成,切换到下一次任务
		{
			cur_sync.once_sync_complete_start = false;
			protocol_set_sync_status(PROTOCOL_SYNC_STATUS_HISTORY_SPORT);
			protocol_health_next_process_sch();
		}
		else
		{
			write_sync_cmd(PROTOCOL_WRITE_CMD_HEART_RATE_START,true);
            sync_guard_timer_start();
		}

		break;
	case PROTOCOL_SYNC_STATUS_HISTORY_HEART_RATE :
		if(cur_sync.once_sync_complete_start == true)
		{
			cur_sync.once_sync_complete_start = false;				
		}

		if(cur_sync.heart_rate_history_days != 0)
		{
			write_sync_cmd(PROTOCOL_WRITE_CMD_HEART_RATE_START,false);
            sync_guard_timer_start();
            cur_sync.heart_rate_history_days --;
		}
		else
		{
			protocol_set_sync_status(PROTOOCL_SYNC_STATUS_STOP);
			protocol_health_next_process_sch();
		}

		break;
	}
	return SUCCESS;
}

//延时一会儿执行
static uint32_t protocol_health_next_process_sch()
{
	return app_timer_start(delay_exec_process_timer,PROTOCOL_HEALTH_DELAY_EXEC_PROCESS_MS,NULL);
}

uint32_t protocol_health_exec(uint8_t const *data,uint8_t length)
{
    uint32_t ret_code = SUCCESS;
	if(data == NULL)
	{
		return ERROR_NULL;
	}
	if(length < sizeof(struct protocol_head))
	{
		return ERROR_DATA_SIZE;
	}
	struct protocol_sync_head *head = (struct protocol_sync_head *)data;
    struct protocol_cmd *cmd = (struct protocol_cmd *)data;
	if(head->head.cmd != PROTOCOL_CMD_HEALTH_DATA)
	{
		return SUCCESS;
	}

    
    if(
       (
        cmd->head.key == PROTOCOL_KEY_HEALTH_DATA_REQUEST)
       || (cmd->head.key == PROTOCOL_KEY_HEALTH_DATA_STOP)
       || (cmd->head.key == PROTOCOL_KEY_HEALTH_DATA_DATA_END
        )
       ||
       (
        (
        cmd->head.key == PROTOCOL_KEY_HEALTH_DATA_DAY_SPORT
        || cmd->head.key == PROTOCOL_KEY_HEALTH_DATA_DAY_SLEEP
        || cmd->head.key  == PROTOCOL_KEY_HEALTH_DATA_HISTORY_SPORT
        || cmd->head.key  == PROTOCOL_KEY_HEALTH_DATA_HISTORY_SLEEP
        || cmd->head.key  == PROTOCOL_KEY_HEALTH_DATA_DAY_HEART_RATE
        || cmd->head.key == PROTOCOL_KEY_HEALTH_DATA_HISTORY_HEART_RATE
        )
        &&
        (
         cmd->cmd1 == PROTOCOL_HEALTH_SYNC_TYPE_START
         || cmd->cmd1 == PROTOCOL_HEALTH_SYNC_TYPE_STOP
         )
        )
    )
    {
        vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY, SYNC_EVT_HEALTH_PROCESSING, data, length, &ret_code);
    }
	switch(head->head.key)
	{

	case PROTOCOL_KEY_HEALTH_DATA_REQUEST :
		{
			struct protocol_start_sync_return *sync = (struct protocol_start_sync_return *)data;

			cur_sync.sport_history_days = sync->sport_day;
			if(cur_sync.sport_history_days > PROTOCOL_HEALTH_SYNC_MAX_DAY)
			{
				cur_sync.sport_history_days = PROTOCOL_HEALTH_SYNC_MAX_DAY;
			}
			cur_sync.sleep_history_days = sync->sleep_day;
			if(cur_sync.sleep_history_days > PROTOCOL_HEALTH_SYNC_MAX_DAY)
			{
				cur_sync.sleep_history_days = PROTOCOL_HEALTH_SYNC_MAX_DAY;
			}
			cur_sync.heart_rate_history_days = sync->heart_rate_day;
			if(cur_sync.heart_rate_history_days > PROTOCOL_HEALTH_SYNC_MAX_DAY)
			{
				cur_sync.heart_rate_history_days = PROTOCOL_HEALTH_SYNC_MAX_DAY;
			}


			DEBUG_INFO("sport day = %d,sleep day = %d,heart rate = %d",cur_sync.sport_history_days,cur_sync.sleep_history_days,cur_sync.heart_rate_history_days);

			cur_sync.need_rx_all_packet = (cur_sync.sport_history_days + 1) * PROTOCOL_HEALTH_RX_SPORT_ONEDAY_PACKET
										+ (cur_sync.sleep_history_days +1) * PROTOCOL_HEALTH_RX_SLEEP_ONEDAY_PACKET;

			if(protocol_func_table_have_heart_rate() == true)
			{
				cur_sync.need_rx_all_packet += ( cur_sync.heart_rate_history_days + 1) * PROTOCOL_HEALTH_RX_HR_ONEDAY_PAKCET;
			}

			cur_sync.cur_rx_all_packet_count = 1;
			cur_sync.sync_progress_rate = 0;
			update_sync_progress_rate(false);
			protocol_set_sync_status(PROTOOCL_SYNC_STATUS_TAODAY_SPORT);
			protocol_health_next_process_sch();

			return SUCCESS;

		}
		break;
	case PROTOCOL_KEY_HEALTH_DATA_STOP : //所有同步完成
		{
            uint32_t ret_code = SUCCESS;
			cur_sync.all_sync_is_start = false;
            vbus_tx_evt(VBUS_EVT_BASE_NOTICE_APP, SYNC_EVT_HEALTH_SYNC_COMPLETE, &ret_code);
            sync_guard_timer_stop();
            update_sync_progress_rate(true);
            return SUCCESS;
            
		}
		break;

	case PROTOCOL_KEY_HEALTH_DATA_DAY_SPORT :
	case PROTOCOL_KEY_HEALTH_DATA_DAY_SLEEP :
	case PROTOCOL_KEY_HEALTH_DATA_HISTORY_SPORT :
	case PROTOCOL_KEY_HEALTH_DATA_HISTORY_SLEEP :
	case PROTOCOL_KEY_HEALTH_DATA_DAY_HEART_RATE :
	case PROTOCOL_KEY_HEALTH_DATA_HISTORY_HEART_RATE :
	{

		uint16_t tmp_total_packet = 0;



		if(cur_sync_status.rx_data_is_end == true) //同步单次完成,通知处理数据,开始下一次同步
		{
			uint32_t exec_index;
			cur_sync.once_sync_complete_start = true;

			DEBUG_INFO("rx once sync end cmd,start next sync,cur status = %d",cur_sync.status);
			switch(cur_sync.status)
			{
			case PROTOOCL_SYNC_STATUS_TAODAY_SPORT :
			case PROTOCOL_SYNC_STATUS_HISTORY_SPORT :
				exec_index = PROTOCOL_EXEC_TABLE_INDEX_SPORT;
				break;
			case PROTOOCL_SYNC_STATUS_TODAY_SLEEP :
			case PROTOOCL_SYNC_STATUS_HISTORY_SLEEP :
				exec_index = PROTOCOL_EXEC_TABLE_INDEX_SLEEP;
				break;
			case PROTOCOL_SYNC_STATUS_TODAY_HEART_RATE :
			case PROTOCOL_SYNC_STATUS_HISTORY_HEART_RATE :
				exec_index = PROTOCOL_EXEC_TABLE_INDEX_HEART_RATE;
				break;
			default :
				DEBUG_INFO("cur_sync status error ,= %d",cur_sync.status);
				return ERROR_INVALID_STATE;
			}
			DEBUG_INFO("start callback health data,index = %d",exec_index);

			if(exec_func_table[exec_index].exec_head_func != NULL)
			{
				exec_func_table[exec_index].exec_head_func(cur_sync_data.head,sizeof(cur_sync_data.head));
			}

			if(exec_func_table[exec_index].exec_data_func != NULL)
			{
				exec_func_table[exec_index].exec_data_func(cur_sync_data.data,cur_sync_status.rx_data_byte_count);
			}

			if(exec_func_table[exec_index].exec_complete_func != NULL)
			{
				exec_func_table[exec_index].exec_complete_func(SUCCESS);
			}

			DEBUG_INFO("clean cur sync data,status");
			memset(&cur_sync_data,0,sizeof(cur_sync_data));
			clean_cur_sync_status();
			protocol_health_next_process_sch();
			return SUCCESS;
		}

		if(head->serial == 0x01) //头部1
		{
			int index;
			for(index = 0 ; index < PROTOOCL_EXEC_TABLE_INDEX_MAX_SIZE; index ++)
			{
				if(exec_func_table[index].total_packet_func != NULL)
				{
					exec_func_table[index].total_packet_func((uint8_t *)data,length,&tmp_total_packet);
					if(tmp_total_packet != 0) //寻找到合适的解析器
					{
						DEBUG_INFO("find heart pack resolve ,index = %d,packet = %d,cmd=0x%02X,key=0x%02X",index,tmp_total_packet,data[0],data[1]);
						cur_sync_status.total_packet_size = tmp_total_packet;
						break;
					}
				}
			}
			memcpy(cur_sync_data.head,data,PROTOCOL_TRANSPORT_MAX_SIZE);
		}
		else if(head->serial == 0x02) //头部2
		{
			memcpy(cur_sync_data.head + PROTOCOL_TRANSPORT_MAX_SIZE,data,PROTOCOL_TRANSPORT_MAX_SIZE);
		}
		else
		{
			DEBUG_INFO("rx packet = %d, byte count = %d,cur length = %d",cur_sync_status.rx_packet_count,cur_sync_status.rx_data_byte_count ,head->length);
			//4 = 2head + serial + length
			memcpy(cur_sync_data.data + cur_sync_status.rx_data_byte_count,data + sizeof(struct protocol_sync_head),head->length);
			cur_sync_status.rx_data_byte_count += head->length;

		}

		cur_sync_status.rx_packet_count ++;
		cur_sync.cur_rx_all_packet_count ++;
		update_sync_progress_rate(false);

	}
		break;
	case PROTOCOL_KEY_HEALTH_DATA_DATA_END :
	{


		DEBUG_INFO("once rx data end,start check data check");
		//开始错误检测
		if(protocol_health_sync_data_check() == false)
		{
			//接收到的数据发生错误,开始重新获取当次的同步
			DEBUG_INFO("health data check error,total_packet_size = %d,cur packet size = %d ",cur_sync_status.total_packet_size,cur_sync_status.rx_packet_count);
			bool is_today = cur_sync_status.is_today;
			memset(&cur_sync_status,0,sizeof(cur_sync_status));
			cur_sync_status.is_today = is_today;

			memset(&cur_sync_data,0,sizeof(cur_sync_data));
			cur_sync.once_sync_complete_start = false;
			protocol_health_next_process_sch();
			return SUCCESS;
		}

		cur_sync.cur_rx_all_packet_count ++;
		//对不足的包进行填充

		cur_sync_status.rx_data_is_end = true;
		DEBUG_INFO("once rx data end,data ok,write end cmd");
		//数据没有问题,结束当次同步
		switch((uint32_t)cur_sync.status)
		{
		case PROTOOCL_SYNC_STATUS_TAODAY_SPORT :
			write_data1(PROTOCOL_CMD_HEALTH_DATA,PROTOCOL_KEY_HEALTH_DATA_DAY_SPORT,PROTOCOL_HEALTH_SYNC_TYPE_STOP);
			cur_sync.cur_rx_all_packet_count += (cur_sync_status.rx_packet_count > PROTOCOL_HEALTH_RX_SPORT_ONEDAY_PACKET) ? 0 : (PROTOCOL_HEALTH_RX_SPORT_ONEDAY_PACKET - cur_sync_status.rx_packet_count);
			break;
		case PROTOCOL_SYNC_STATUS_HISTORY_SPORT :
			write_data1(PROTOCOL_CMD_HEALTH_DATA,PROTOCOL_KEY_HEALTH_DATA_HISTORY_SPORT,PROTOCOL_HEALTH_SYNC_TYPE_STOP);
			cur_sync.cur_rx_all_packet_count += (cur_sync_status.rx_packet_count > PROTOCOL_HEALTH_RX_SPORT_ONEDAY_PACKET) ? 0 : (PROTOCOL_HEALTH_RX_SPORT_ONEDAY_PACKET - cur_sync_status.rx_packet_count);
			break;
		case PROTOOCL_SYNC_STATUS_TODAY_SLEEP :
			write_data1(PROTOCOL_CMD_HEALTH_DATA,PROTOCOL_KEY_HEALTH_DATA_DAY_SLEEP,PROTOCOL_HEALTH_SYNC_TYPE_STOP);
			cur_sync.cur_rx_all_packet_count += (cur_sync_status.rx_packet_count > PROTOCOL_HEALTH_RX_SLEEP_ONEDAY_PACKET) ? 0 : (PROTOCOL_HEALTH_RX_SLEEP_ONEDAY_PACKET - cur_sync_status.rx_packet_count);
			break;
		case PROTOOCL_SYNC_STATUS_HISTORY_SLEEP :
			write_data1(PROTOCOL_CMD_HEALTH_DATA,PROTOCOL_KEY_HEALTH_DATA_HISTORY_SLEEP,PROTOCOL_HEALTH_SYNC_TYPE_STOP);
			cur_sync.cur_rx_all_packet_count += (cur_sync_status.rx_packet_count > PROTOCOL_HEALTH_RX_SLEEP_ONEDAY_PACKET) ? 0 : (PROTOCOL_HEALTH_RX_SLEEP_ONEDAY_PACKET - cur_sync_status.rx_packet_count);
			break;
		case PROTOCOL_SYNC_STATUS_TODAY_HEART_RATE :
			write_data1(PROTOCOL_CMD_HEALTH_DATA,PROTOCOL_KEY_HEALTH_DATA_DAY_HEART_RATE,PROTOCOL_HEALTH_SYNC_TYPE_STOP);
			cur_sync.cur_rx_all_packet_count += (cur_sync_status.rx_packet_count > PROTOCOL_HEALTH_RX_HR_ONEDAY_PAKCET) ? 0 : (PROTOCOL_HEALTH_RX_HR_ONEDAY_PAKCET - cur_sync_status.rx_packet_count);
			break;
		case PROTOCOL_SYNC_STATUS_HISTORY_HEART_RATE :
			write_data1(PROTOCOL_CMD_HEALTH_DATA,PROTOCOL_KEY_HEALTH_DATA_HISTORY_HEART_RATE,PROTOCOL_HEALTH_SYNC_TYPE_STOP);
			cur_sync.cur_rx_all_packet_count += (cur_sync_status.rx_packet_count > PROTOCOL_HEALTH_RX_HR_ONEDAY_PAKCET) ? 0 : (PROTOCOL_HEALTH_RX_HR_ONEDAY_PAKCET - cur_sync_status.rx_packet_count);
			break;
		}
        
        sync_guard_timer_stop();
        update_sync_progress_rate(false);
	}
		break;

	}

	return SUCCESS;

}


uint32_t protocol_health_add_exec(uint8_t exec_index,struct protocol_health_exec_st func_st)
{
	if(exec_index >= PROTOOCL_EXEC_TABLE_INDEX_MAX_SIZE)
	{
		return ERROR_DATA_SIZE;
	}

	memcpy(&exec_func_table[exec_index],&func_st,sizeof(struct protocol_health_exec_st));
	return SUCCESS;
}



static void delay_exec_process_timer_handler(void *data)
{
	protocol_health_next_process();
}


static void sync_guard_timer_handle(void *data)
{
    uint32_t ret_code = ERROR_TIMEOUT;
    protocol_health_sync_stop();
    vbus_tx_evt(VBUS_EVT_BASE_NOTICE_APP, SYNC_EVT_HEALTH_SYNC_COMPLETE, &ret_code);
}

static uint32_t protocol_health_vbus_control(VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,void *data,uint32_t size,uint32_t *error_code)
{
    if(evt_base == VBUS_EVT_BASE_SET)
    {
        if(evt_type == SET_BLE_EVT_DISCONNECT)
        {
            protocol_health_sync_stop();
        }
    }
    else if(evt_base == VBUS_EVT_BASE_NOTICE_APP)
    {
        if((evt_type == SYNC_EVT_HEALTH_PROCESSING) && (*error_code != SUCCESS)) //同步超时
        {
            protocol_health_sync_stop();
            vbus_tx_evt(VBUS_EVT_BASE_NOTICE_APP, SYNC_EVT_HEALTH_SYNC_COMPLETE, error_code);
        }
    }
    return SUCCESS;
}

static uint32_t protocol_health_vbus_init()
{
    struct vbus_t status;
    uint32_t id;
    uint32_t err_code;
    status.control = protocol_health_vbus_control;
    status.name = "protocol health";
    err_code = vbus_reg(status,&id);
    APP_ERROR_CHECK(err);
    return SUCCESS;
}


uint32_t protocol_health_init()
{

	uint32_t err;
	memset(&exec_func_table,0,sizeof(exec_func_table));
	memset(&cur_sync_status,0,sizeof(cur_sync_status));
	memset(&cur_sync_data,0,sizeof(cur_sync_data));
	memset(&cur_sync,0,sizeof(cur_sync));

	/*test
	int index;
	for(index = 0; index < PROTOOCL_EXEC_TABLE_INDEX_MAX_SIZE; index ++)
	{
		exec_func_table[index].exec_complete_func = NULL;
		exec_func_table[index].exec_data_func = NULL;
		exec_func_table[index].exec_head_func = NULL;
		exec_func_table[index].total_packet_func = NULL;
	}
	*/
	err = app_timer_create(&delay_exec_process_timer,delay_exec_process_timer_handler);
	DEBUG_INFO("delay_exec_process_timer id = %d",delay_exec_process_timer);
	APP_ERROR_CHECK(err);
    
    err = app_timer_create(&sync_guard_timer, sync_guard_timer_handle);
    DEBUG_INFO("sync_guard_timer id = %d",sync_guard_timer);
    APP_ERROR_CHECK(err);
    
    protocol_health_vbus_init();
	return err;
}


uint32_t protocol_health_sync_start()
{
	if(cur_sync.all_sync_is_start == true)
	{
		return SUCCESS;
	}
	cur_sync.all_sync_is_start = true;
	clean_cur_sync_status();
	protocol_set_sync_status(PROTOOCL_SYNC_STATUS_START);
	protocol_health_next_process_sch();
	return SUCCESS;

}

uint32_t protocol_health_sync_stop()
{
	if(cur_sync.all_sync_is_start == false)
	{
		return SUCCESS;
	}
	cur_sync.all_sync_is_start =  false;
	sync_guard_timer_stop();
    app_timer_stop(delay_exec_process_timer);
    protocol_set_sync_status(false);
    protocol_set_sync_status(PROTOCOL_SYNC_STATUS_IDLE);
	return SUCCESS;
}


bool protocol_health_get_is_sync()
{
	return cur_sync.all_sync_is_start;
}




