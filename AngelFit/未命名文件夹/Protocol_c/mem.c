//
//  mem.c
//  BLEProject
//
//  Created by aiju on 16/3/11.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

#include "mem.h"

//队列

#define MEM_MAX_SIZE	5

static uint8_t mem_arr_count = 0;

struct mem_s{
    
    uint8_t *buf;
    uint32_t buf_size;
    uint32_t data_size;
    uint32_t mem_head;
    uint32_t mem_tail;
    uint32_t data_sum;
    uint32_t count;
};

struct mem_s mem_arr[MEM_MAX_SIZE];

bool mem_isfull(uint8_t mem_id)
{
    if(mem_id >= MEM_MAX_SIZE)
        return true;
    if(((mem_arr[mem_id].mem_tail + 1) % mem_arr[mem_id].data_sum) == mem_arr[mem_id].mem_head )
        return true;
    return false;
}

bool mem_isempty(uint8_t mem_id)
{
    if(mem_id >= MEM_MAX_SIZE)
        return true;
    if(mem_arr[mem_id].mem_tail == mem_arr[mem_id].mem_head)
        return true;
    return false;
}


uint32_t mem_init(uint8_t *buf,uint32_t buf_size,uint32_t data_size,uint8_t *mem_id)
{
    if(mem_arr_count > MEM_MAX_SIZE)
        return 1;
    
    mem_arr[mem_arr_count].buf = buf;
    mem_arr[mem_arr_count].buf_size = buf_size;
    mem_arr[mem_arr_count].data_size = data_size;
    mem_arr[mem_arr_count].mem_head = 0;
    mem_arr[mem_arr_count].mem_tail = 0;
    mem_arr[mem_arr_count].data_sum = (buf_size / data_size) - 1;
    mem_arr[mem_arr_count].count = 0;
    *mem_id = mem_arr_count;
    mem_arr_count ++;
    
    return 0;
}


bool mem_push(uint8_t mem_id,void *dat)
{
    if(mem_id >= MEM_MAX_SIZE)
        return false;
    if(mem_isfull(mem_id))
    {
        return false;
    }
    memcpy (&mem_arr[mem_id].buf[mem_arr[mem_id].mem_tail * mem_arr[mem_id].data_size],dat,mem_arr[mem_id].data_size);
    mem_arr[mem_id].mem_tail = (mem_arr[mem_id].mem_tail + 1) % mem_arr[mem_id].data_sum;
    mem_arr[mem_id].count ++;
    return true;
}



bool mem_pop(uint8_t mem_id,void *getdata)
{
    if(mem_id >= MEM_MAX_SIZE)
        return false;
    if(mem_isempty(mem_id))
    {
        return false;
    }
    memcpy(getdata,&mem_arr[mem_id].buf[mem_arr[mem_id].mem_head * mem_arr[mem_id].data_size],mem_arr[mem_id].data_size);
    mem_arr[mem_id].mem_head = (mem_arr[mem_id].mem_head  + 1) % mem_arr[mem_id].data_sum;
    mem_arr[mem_id].count --;
    return true;
}

uint32_t mem_getlen(uint8_t memid)
{
    if(memid >= MEM_MAX_SIZE)
        return 0xffff;
    return mem_arr[memid].count;
}

/*

//添加数据
uint32_t mem_add(uint8_t mem_id,void *data)
{
    bool ret;
    static uint8_t tmp[MEM_MAX_BUF];
    if(mem_id >= MEM_MAX_SIZE)
        return 1;
    if(mem_isfull(mem_id))   //如果已经满了，跌掉最前面的数据
    {
        DEBUG_INFO("data full id = %d",mem_id);
        mem_pop(mem_id,tmp);
    }
    
    ret = mem_push(mem_id,data);
    if(ret == false)
    {
        DEBUG_INFO("save data err id = %d",mem_id);
    }
    return 0;
}
*/
 
uint32_t mem_clean(uint8_t mem_id)
{
    if(mem_id >= MEM_MAX_SIZE)
        return 1;
    mem_arr[mem_id].count = 0;
    mem_arr[mem_id].mem_head = 0;
    mem_arr[mem_id].mem_tail = 0;
    return 0;
}

