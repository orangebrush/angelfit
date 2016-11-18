//
//  NSObject+SocketLog.m
//  SocketServiceMac
//
//  Created by aiju on 16/3/21.
//  Copyright © 2016年 aiju. All rights reserved.
//

#import "SocketLog.h"
#include <ifaddrs.h>
#include <arpa/inet.h>


#define WELCOME_MSG  0
#define ECHO_MSG     1
#define WARNING_MSG  2
#define TEST_MSG     3
#define TEXT_LOG     4

#define READ_TIMEOUT -1
#define READ_TIMEOUT_EXTENSION 10.0

@interface SocketLog()

@property (nonatomic,strong)  GCDAsyncSocket *asyncSocket;
@property (nonatomic,strong)  GCDAsyncSocket *curConnect; //当前链接
@property (nonatomic,weak)    id<SocketLogDelegate> delegate;


@end

@implementation  SocketLog
@synthesize asyncSocket,curConnect,delegate;
- (id) init
{
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    self = [super init];
    if(self)
    {
    
        NSError *err = nil;
        if ([asyncSocket acceptOnPort:54145 error:&err])
        {
            // So what port did the OS give us?
            
            UInt16 port = [asyncSocket localPort];
            
           // NSLog(@"ip = %@, port = %d",[self localIpAddr],port);
            
        }
        else
        {
           // NSLog(@"Error in acceptOnPort:error: -> %@", err);
        }
        
        
    }
    return self;
}


+ (SocketLog *)shareInstance
{
    static SocketLog *socketLog = nil;
    static dispatch_once_t once;
    dispatch_once( &once, ^{
        socketLog = [[self alloc] init];
    });
    return socketLog;
}

- (void)delegate :(id)aDelegate
{
    self->delegate = aDelegate;
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"Accepted new socket from %@:%hu", [newSocket connectedHost], [newSocket connectedPort]);
    
    // The newSocket automatically inherits its delegate & delegateQueue from its parent.
    
    NSString *welcomeMsg = @"Welcome to the Socket Log,use Utf-8\r\n";
    NSData *welcomeData = [welcomeMsg dataUsingEncoding:NSUTF8StringEncoding];
    
    [newSocket writeData:welcomeData withTimeout:-1 tag:WELCOME_MSG];
    
    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
    
    curConnect = newSocket;
    
    [delegate didConnect:[newSocket connectedHost] : [newSocket connectedPort]];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    
    NSLog(@"socketDidDisconnect");
    
    [delegate didDisConnect];
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    // This method is executed on the socketQueue (not the main thread)
    /*
     dispatch_async(dispatch_get_main_queue(), ^{
     @autoreleasepool {
     }
     });
     */
    NSData *readData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
    //NSLog(@"read data = %@",readData);
    //重新开始读取信息
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
    
    // Echo message back to client
    //[sock writeData:data withTimeout:-1 tag:ECHO_MSG];
    
    [delegate didReadData:readData];
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    if (elapsed <= READ_TIMEOUT)
    {
        NSString *warningMsg = @"Are you still there?\r\n";
        NSData *warningData = [warningMsg dataUsingEncoding:NSUTF8StringEncoding];
        
        [sock writeData:warningData withTimeout:-1 tag:WARNING_MSG];
        
        return READ_TIMEOUT_EXTENSION;
    }
    
    return 0.0;
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    // This method is executed on the socketQueue (not the main thread)
    //NSLog(@"didWriteDataWithTag = %ld",tag);
    /*
     if (tag == ECHO_MSG)
     {
     [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
     }
     */
}

- (void)writeData :(NSData *) data
{
    [curConnect writeData:data withTimeout:-1 tag:TEXT_LOG];
}

-(NSString *)localIpAddr
{
//    return [asyncSocket localHost];
    return [self getIPAddress];
}

-(uint16_t)localPort
{
    return [asyncSocket localPort];
}

-(NSString *)connectedHost
{
    return [curConnect connectedHost];
}

-(uint16_t )connectedPort
{
    return [curConnect connectedPort];
}

-(void)Disconnect
{
    [curConnect disconnect];
}

- (BOOL)isConnected
{
    return [curConnect isConnected];
}

- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}


@end
