//
//  protocol_status.h
//  BLEProject
//
//  Created by aiju on 16/3/3.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

#ifndef protocol_status_h
#define protocol_status_h



#ifdef __cplusplus
extern "C" {
#endif


extern uint32_t protocol_status_init(void);
extern void protocol_status_set_photo_status(VBUS_EVT_TYPE type);
extern VBUS_EVT_TYPE protocol_status_get_photo_status(void);

extern void protocol_status_set_music_status(VBUS_EVT_TYPE type);
extern VBUS_EVT_TYPE protocol_status_get_music_status(void);

extern void protocol_status_set_find_device_status(VBUS_EVT_TYPE type);
extern VBUS_EVT_TYPE protocol_status_get_find_device_status(void);

#ifdef __cplusplus
}
#endif

#endif /* protocol_status_h */
