/*
 * protocol_exec.h
 *
 *  Created on: 2016年1月8日
 *      Author: Administrator
 */



#ifndef _PROTOCOL_EXEC_H_
#define _PROTOCOL_EXEC_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "include.h"
#include "protocol.h"
extern uint32_t protocol_cmd_exec( uint8_t const *data,uint16_t length);


#ifdef __cplusplus
}
#endif

#endif
