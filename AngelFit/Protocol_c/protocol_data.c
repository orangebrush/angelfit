/*
 * protocol_data.c
 *
 *  Created on: 2016年1月22日
 *      Author: Administrator
 */


//全局变量维护

#include "protocol_data.h"

static volatile PROTOCOL_MODE m_mode = PROTOCOL_MODE_BIND;

uint32_t protocol_set_mode(PROTOCOL_MODE mode)
{
    m_mode = mode;
    if(m_mode == PROTOCOL_MODE_UNBIND)
    {
        DEBUG_INFO("set unbind mode");
    }
    else if(m_mode == PROTOCOL_MODE_BIND)
    {
        DEBUG_INFO("set bind mode");
    }
    else if(m_mode == PROTOCOL_MODE_OTA)
    {
        DEBUG_INFO("set ota mode");
    }
    return SUCCESS;
}

PROTOCOL_MODE protoocl_get_mode()
{
    return m_mode;
}

