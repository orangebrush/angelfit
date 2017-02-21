/*
 * protocol_health_resolve_heart_rate.c
 *
 *  Created on: 2016年2月18日
 *      Author: Administrator
 */
//心率数据解析器

#define DEBUG_STR "[PROTOCOL_HEALTH_HEART_RATE]"

#include "protocol_health_resolve_heart_rate.h"



struct protocol_health_resolve_heart_rate_data_s m_heart_rate_data;
static protocol_health_resolve_heart_rate_data_handle_t m_heart_rate_data_handle = NULL;

static uint32_t protocol_health_resolve_heart_rate_exec_total_packet(uint8_t *data,uint8_t length,uint16_t *total_packet)
  {
	if(data == NULL || (total_packet == NULL))
	{
		return ERROR_NULL;
	}
	struct ble_sync_heart_rate_head *head = (struct ble_sync_heart_rate_head *)data;
	if(head->head.cmd != PROTOCOL_CMD_HEALTH_DATA &&
			((head->head.key != PROTOCOL_KEY_HEALTH_DATA_DAY_HEART_RATE) || (head->head.key != PROTOCOL_KEY_HEALTH_DATA_HISTORY_HEART_RATE)))
	{
		*total_packet = 0;
		return SUCCESS;
	}

	*total_packet = head->packets_count;
	DEBUG_INFO("protocol_health_resolve_heart_rate_exec_total_packet");
	return SUCCESS;

  }

  static uint32_t protocol_health_resolve_heart_rate_exec_head(uint8_t *data,uint16_t length)
  {
	if(data == NULL)
	{
		return ERROR_NULL;
	}
	struct ble_sync_heart_rate_head *head1 = (struct ble_sync_heart_rate_head *)data;
	struct ble_sync_heart_rate_head1 *head2 = (struct ble_sync_heart_rate_head1 *)(data + PROTOCOL_TRANSPORT_MAX_SIZE);
	DEBUG_INFO("protocol_health_resolve_heart_rate_exec_head");

	DEBUG_INFO("%d-%d-%d,silent_heart_rate=%d,items_count=%d,packets_count=%d",
			head1->year,head1->month,head1->day,head1->silent_heart_rate,head1->items_count,head1->packets_count);
	DEBUG_INFO("aerobic_mins=%d,aerobic_threshold=%d,burn_fat_mins=%d,burn_fat_threshold=%d"
			"limit_mins=%d,limit_threshold=%d",
               head2->aerobic_mins,head2->aerobic_threshold,head2->burn_fat_mins,head2->burn_fat_threshold,
					head2->limit_mins,head2->limit_threshold);

	memcpy(&m_heart_rate_data.head1,head1,sizeof(struct ble_sync_heart_rate_head));
	memcpy(&m_heart_rate_data.head2,head2,sizeof(struct ble_sync_heart_rate_head1));


	return SUCCESS;
  }

  static uint32_t protocol_health_resolve_heart_rate_exec_data(uint8_t *data,uint16_t length)
  {

	if(data == NULL)
	{
		return ERROR_NULL;
	}

	if(length == 0)
	{
		return ERROR_INVALID_LENGTH;
	}


	uint16_t index_count = length / sizeof(struct ble_sync_heart_rate_item);
	uint16_t index;
	//uint16_t byte_index = 0;
	struct  ble_sync_heart_rate_item *itme;
	if(length % sizeof(struct ble_sync_heart_rate_item))
	{
		DEBUG_INFO("protocol health length err , length = %d",length);
	}

	if(index_count > BLE_SYNC_HEART_RATE_ITEM_ONE_DAY_MAX)
	{
		DEBUG_INFO("heart rate data length error = %d",index_count);
		memset(m_heart_rate_data.items,0,sizeof(m_heart_rate_data.items));
		m_heart_rate_data.items_count = 0;
		return SUCCESS;
	}

	for(index =  0; index < index_count; index ++)
	{
		itme = (struct ble_sync_heart_rate_item *)(&data[index * sizeof(struct ble_sync_heart_rate_item)]);
		memcpy(&m_heart_rate_data.items[index],itme,sizeof(struct ble_sync_heart_rate_item));

		DEBUG_INFO("index = %d,offset = %d,data = %d",index,itme->offset,itme->data);
	}
	m_heart_rate_data.items_count = index_count;
	DEBUG_INFO("protocol_health_resolve_heart_rate_exec_data");
	return SUCCESS;
  }

  /*
   *
   * */
  static uint32_t protocol_health_resolve_heart_rate_exec_complete(uint32_t err_code)
  {
	DEBUG_INFO("protocol_health_resolve_heart_rate_exec_complete");

	if(m_heart_rate_data_handle != NULL)
	{
		m_heart_rate_data_handle(&m_heart_rate_data);
	}
    memset(&m_heart_rate_data,0,sizeof(m_heart_rate_data));
	return SUCCESS;
  }


  uint32_t protocol_health_resolve_heart_rate_init()
  {
	struct protocol_health_exec_st func;
	func.exec_complete_func = protocol_health_resolve_heart_rate_exec_complete;
	func.exec_data_func = protocol_health_resolve_heart_rate_exec_data;
	func.exec_head_func = protocol_health_resolve_heart_rate_exec_head;
	func.total_packet_func = protocol_health_resolve_heart_rate_exec_total_packet;
	protocol_health_add_exec(PROTOCOL_EXEC_TABLE_INDEX_HEART_RATE,func);
	return SUCCESS;
  }

  uint32_t protocol_health_resolve_heart_rate_reg_data_callback(protocol_health_resolve_heart_rate_data_handle_t func)
  {
	  m_heart_rate_data_handle = func;
	  return SUCCESS;
  }

