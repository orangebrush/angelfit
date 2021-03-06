/*
 * protocol_switch_data.c
 *
 *  Created on: 2016年9月26日
 *      Author: Administrator
 */


 



#include "protocol_write.h"
#include "vbus.h"
#include "vbus_evt_app.h"
#include "protocol_switch_data.h"

static uint32_t protocol_switch_write_data(struct protocol_head head,const uint8_t *data,uint16_t length,bool need_resend,VBUS_EVT_TYPE evt_type)
{
	return protocol_write_set_head(head,data,length,need_resend,evt_type);
}

uint32_t protocol_switch_exec(const uint8_t *data,uint16_t length)
{
	struct protocol_head *head = (struct protocol_head *)data;
	uint32_t err_code = SUCCESS;
	if(head->cmd != PROTOCOL_CMD_SWITCH_DATA)
	{
		return SUCCESS;
	}
	switch(head->key)
	{
	case PROTOCOL_KEY_SWITCH_DATA_APP_START:
		vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SWITCH_APP_START_REPLY,data,length,&err_code);
		break;
	case PROTOCOL_KEY_SWITCH_DATA_APP_ING :
		vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SWITCH_APP_ING_REPLY,data,length,&err_code);
		break;
	case PROTOCOL_KEY_SWITCH_DATA_APP_END :
		vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SWITCH_APP_END_REPLY,data,length,&err_code);
		break;
	case PROTOCOL_KEY_SWITCH_DATA_APP_PAUSE :
		vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SWITCH_APP_PAUSE_REPLY,data,length,&err_code);
		break;
	case PROTOCOL_KEY_SWITCH_DATA_APP_RESTORE :
		vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SWITCH_APP_RESTORE_REPLY,data,length,&err_code);
		break;
	case PROTOCOL_KEY_SWITCH_DATA_BLE_START :
		vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SWITCH_BLE_START,data,length,&err_code);
		break;
	case PROTOCOL_KEY_SWITCH_DATA_BLE_ING :
		vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SWITCH_BLE_ING,data,length,&err_code);
		break;
	case PROTOCOL_KEY_SWITCH_DATA_BLE_END :
		vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SWITCH_BLE_END,data,length,&err_code);
		break;
	case PROTOCOL_KEY_SWITCH_DATA_BLE_PAUSE :
		vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SWITCH_BLE_PAUSE,data,length,&err_code);
		break;
	case PROTOCOL_KEY_SWITCH_DATA_BLE_RESTORE :
		vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SWITCH_BLE_RESTORE,data,length,&err_code);
		break;
	case PROTOCOL_KEY_SWITCH_DATA_APP_BLE_PAUSE :
		vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SWITCH_APP_BLE_PAUSE,data,length,&err_code);
		break;
	case PROTOCOL_KEY_SWITCH_DATA_APP_BLE_RESTORE :
		vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SWITCH_APP_BLE_RESTORE,data,length,&err_code);
		break;
	case PROTOCOL_KEY_SWITCH_DATA_APP_BLE_END :
		vbus_tx_data(VBUS_EVT_BASE_BLE_REPLY,VBUS_EVT_APP_SWITCH_APP_BLE_END,data,length,&err_code);
		break;

	default :
		return SUCCESS;
	}

	return err_code;
}


static uint32_t protocol_switch_vbus_control(VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,void *data,uint32_t size,uint32_t *error_code)
{
	uint32_t err_code = SUCCESS;
	bool need_re_send = false;
	if(evt_base == VBUS_EVT_BASE_SET)
	{
		struct protocol_head head;
		switch(evt_type)
		{
			case VBUS_EVT_APP_SWITCH_APP_STAERT :
				need_re_send = true;
			case VBUS_EVT_APP_SWITCH_APP_START_REPLY :
				head.cmd = PROTOCOL_CMD_SWITCH_DATA;
				head.key = PROTOCOL_KEY_SWITCH_DATA_APP_START;

				break;
			case VBUS_EVT_APP_SWITCH_APP_ING :
			case VBUS_EVT_APP_SWITCH_APP_ING_REPLY :
				head.cmd = PROTOCOL_CMD_SWITCH_DATA;
				head.key = PROTOCOL_KEY_SWITCH_DATA_APP_ING;
				break;

			case VBUS_EVT_APP_SWITCH_APP_END :
				need_re_send = true;
			case VBUS_EVT_APP_SWITCH_APP_END_REPLY :
				head.cmd = PROTOCOL_CMD_SWITCH_DATA;
				head.key = PROTOCOL_KEY_SWITCH_DATA_APP_END;
				break;

			case VBUS_EVT_APP_SWITCH_APP_PAUSE :
				need_re_send = true;
			case VBUS_EVT_APP_SWITCH_APP_PAUSE_REPLY :
				head.cmd = PROTOCOL_CMD_SWITCH_DATA;
				head.key = PROTOCOL_KEY_SWITCH_DATA_APP_PAUSE;
				break;
			case VBUS_EVT_APP_SWITCH_APP_RESTORE :
				need_re_send = true;
			case VBUS_EVT_APP_SWITCH_APP_RESTORE_REPLY :
				head.cmd = PROTOCOL_CMD_SWITCH_DATA;
				head.key = PROTOCOL_KEY_SWITCH_DATA_APP_RESTORE;
				break;
			case VBUS_EVT_APP_SWITCH_BLE_START :
			case VBUS_EVT_APP_SWITCH_BLE_START_REPLY :
				head.cmd = PROTOCOL_CMD_SWITCH_DATA;
				head.key = PROTOCOL_KEY_SWITCH_DATA_BLE_START;
				break;

			case VBUS_EVT_APP_SWITCH_BLE_ING :
			case VBUS_EVT_APP_SWITCH_BLE_ING_REPLY :
				head.cmd = PROTOCOL_CMD_SWITCH_DATA;
				head.key = PROTOCOL_KEY_SWITCH_DATA_BLE_ING;
				break;


			case VBUS_EVT_APP_SWITCH_BLE_END :
			case VBUS_EVT_APP_SWITCH_BLE_END_REPLY :
				head.cmd = PROTOCOL_CMD_SWITCH_DATA;
				head.key = PROTOCOL_KEY_SWITCH_DATA_BLE_END;
				break;

			case VBUS_EVT_APP_SWITCH_BLE_PAUSE :
			case VBUS_EVT_APP_SWITCH_BLE_PAUSE_REPLY :
				head.cmd = PROTOCOL_CMD_SWITCH_DATA;
				head.key = PROTOCOL_KEY_SWITCH_DATA_BLE_PAUSE;
				break;

			case VBUS_EVT_APP_SWITCH_BLE_RESTORE :
			case VBUS_EVT_APP_SWITCH_BLE_RESTORE_REPLY :
				head.cmd = PROTOCOL_CMD_SWITCH_DATA;
				head.key = PROTOCOL_KEY_SWITCH_DATA_BLE_RESTORE;
				break;
			case VBUS_EVT_APP_SWITCH_APP_BLE_PAUSE :
			case VBUS_EVT_APP_SWITCH_APP_BLE_PAUSE_REPLY :
				head.cmd = PROTOCOL_CMD_SWITCH_DATA;
				head.key = PROTOCOL_KEY_SWITCH_DATA_APP_BLE_PAUSE;
				break;
			case VBUS_EVT_APP_SWITCH_APP_BLE_RESTORE :
			case VBUS_EVT_APP_SWITCH_APP_BLE_RESTORE_REPLY :
				head.cmd = PROTOCOL_CMD_SWITCH_DATA;
				head.key = PROTOCOL_KEY_SWITCH_DATA_APP_BLE_RESTORE ;
				break;
			case VBUS_EVT_APP_SWITCH_APP_BLE_END :
			case VBUS_EVT_APP_SWITCH_APP_BLE_END_REPLY :
				head.cmd = PROTOCOL_CMD_SWITCH_DATA;
				head.key = PROTOCOL_KEY_SWITCH_DATA_APP_BLE_END;
				break;
				break;
			default :
				return SUCCESS;
		}
		err_code = protocol_switch_write_data(head,((uint8_t *)data) + 2,size,need_re_send,evt_type);
	}
	return err_code;
}
static uint32_t protocol_switch_vbus_init()
{
	uint32_t err_code;
	struct vbus_t vbus_id;
	uint32_t id;
	vbus_id.name = "protocol switch";
	vbus_id.control = protocol_switch_vbus_control;
	err_code = vbus_reg(vbus_id,&id);
	APP_ERROR_CHECK(err_code);


	return err_code;
}


uint32_t protocol_switch_init()
{
	protocol_switch_vbus_init();
	return SUCCESS;
}


