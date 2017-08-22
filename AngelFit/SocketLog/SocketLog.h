//
//  NSObject+SocketLog.h
//  SocketServiceMac
//
//  Created by aiju on 16/3/21.
//  Copyright © 2016年 aiju. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@class  SocketLog;

@interface SocketLog : NSObject <NSNetServiceDelegate>

- (void)delegate :(id)aDelegate;

- (NSString *)localIpAddr; //本地的ip地址
- (uint16_t)localPort;   //本地的端口

- (NSString *)connectedHost; //远程的ip地址
- (uint16_t )connectedPort;  //远程的端口号

- (BOOL)isConnected;
- (void)writeData :(NSData *) data; //写数据

- (void)Disconnect;  //主动断开

+ (SocketLog *)shareInstance;
@end


@protocol SocketLogDelegate <NSObject>

- (void)didReadData : (NSData *)data;  //接受到数据
- (void)didConnect : (NSString *)ipAddr : (uint16_t)port; //被连接
- (void)didDisConnect;  //被断开
@end
