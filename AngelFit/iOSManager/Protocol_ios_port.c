//
//  Protoocl_ios.c
//  BLEProject
//
//  Created by aiju on 16/3/3.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

#include "Protocol_ios_port.h"
#include "include.h"
#include "vbus.h"
#include "Cfunc.h"


static uint32_t protocol_ios_vbus_control(VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,void *data,uint32_t size,uint32_t *error_code)
{
    
    if(evt_base == VBUS_EVT_BASE_APP_SET)
    {
        vbus_tx_data(VBUS_EVT_BASE_SET, evt_type,data, size,error_code);
    }
    else if(evt_base == VBUS_EVT_BASE_APP_GET)
    {
        vbus_tx_data(VBUS_EVT_BASE_GET, evt_type, data, size,error_code);
    }
    else if(evt_base == VBUS_EVT_BASE_BLE_REPLY)
    {
        vbus_tx_data(VBUS_EVT_BASE_NOTICE_APP,evt_type,data,size,error_code);
    }
    
    return SUCCESS;
}

static uint32_t protocol_ios_vbus_init()
{
    struct vbus_t vbus;
    uint32_t id;
    uint32_t err_code;
    vbus.control = protocol_ios_vbus_control;
    vbus.name = "protocol ios";
    err_code = vbus_reg(vbus,&id);
    APP_ERROR_CHECK(err);
    
    return SUCCESS;
}

uint32_t protocol_ios_send_data(const uint8_t *data,uint16_t length)
{
    
    
    if(data[0] == 0x08)
    {
        ble_send_health_data(data, length);
    }
    else
    {
        ble_send_command_data(data,length);
    }
    return SUCCESS;
}

uint32_t protocol_ios_port_init()
{
    protocol_ios_vbus_init();
    return SUCCESS;
}


