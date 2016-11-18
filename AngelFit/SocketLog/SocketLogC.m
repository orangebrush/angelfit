//
//  SocketLogC.m
//  BLEProject
//
//  Created by aiju on 16/3/22.
//  Copyright © 2016年 aiju_huangjing1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketLog.h"

void socket_debug_print(const char *format, ...)
{
    char strbuf[1024 * 2];
    va_list arg;
    va_start(arg, format);
    vsprintf(strbuf, format, arg);
    va_end(arg);
    SocketLog *socketLog = [SocketLog shareInstance];
    NSString *nsstr = [NSString stringWithUTF8String:strbuf];
    NSData *data = [nsstr dataUsingEncoding:NSUTF8StringEncoding];
    [socketLog writeData:data];
}