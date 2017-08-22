

#include "vbus.h"


#define VBUS_MAX_SUM                 18
#define VBUS_DATA_MAX_SIZE          22
#define VBUS_DEBUG                   0

struct vbus_sch_data
{
	VBUS_EVT_BASE evt_base;
	VBUS_EVT_TYPE evt_type;
    uint8_t *data;
};



static struct vbus_t m_bus_table[VBUS_MAX_SUM]; //保存总线上的所有的设备
static volatile uint32_t m_bus_table_count = 0;

static vbuf_rx_func_cb_t m_rx_func_table[VBUS_MAX_SUM]; //接收总线数据的回调
static volatile uint32_t m_rx_func_table_count = 0;


static uint32_t vbus_tx_evt_process(VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,const void *data,uint32_t size,uint32_t *error_code)
{

	int i;
    for(i = 0; i < m_bus_table_count; i ++)
    {
        if(m_bus_table[i].control != NULL)
        {
            #if VBUS_DEBUG
            if(m_bus_table[i].name != NULL)
            {
                DEBUG_INFO("vbus process = %s",m_bus_table[i].name);
            }
            #endif
            m_bus_table[i].control(evt_base,evt_type,(void *)data,size,error_code);
        }
    }
    for(i = 0; i < m_rx_func_table_count; i ++)
    {
        if(m_rx_func_table[i] != NULL)
        {
            m_rx_func_table[i](evt_base,evt_type,(void *)data,size,error_code);
        }
    }
    return SUCCESS;
}

/*
static void vbus_tx_evt_process_sch(void * p_event_data, uint16_t event_size)
{
    struct vbus_sch_data *data = (struct vbus_sch_data *)p_event_data;
    vbus_tx_evt_process(data->cmd,data->data,event_size - sizeof(uint32_t));
}
*/

uint32_t vbus_init()
{
    memset(m_bus_table,0,sizeof(m_bus_table));
    memset(m_rx_func_table,0,sizeof(m_rx_func_table));
    return SUCCESS;
}

uint32_t vbus_reg(struct vbus_t dev,uint32_t *id)
{
    if(m_bus_table_count >= VBUS_MAX_SUM)
    {
        return ERROR_NO_MEM;
    }
    memcpy(&m_bus_table[m_bus_table_count],&dev,sizeof(struct vbus_t));
    m_bus_table[m_bus_table_count].bus_id = m_bus_table_count;
    *id = m_bus_table_count;
    m_bus_table_count ++;
    return SUCCESS;
}

uint32_t vbus_rx_evt_reg(vbuf_rx_func_cb_t func)
{
    if(m_rx_func_table_count >= VBUS_MAX_SUM)
    {
        return ERROR_NO_MEM;
    }
    m_rx_func_table[m_rx_func_table_count] = func;
    m_rx_func_table_count ++;
    return SUCCESS;
}

uint32_t vbus_tx_evt(VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,uint32_t *error_code)
{
    return vbus_tx_evt_process(evt_base,evt_type,NULL,0,error_code);
}


uint32_t vbus_tx_data(VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,const void *data,uint32_t size,uint32_t *error_code)
{
    return vbus_tx_evt_process(evt_base,evt_type,data,size,error_code);
}

uint32_t vbus_get_data(VBUS_EVT_TYPE evt_type,void *data,uint32_t size ,uint32_t *error_code)
{
    return vbus_tx_evt_process(VBUS_EVT_BASE_APP_GET,evt_type,data,size,error_code);
}

/*
uint32_t vbus_tx_evt_push(uint32_t evt)
{
    uint32_t err;
    struct vbus_sch_data push_data;
    push_data.cmd = evt;
    err = app_sched_event_put(&push_data,sizeof(push_data),vbus_tx_evt_process_sch);
    APP_ERROR_CHECK(err);
    return 0;
}

uint32_t vbus_tx_data_push(uint32_t evt,void *data,uint32_t size)
{
    uint32_t err;
    struct vbus_sch_data push_data;
    if(size > VBUS_DATA_MAX_SIZE)
    {
        return 0;
        
    }
    
    push_data.cmd = evt;
    memcpy(push_data.data,data,size);
    err = app_sched_event_put(&push_data,sizeof(push_data),vbus_tx_evt_process_sch);
    APP_ERROR_CHECK(err);
    return 0;
}
*/


uint32_t vbus_find_by_name(char *name,struct vbus_t *dev)
{
	int i;
    for(i = 0; i < m_bus_table_count; i ++)
    {
        if(strcmp(m_bus_table[i].name,name) == 0)
        {
            memcpy(dev,&m_bus_table[i],sizeof(struct vbus_t));
            return 0;
        }
    }
    return 1;
}

uint32_t vbus_find_by_id(uint32_t id,struct vbus_t *dev)
{
	int i;
    for(i = 0; i < m_bus_table_count; i ++)
    {
        if(m_bus_table[i].bus_id == id)
        {
            memcpy(dev,&m_bus_table[i],sizeof(struct vbus_t));
            return SUCCESS;
        }
    }
    return ERROR_NOT_FIND;
}


uint32_t vbus_print_info()
{
    DEBUG_INFO("vbus print info :");
    int i;
    for(i = 0; i < m_bus_table_count; i ++)
    {
        DEBUG_INFO("%d:%s",m_bus_table[i].bus_id,m_bus_table[i].name);
    }
    //DEBUG_INFO("");
    return SUCCESS;
}


#if USE_VBUS_READ_WRITE
uint32_t vbus_dev_read(uint32_t id,void *buff,uint32_t size,uint32_t offset)
{
    if(m_bus_table[id].read == NULL)
    {
        return NRF_ERROR_NOT_FOUND;
    }
    return m_bus_table[id].read(buff,size,offset);
}

uint32_t vbus_dev_write(uint32_t id,void *buff,uint32_t size,uint32_t offset)
{
    if(m_bus_table[id].write == NULL)
    {
        return NRF_ERROR_NOT_FOUND;
    }
    return m_bus_table[id].write(buff,size,offset);
}
#endif

#if USE_VBUS_OPEN_CLOSE

uint32_t vbus_dev_init(uint32_t id,int32_t arg)
{
    if(m_bus_table[id].init == NULL)
    {
        return NRF_ERROR_NOT_FOUND;
    }
    return m_bus_table[id].init(arg);
}

uint32_t vbus_dev_init_all()
{
    return NRF_SUCCESS;
}

uint32_t vbus_dev_open(uint32_t id,int32_t arg)
{
    if(m_bus_table[id].open == NULL)
    {
        return NRF_ERROR_NOT_FOUND;
    }
    return m_bus_table[id].open(arg);
}

uint32_t vbus_dev_close(uint32_t id,int32_t arg)
{
    if(m_bus_table[id].close == NULL)
    {
        return NRF_ERROR_NOT_FOUND;
    }
    return m_bus_table[id].close(arg);
}
#endif

uint32_t vbus_dev_control(uint32_t id,VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,void *data,uint32_t size,uint32_t *error_code)
{
    if(m_bus_table[id].control == NULL)
    {
        return ERROR_NULL;
    }
    return m_bus_table[id].control(evt_base,evt_type,data,size,error_code);
}

