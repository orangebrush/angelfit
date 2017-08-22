//
//  config.h
//  BLEProject
//
//  Created by aiju on 16/3/9.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

//配置
#ifndef config_h
#define config_h

#define PROTOCOL_ANDROID 		0
#define PROTOCOL_IOS			1


//定义版本
#define VERSION_MAJOR           1
#define VERSION_MINOR           1
#define VERSION_IS_RELEASE      0   //(bool ,0 or 1)
#define VERSION_DATE            201600623



#if (PROTOCOL_ANDROID==0)&&(PROTOCOL_IOS==0)
#error "PROTOCOL_ANDROID = 0 && PROTOCOL_IOS == 0"
#endif

#if (PROTOCOL_ANDROID==1) && (PROTOCOL_IOS == 1)
#error "PROTOCOL_ANDROID = 1 && PROTOCOL_IOS == 1"
#endif

#endif /* config_h */
