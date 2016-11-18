/*
 * protocol_send_notice.c
 *
 *  Created on: 2016年3月29日
 *      Author: Administrator
 */

//#include "jni.h"
#include "include.h"
#include "mem.h"
#include "protocol.h"
#include "protocol_write.h"

#include "protocol_send_notice.h"

#define PROTOCOL_NOTICE_ONE_PACK_SZIE		16
#define PROTOCOL_NOTICE_BUF_MAX_ITEM		5

 #pragma pack(1)

struct notice_head
{
	struct protocol_head cmd_head;
	uint8_t total;
	uint8_t serial;
};

struct notice_call_head
{
	uint8_t phone_number_length;
	uint8_t contact_length;
};

struct notice_msg_head
{
	uint8_t type;
	uint8_t data_length;
	uint8_t phone_number_length;
	uint8_t contact_length;
};

struct notice_send_packet
{
	struct notice_head head;
	uint8_t buf[16];
};

#pragma pack()



struct protocol_notice_send_buf_s
{
	uint8_t all_total;
	uint8_t cur_serial;
	uint32_t type;
	uint8_t send_buf[sizeof(struct protocol_notice_s) + 100];
	uint16_t send_buf_length;
	bool is_sending;
};

static uint8_t send_notice_mem_id;


static struct protocol_notice_s cur_send_data;  //保存的原始数据
static struct protocol_notice_send_buf_s protocol_notice_send_buf; //发送缓存


static uint32_t protocol_send_notice_start(void);
static uint32_t protocol_send_notice_process(void);


static bool is_notice_type_call(uint32_t type)
{
	if((type & 0xff00) == (uint32_t)PROTOCOL_SEND_NOTICE_TYPE_CALL)
		return true;
	return false;
}

static bool is_notice_type_msg(int type)
{
	if((type & 0xff00) == (uint32_t)PROTOCOL_SEND_NOTICE_TYPE_MSG)
		return true;
	return false;
}


static uint32_t protocol_send_notice_make_buf()
{

	if(is_notice_type_call(cur_send_data.type) == true)
	{
		struct notice_call_head call_head;
		memset(&call_head,0,sizeof(call_head));

		call_head.contact_length = cur_send_data.contact_text_length;
		call_head.phone_number_length = cur_send_data.Phone_number_length;
		protocol_notice_send_buf.type =cur_send_data.type;
		memcpy(protocol_notice_send_buf.send_buf,&call_head,sizeof(call_head));
		memcpy(protocol_notice_send_buf.send_buf + sizeof(call_head),cur_send_data.Phone_number,cur_send_data.Phone_number_length);
		memcpy(protocol_notice_send_buf.send_buf + sizeof(call_head) + cur_send_data.Phone_number_length,cur_send_data.contact_text,cur_send_data.contact_text_length);

		protocol_notice_send_buf.send_buf_length = sizeof(call_head) + cur_send_data.Phone_number_length + cur_send_data.contact_text_length;
		DEBUG_INFO("send notice make buf,type = call,length = protocol_notice_send_buf.send_buf_length");

	}
	else if(is_notice_type_msg(cur_send_data.type) == true)
	{
		struct notice_msg_head msg_head;
		memset(&msg_head,0,sizeof(msg_head));
		msg_head.type = (uint8_t)(cur_send_data.type & 0x00ff);
		msg_head.contact_length = cur_send_data.contact_text_length;
		msg_head.data_length = cur_send_data.data_text_length;
		msg_head.phone_number_length = cur_send_data.Phone_number_length;
		protocol_notice_send_buf.type =cur_send_data.type;
		memcpy(protocol_notice_send_buf.send_buf,&msg_head,sizeof(msg_head));
		memcpy(protocol_notice_send_buf.send_buf + sizeof(msg_head),cur_send_data.Phone_number,cur_send_data.Phone_number_length);
		memcpy(protocol_notice_send_buf.send_buf + sizeof(msg_head) + cur_send_data.Phone_number_length,cur_send_data.contact_text,cur_send_data.contact_text_length);
		memcpy(protocol_notice_send_buf.send_buf + sizeof(msg_head) + cur_send_data.Phone_number_length + cur_send_data.contact_text_length,cur_send_data.data_text,cur_send_data.data_text_length);
		protocol_notice_send_buf.send_buf_length = sizeof(msg_head) + cur_send_data.Phone_number_length + cur_send_data.contact_text_length + cur_send_data.data_text_length;
		DEBUG_INFO("send notice make buf,type = msg,length = protocol_notice_send_buf.send_buf_length");

	}

	protocol_notice_send_buf.cur_serial = 1;
	protocol_notice_send_buf.all_total = protocol_notice_send_buf.send_buf_length / PROTOCOL_NOTICE_ONE_PACK_SZIE;
	if(protocol_notice_send_buf.send_buf_length % PROTOCOL_NOTICE_ONE_PACK_SZIE != 0)
	{
		protocol_notice_send_buf.all_total ++;
	}
	DEBUG_INFO("send notice make buf,total = %d,type = 0x%X,",protocol_notice_send_buf.all_total,cur_send_data.type);
	return SUCCESS;
}




static uint32_t protocol_send_notice_buf(uint8_t serial)
{
	struct notice_send_packet buf;
	uint8_t *pack_byte_buf = (uint8_t *)&buf;
	DEBUG_INFO("protocol_send_notice_buf serial = %d,total = %d",serial,protocol_notice_send_buf.all_total);
	if(serial > protocol_notice_send_buf.all_total) //发送完成;
	{
		uint32_t ret_code = SUCCESS;
		vbus_tx_evt(VBUS_EVT_BASE_NOTICE_APP,is_notice_type_call(protocol_notice_send_buf.type) == true ? VBUS_EVT_APP_SET_NOTICE_CALL : VBUS_EVT_APP_SET_NOTICE_MSG,&ret_code);
		protocol_send_notice_process();

		return SUCCESS;
	}
	protocol_notice_send_buf.cur_serial = serial;
	memset(&buf,0,sizeof(buf));
	buf.head.total = protocol_notice_send_buf.all_total;
	buf.head.serial = protocol_notice_send_buf.cur_serial;
	memcpy(&buf.buf,protocol_notice_send_buf.send_buf + (serial - 1) * PROTOCOL_NOTICE_ONE_PACK_SZIE,PROTOCOL_NOTICE_ONE_PACK_SZIE);
	if(is_notice_type_call(protocol_notice_send_buf.type) == true)
	{
		buf.head.cmd_head.cmd = PROTOCOL_CMD_MSG;
		buf.head.cmd_head.key = PROTOCOL_KEY_MSG_CALL;
		protocol_write_set_cmd_key(buf.head.cmd_head.cmd,buf.head.cmd_head.key,pack_byte_buf + 2,sizeof(struct notice_send_packet),true,VBUS_EVT_APP_SET_NOTICE_CALL_PROCESSING);
	}
	else if(is_notice_type_msg(protocol_notice_send_buf.type) == true)
	{
		buf.head.cmd_head.cmd = PROTOCOL_CMD_MSG;
		buf.head.cmd_head.key = PROTOCOL_KEY_MSG_SMS;
		protocol_write_set_cmd_key(buf.head.cmd_head.cmd,buf.head.cmd_head.key,pack_byte_buf + 2,sizeof(struct notice_send_packet),true,VBUS_EVT_APP_SET_NOTICE_MSG_PROCESSING);
	}
	else
	{
		DEBUG_INFO("send notice error,invalid type , = %d",protocol_notice_send_buf.type);
		return ERROR_INVALID_PARAM;
	}

	return SUCCESS;

}

static uint32_t protocol_send_notice_process()
{
	if(mem_isempty(send_notice_mem_id) == false)
	{
		mem_pop(send_notice_mem_id,&cur_send_data);
		protocol_send_notice_make_buf();
		protocol_send_notice_start();
	}
	return SUCCESS;
}

static uint32_t protocol_send_notice_start()
{
	protocol_send_notice_buf(1);
	return SUCCESS;
}

static uint32_t protocol_send_notice_stop()
{
	return SUCCESS;
}

uint32_t protocol_send_notice_add(struct protocol_notice_s *data)
{
	struct protocol_notice_s tmp;
	if(mem_isfull(send_notice_mem_id) == true)
	{
		mem_pop(send_notice_mem_id,&tmp);
	}
	DEBUG_INFO("add notice ,type = 0x%X,Phone_number_length = %d,contact_text_length=%d，data_text_length=%d",data->type,data->Phone_number_length,data->contact_text_length,data->data_text_length);
	mem_push(send_notice_mem_id,data);
	protocol_send_notice_process();

	return SUCCESS;
}

static uint32_t protocol_send_notice_control(VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,void *data,uint32_t size,uint32_t *error_code)
{
	if(evt_base == VBUS_EVT_BASE_BLE_REPLY)
	{


		if(((evt_type == VBUS_EVT_APP_SET_NOTICE_CALL_PROCESSING) && (is_notice_type_call(protocol_notice_send_buf.type) == true))
		|| ((evt_type == VBUS_EVT_APP_SET_NOTICE_MSG_PROCESSING) && (is_notice_type_msg(protocol_notice_send_buf.type) == true)))
		{
			struct notice_head *head = (struct notice_head *)data;
			if(head->serial == protocol_notice_send_buf.cur_serial)
			{
				protocol_send_notice_buf(head->serial + 1); //发送下一个
			}
		}


	}
	else if(evt_base == VBUS_EVT_BASE_NOTICE_APP)
	{
		if((evt_type == VBUS_EVT_APP_SET_NOTICE_CALL_PROCESSING || evt_type == VBUS_EVT_APP_SET_NOTICE_MSG_PROCESSING) && (*error_code != SUCCESS)) //同步失败
		{
			protocol_send_notice_stop();
		}
	}


	return SUCCESS;
}

static uint32_t protocol_send_notice_vbus_init()
{
	uint32_t err_code;
	struct vbus_t vbus_id;
	uint32_t id;
	vbus_id.name = "protocol send notice";
	vbus_id.control = protocol_send_notice_control;
	err_code = vbus_reg(vbus_id,&id);
	APP_ERROR_CHECK(err_code);


	return err_code;
}


uint32_t protocol_send_notice_init()
{
	static uint8_t mem_buf[sizeof(struct protocol_notice_s) * PROTOCOL_NOTICE_BUF_MAX_ITEM];
	mem_init(mem_buf,sizeof(mem_buf),sizeof(struct protocol_notice_s),&send_notice_mem_id);
	protocol_send_notice_vbus_init();
	memset(&protocol_notice_send_buf,0,sizeof(protocol_notice_send_buf));
	memset(&cur_send_data,0,sizeof(cur_send_data));
	return SUCCESS;
}
