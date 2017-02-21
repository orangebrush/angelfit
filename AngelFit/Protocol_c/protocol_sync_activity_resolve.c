/*
 * protocol_sync_activity_resolve.c
 *
 *  Created on: 2016年10月14日
 *      Author: Administrator
 */


//心率数据解析器



#include "protocol_sync_activity_resolve.h"

static protocol_sync_activity_resolve_data_cb_t data_handle = NULL;

static void protocol_sync_activity_data_cb_handle(const struct activity_packet_data data[],uint16_t serial_count)
{



	struct protocol_activity_data activity_data;
	memset(&activity_data,0,sizeof(activity_data));

	memcpy(&activity_data.head,&data[1].hr_data,sizeof(activity_data.head));
	memcpy(&activity_data.ex_data1,&data[2].hr_data,sizeof(activity_data.ex_data1));
	memcpy(&activity_data.ex_data2,&data[3].hr_data,sizeof(activity_data.ex_data2));

	uint16_t data_offset = 0;
	int i;
	for(i = 4; i <= activity_data.head.packet_count; i ++)
	{
		DEBUG_INFO("i = %d,length = %d",i,data[i].length);
		memcpy(activity_data.hr_value + data_offset,data[i].hr_data + 4,data[i].length);
		data_offset += data[i].length;
	}

	DEBUG_INFO("protocol_sync_activity_data_cb_handle %d-%d-%d,packet = %d,item count = %d ",activity_data.head.time.year,
			activity_data.head.time.month,activity_data.head.time.day,activity_data.head.packet_count,activity_data.head.hr_item_count);


	DEBUG_INFO("type=%d,step=%d,distance=%d,durations=%d,calories=%d",activity_data.ex_data1.type,activity_data.ex_data1.step,activity_data.ex_data1.distance,activity_data.ex_data1.durations,activity_data.ex_data1.calories);


	if(data_handle != NULL)
	{
		data_handle(&activity_data);
	}

	/*
	for( i = 0; i < activity_data.head.hr_item_count; i ++)
	{
		//DEBUG_PRINT("%d = %02X ",i,activity_data.hr_value[i]);
	}

	for( i = 0; i < sizeof(activity_data.head); i ++)
	{
		//DEBUG_INFO("%02X ",((uint8_t *)&activity_data.head)[i]);
	}

	*/
}

static uint16_t protocol_sync_activiey_get_packet_count_handle(uint8_t *data,uint16_t length)
{

	DEBUG_INFO("protocol_sync_activiey_get_packet_count_handle,data=%X,length = %d",(uint32_t *)data,length);
	if(data == NULL)
	{
		return 0;
	}

	DEBUG_INFO("%02X %02X %02X %02X",data[0],data[1],data[2],data[3]);

	struct protocol_activity_data_head *head_data = (struct protocol_activity_data_head *)data;
	return head_data->packet_count;
}

uint32_t protocol_sync_activity_resolve_data_cb_reg(protocol_sync_activity_resolve_data_cb_t func)
{
	data_handle = func;
	return SUCCESS;
}

uint32_t protocol_sync_activity_resolve_init()
{
	protocol_sync_activity_rx_data_reg(protocol_sync_activity_data_cb_handle);
	protocol_sync_activity_get_packet_reg(protocol_sync_activiey_get_packet_count_handle);
	return SUCCESS;
}

