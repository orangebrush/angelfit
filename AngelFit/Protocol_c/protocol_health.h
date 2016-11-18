/*
 * protocol_health.h
 *
 *  Created on: 2016年2月17日
 *      Author: Administrator
 */

#ifndef PROTOCOL_HEALTH_H_
#define PROTOCOL_HEALTH_H_


#define PROTOCOL_HEALTH_SYNC_TYPE_START		0x01
#define PROTOCOL_HEALTH_SYNC_TYPE_STOP		0x02
#define PROTOCOL_HEALTH_SYNC_TYPE_RESEDN	0x03


//解析器索引
#define PROTOCOL_EXEC_TABLE_INDEX_SPORT				0x00
#define PROTOCOL_EXEC_TABLE_INDEX_SLEEP				0x01
#define PROTOCOL_EXEC_TABLE_INDEX_HEART_RATE		0x02
#define PROTOOCL_EXEC_TABLE_INDEX_MAX_SIZE			0x03

typedef enum
{
	PROTOCOL_WRITE_CMD_START,
	PROTOCOL_WRITE_CMD_STOP,
	PROTOCOL_WRITE_CMD_SPORT_START,
	PROTOCOL_WRITE_CMD_SPORT_STOP,
	PROTOCOL_WRITE_CMD_SLEEP_START,
	PROTOCOL_WRITE_CMD_SLEEP_STOP,
	PROTOCOL_WRITE_CMD_HEART_RATE_START,
	PROTOCOL_WRITE_CMD_HEART_RATE_STOP
}protoocl_sync_cmd;

typedef enum
{
	PROTOOCL_SYNC_STATUS_START,
	PROTOOCL_SYNC_STATUS_STOP,
	PROTOOCL_SYNC_STATUS_TAODAY_SPORT,
	PROTOCOL_SYNC_STATUS_HISTORY_SPORT,
	PROTOOCL_SYNC_STATUS_TODAY_SLEEP,
	PROTOOCL_SYNC_STATUS_HISTORY_SLEEP,
	PROTOCOL_SYNC_STATUS_TODAY_HEART_RATE,
	PROTOCOL_SYNC_STATUS_HISTORY_HEART_RATE,
    PROTOCOL_SYNC_STATUS_IDLE,
}protocol_sync_status;


/*
 *解析器,用来获取总包数
 * */
typedef uint32_t (*protocol_health_exec_total_packet_evt)(uint8_t *data,uint8_t length,uint16_t *total_packet);
/*
 * 解析器,用来处理头部数据
 * */
typedef uint32_t (*protocol_health_exec_head_evt)(uint8_t *data,uint16_t length);
/*
 * 解析器,处理数据详情
 * */
typedef uint32_t (*protocol_health_exec_data_evt)(uint8_t *data,uint16_t length);

/*
 * 解析器,解析完成
 * */
typedef uint32_t (*protocol_health_exec_complete_evt)(uint32_t err_code);




struct protocol_health_exec_st
{
	protocol_health_exec_total_packet_evt total_packet_func;
	protocol_health_exec_head_evt exec_head_func;
	protocol_health_exec_data_evt exec_data_func;
	protocol_health_exec_complete_evt exec_complete_func;
};



#ifdef __cplusplus
extern "C" {
#endif

extern uint32_t protocol_health_add_exec(uint8_t exec_index,struct protocol_health_exec_st func_st); //添加数据解析器
extern bool protocol_health_get_is_sync(void);	//获得同步状态
extern uint32_t protocol_health_sync_stop(void); //接收同步
extern uint32_t protocol_health_sync_start(void); //开始同步
extern uint32_t protocol_health_init(void);
extern uint32_t protocol_health_exec(uint8_t const *data,uint8_t length);

#ifdef __cplusplus
}
#endif

#endif /* PROTOCOL_HEALTH_H_ */
