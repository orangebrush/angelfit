//
//  Protoocl_ios.h
//  BLEProject
//
//  Created by aiju on 16/3/3.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

#ifndef Protoocl_ios_h
#define Protoocl_ios_h

#include <stdio.h>

extern uint32_t protocol_ios_port_init(void);
extern uint32_t protocol_ios_send_data(const uint8_t *data,uint16_t length);

#endif /* Protoocl_ios_h */
