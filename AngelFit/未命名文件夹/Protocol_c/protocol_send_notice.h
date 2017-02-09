/*
 * protocol_send_notice.h
 *
 *  Created on: 2016年4月7日
 *      Author: Administrator
 */

#ifndef PROTOCOL_SEND_NOTICE_H_
#define PROTOCOL_SEND_NOTICE_H_

#ifdef __cplusplus
extern "C" {
#endif


#define PROTOCOL_SEND_NOTICE_TYPE_CALL		0xF100
#define PROTOCOL_SEND_NOTICE_TYPE_MSG		0xF200

struct protocol_notice_s
{
	uint8_t contact_text[100];
	uint8_t contact_text_length;

	uint8_t Phone_number[20];
	uint8_t Phone_number_length;

	uint8_t data_text[100];
	uint8_t data_text_length;

	uint32_t type;

};

extern uint32_t protocol_send_notice_init(void);

extern uint32_t protocol_send_notice_add(struct protocol_notice_s *data);

#ifdef __cplusplus
}
#endif

#endif /* PROTOCOL_SEND_NOTICE_H_ */
