/*
 * protocol_health_resolve_sleep.c
 *
 *  Created on: 2016年2月18日
 *      Author: Administrator
 */

//睡眠数据解析器

#define DEBUG_STR "[PROTOCOL_HEALTH_SLEEP]"

#include "protocol_health_resolve_sleep.h"





static protocol_health_resolve_sleep_data_handle_t m_sleep_data_handle = NULL;
static struct  protocol_health_resolve_sleep_data_s m_sleep_data;

static uint32_t protocol_health_resolve_sleep_exec_total_packet(uint8_t *data,uint8_t length,uint16_t *total_packet)
{
	if(data == NULL || (total_packet == NULL))
	{
		return ERROR_NULL;
	}
	struct ble_sync_sleep_head *head = (struct ble_sync_sleep_head *)data;
	if(head->head.cmd != PROTOCOL_CMD_HEALTH_DATA &&
			((head->head.key != PROTOCOL_KEY_HEALTH_DATA_DAY_SLEEP) || (head->head.key != PROTOCOL_KEY_HEALTH_DATA_HISTORY_SLEEP)))
	{
		*total_packet = 0;
		return SUCCESS;
	}

	*total_packet = head->packet_count;
	DEBUG_INFO("protocol_health_resolve_sleep_exec_total_packet packet = %d",*total_packet);
	return SUCCESS;

}

static uint32_t protocol_health_resolve_sleep_exec_head(uint8_t *data,uint16_t length)
{
	if(data == NULL)
	{
		return ERROR_NULL;
	}
	struct ble_sync_sleep_head *head1 = (struct ble_sync_sleep_head *)data;
	struct ble_sync_sleep_head1 *head2 = (struct ble_sync_sleep_head1 *)(data + PROTOCOL_TRANSPORT_MAX_SIZE);
	DEBUG_INFO("protocol_health_resolve_sleep_exec_head");

	DEBUG_INFO("%d-%d-%d,end time %d:%d,total minute = %d,item count = %d",head1->date.year,head1->date.month,head1->date.day,head1->end_time_hour,head1->end_time_minute,
			head1->total_minute,head1->sleep_item_count);


	DEBUG_INFO("deep_sleep_count=%d,deep_sleep_minute=%d,light_sleep_count=%d,ligth_sleep_minute=%d,wake_count=%d",
			head2->deep_sleep_count,head2->deep_sleep_minute,head2->light_sleep_count,head2->ligth_sleep_minute,head2->wake_count);

	memcpy(&m_sleep_data.head1,head1,sizeof(struct ble_sync_sleep_head));
	memcpy(&m_sleep_data.head2,head2,sizeof(struct ble_sync_sleep_head1));

	return SUCCESS;
}

static uint32_t protocol_health_resolve_sleep_exec_data(uint8_t *data,uint16_t length)
{

	if(data == NULL)
	{
		return ERROR_NULL;
	}

	if(length == 0)
	{
		return ERROR_INVALID_LENGTH;
	}

	uint16_t index_count = length / (sizeof(struct ble_sync_sleep_item));
	uint16_t index;
	//uint16_t byte_index = 0;

	struct ble_sync_sleep_item *item;
	if(length % sizeof(struct ble_sync_sleep_item))
	{
		DEBUG_INFO("protocol health length err , length = %d",length);
	}


	if(index_count > BLE_SYNC_SLEEP_ITEM_ONE_DAY_DATA_MAX)
	{
		DEBUG_INFO("sleep data length err = %d",index_count);
		//memset(m_sleep_data.itmes,0,sizeof(m_sleep_data.itmes));
		m_sleep_data.itmes_count = 0;
		return SUCCESS;
	}

    m_sleep_data.itmes = malloc(sizeof(struct ble_sync_sleep_item) * BLE_SYNC_SLEEP_ITEM_ONE_DAY_DATA_MAX);
	for(index = 0; index < index_count; index ++)
	{
		item = (struct ble_sync_sleep_item *)(&data[index * sizeof(struct ble_sync_sleep_item)]);
		memcpy(&m_sleep_data.itmes[index],item,sizeof(struct ble_sync_sleep_item));

		DEBUG_INFO("index = %d,sleep time = %d,sleep status = %d",index,item->durations,item->sleep_status);
	}
	m_sleep_data.itmes_count = index_count;


	DEBUG_INFO("protocol_health_resolve_sleep_exec_data");
	return SUCCESS;
}

/*
 *
 * */
static uint32_t protocol_health_resolve_sleep_exec_complete(uint32_t err_code)
{
	DEBUG_INFO("protocol_health_resolve_sleep_exec_complete");

	if(m_sleep_data_handle != NULL)
	{
		m_sleep_data_handle(&m_sleep_data);
	}
    free(m_sleep_data.itmes);
    memset(&m_sleep_data,0,sizeof(m_sleep_data));
    
	return SUCCESS;
}


uint32_t protocol_health_resolve_sleep_init()
{
	struct protocol_health_exec_st func;
	func.exec_complete_func = protocol_health_resolve_sleep_exec_complete;
	func.exec_data_func = protocol_health_resolve_sleep_exec_data;
	func.exec_head_func = protocol_health_resolve_sleep_exec_head;
	func.total_packet_func = protocol_health_resolve_sleep_exec_total_packet;
	protocol_health_add_exec(PROTOCOL_EXEC_TABLE_INDEX_SLEEP,func);
	return SUCCESS;
}

uint32_t protocol_health_resolve_sleep_reg_data_callback(protocol_health_resolve_sleep_data_handle_t func)
{
	m_sleep_data_handle = func;
	return SUCCESS;
}


