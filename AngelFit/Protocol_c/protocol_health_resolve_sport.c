/*
 * protocol_health_resolve_sport.c
 *
 *  Created on: 2016年2月17日
 *      Author: Administrator
 *      健康数据解析器,运动
 *
 */

//运动数据解析器
#define DEBUG_STR "[PROTOCOL_HEALTH_SPORT]"

#include "protocol_health_resolve_sport.h"



static protocol_health_resolve_sport_data_handle_t m_sport_data_handle = NULL;
struct protocol_health_resolve_sport_data_s m_sport_data;

static uint32_t protocol_health_resolve_sport_exec_total_packet(uint8_t *data,uint8_t length,uint16_t *total_packet)
{
	if(data == NULL || (total_packet == NULL))
	{
		return ERROR_NULL;
	}
	struct ble_sync_sport_head *head = (struct ble_sync_sport_head *)data;
	if((head->head.cmd != PROTOCOL_CMD_HEALTH_DATA) &&
			((head->head.key != PROTOCOL_KEY_HEALTH_DATA_DAY_SPORT) || (head->head.key != PROTOCOL_KEY_HEALTH_DATA_HISTORY_SPORT)))
	{
		*total_packet = 0;
		return SUCCESS;
	}

	*total_packet = head->packet_count;
	DEBUG_INFO("protocol_health_resolve_sport_exec_total_packet,packet = %d",*total_packet);
	return SUCCESS;

}

static uint32_t protocol_health_resolve_sport_exec_head(uint8_t *data,uint16_t length)
{
	if(data == NULL)
	{
		return ERROR_NULL;
	}
	struct ble_sync_sport_head *head1 = (struct ble_sync_sport_head *)data;
	struct ble_sync_sport_head1 *head2 = (struct ble_sync_sport_head1 *)(data + PROTOCOL_TRANSPORT_MAX_SIZE);
	DEBUG_INFO("protocol_health_resolve_sport_exec_head");
	DEBUG_INFO("%d-%d-%d,item_count = %d,minute_offset = %d",
			head1->date.year,head1->date.month,head1->date.day,head1->item_count,head1->minute_offset);

	DEBUG_INFO("total_active_time=%d,total_cal=%d,total_distances=%d,total_step=%d",
			head2->total_active_time,head2->total_cal,head2->total_distances,head2->total_step);
	memcpy(&m_sport_data.head1,head1,sizeof(struct ble_sync_sport_head));
	memcpy(&m_sport_data.head2,head2,sizeof(struct ble_sync_sport_head1));
	return SUCCESS;
}

static uint32_t protocol_health_resolve_sport_exec_data(uint8_t *data,uint16_t length)
{
	if(data == NULL)
	{
		return ERROR_NULL;
	}

	if(length == 0)
	{
		return ERROR_INVALID_LENGTH;
	}

	DEBUG_INFO("protocol_health_resolve_sport_exec_data");

	uint16_t index_count = length / sizeof(struct ble_sync_sport_item);
	uint16_t index;
	//uint16_t byte_index = 0;
	struct  ble_sync_sport_item *itme;
	if(length % sizeof(struct ble_sync_sport_item))
	{
		DEBUG_INFO("protocol health length err , length = %d",length);
	}

	if(index_count > BLE_SYNC_SPORT_ONE_DAY_ITEMS_MAX)
	{
		DEBUG_INFO("sport data length error = %d,",index_count);
		memset(m_sport_data.items,0,sizeof(m_sport_data.items));
		m_sport_data.items_count = 0;
		return SUCCESS;
	}
    m_sport_data.items = malloc(sizeof(struct ble_sync_sport_item ) * BLE_SYNC_SPORT_ONE_DAY_ITEMS_MAX);
    if(m_sport_data.items == NULL)
    {
        return ERROR_NULL;
    }
	for(index =  0; index < index_count; index ++)
	{
		itme = (struct ble_sync_sport_item *)(&data[index * sizeof(struct ble_sync_sport_item)]);
		memcpy(&m_sport_data.items[index],itme,sizeof(struct ble_sync_sport_item));

		DEBUG_INFO("index = %d,step = %d",index,itme->sport_count);
	}
	m_sport_data.items_count = index_count;
	return SUCCESS;
}

/*
 *
 * */
static uint32_t protocol_health_resolve_sport_exec_complete(uint32_t err_code)
{
	DEBUG_INFO("protocol_health_resolve_sport_exec_complete");

	if(m_sport_data_handle != NULL)
	{
		m_sport_data_handle(&m_sport_data);
	}
    free(m_sport_data.items);
    memset(&m_sport_data,0,sizeof(m_sport_data));
    
	return SUCCESS;
}


uint32_t protocol_health_resolve_sport_init()
{
	struct protocol_health_exec_st func;
	func.exec_complete_func = protocol_health_resolve_sport_exec_complete;
	func.exec_data_func = protocol_health_resolve_sport_exec_data;
	func.exec_head_func = protocol_health_resolve_sport_exec_head;
	func.total_packet_func = protocol_health_resolve_sport_exec_total_packet;
	memset(&m_sport_data,0,sizeof(m_sport_data));
	protocol_health_add_exec(PROTOCOL_EXEC_TABLE_INDEX_SPORT,func);
	return SUCCESS;
}

uint32_t protoocl_health_resolve_sport_reg_data_callback(protocol_health_resolve_sport_data_handle_t func)
{
	m_sport_data_handle = func;
	return SUCCESS;
}
