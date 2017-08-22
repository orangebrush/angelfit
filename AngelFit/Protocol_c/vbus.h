

#ifndef _VBUS_H_
    #define _VBUS_H_

#include "include.h"
#include "vbus_evt_app.h"


#define USE_VBUS_OPEN_CLOSE     0
#define USE_VBUS_READ_WRITE     0



enum VBUS_DEV_TYPE
{
    VBUS_TYPE_DEVICE,
    VBUS_TYPE_MODULE,
};


typedef uint32_t  (*vbuf_rx_func_cb_t)(VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,void *data,uint32_t size,uint32_t *error_code);

struct vbus_t
{
    uint8_t bus_id;			//不使用
    const char  *name;		//名字
    #if USE_VBUS_OPEN_CLOSE
    uint32_t (*init)(int32_t arg);
    uint32_t (*open)(int32_t arg);
    uint32_t (*close)(int32_t arg);
    #endif
    #if USE_VBUS_READ_WRITE
    uint32_t (*read)(void *buff,uint32_t size,uint32_t offset);
    uint32_t (*write)(void *buff,uint32_t size,uint32_t offset);
    #endif
    uint32_t (*control)(VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,void *data,uint32_t size,uint32_t *error_code); //事件接收函数
    void *user_data;
};

#ifdef __cplusplus
extern "C" {
#endif


extern uint32_t vbus_tx_data(VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,const void *data,uint32_t size,uint32_t *error_code); //向总线发送数据
extern uint32_t vbus_tx_evt(VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,uint32_t *error_code);                          //向总线发送事件
extern uint32_t vbus_get_data(VBUS_EVT_TYPE evt_type,void *data,uint32_t size,uint32_t *error_code);  //从总线获得数据


extern uint32_t vbus_init(void);        //初始化
extern uint32_t vbus_reg(struct vbus_t dev,uint32_t *id);   //注册设备
extern uint32_t vbus_rx_evt_reg(vbuf_rx_func_cb_t func);    //向总线注册接收事件函数
extern uint32_t vbus_print_info(void);
/*
extern uint32_t vbus_tx_evt_push(uint32_t evt); //添加到队列        事件
extern uint32_t vbus_tx_data_push(uint32_t evt,void *data,uint32_t size);       //数据

*/


//寻找设备
extern uint32_t vbus_find_by_name(char *name,struct vbus_t *dev);
extern uint32_t vbus_find_by_id(uint32_t id,struct vbus_t *dev);

//操作函数
extern uint32_t vbus_dev_init(uint32_t id,int32_t arg);
extern uint32_t vbus_dev_init_all(void);
extern uint32_t vbus_dev_open(uint32_t id,int32_t arg);
extern uint32_t vbus_dev_read(uint32_t id,void *buff,uint32_t size,uint32_t offset);
extern uint32_t vbus_dev_write(uint32_t id,void *buff,uint32_t size,uint32_t offset);
extern uint32_t vbus_dev_close(uint32_t id,int32_t arg);
extern uint32_t vbus_dev_control(uint32_t id,VBUS_EVT_BASE evt_base,VBUS_EVT_TYPE evt_type,void *data,uint32_t size,uint32_t *error_code);

#ifdef __cplusplus
}
#endif

#endif
