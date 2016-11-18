//
//  mem..h
//  BLEProject
//
//  Created by aiju on 16/3/11.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

#ifndef mem__h
#define mem__h

#include "include.h"

#ifdef __cplusplus
extern "C" {
#endif

extern bool mem_isfull(uint8_t mem_id);
extern bool mem_isempty(uint8_t mem_id);
extern uint32_t mem_init(uint8_t *buf,uint32_t buf_size,uint32_t data_size,uint8_t *mem_id);
extern bool mem_push(uint8_t mem_id,void *dat);
extern bool mem_pop(uint8_t mem_id,void *getdata);
extern uint32_t mem_getlen(uint8_t mem_id);
extern uint32_t mem_clean(uint8_t mem_id);


#ifdef __cplusplus
}
#endif

#endif /* mem__h */
