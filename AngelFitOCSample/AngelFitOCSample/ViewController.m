//
//  ViewController.m
//  AngelFitOCSample
//
//  Created by YiGan on 27/07/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

#import "ViewController.h"
//#import <AngelFit/AngelFit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AngelFitNetwork/AngelFitNetwork.h>

@interface ViewController (){

}

@property (nonatomic, strong) NetworkHandler *networkHandler;
//@property (nonatomic, strong) CoredataHandler *coredateHandler;
@end

#define weakSelf __weak typeof(self) Self = self;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self config];
    [self createContents];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)config {
    
    _networkHandler = [NetworkHandler share];
    
    NSString *userId = @"283925583@qq.com";
    NSString *password = @"1234567";
    NSString *macaddress = @"DES8DSKJ9IDF";
    NSString *deviceId = [NSString stringWithFormat:@"1%@110", macaddress];

    
    NWHUserUpdateParam *updateParam = [[NWHUserUpdateParam alloc] init];
    updateParam.userId = userId;
    updateParam.password = password;
    updateParam.showName = @"8_16";
    [_networkHandler.user updateWithParam:updateParam closure:^(NSInteger resultCode, NSString *message, id data) {
        NSLog(@"<update> resultCode: %ld-%@-%@", resultCode, message, data);
        
        NWHUserLogonParam *logonParam = [[NWHUserLogonParam alloc] init];
        logonParam.userId = userId;
        logonParam.password = password;
        [_networkHandler.user logonWithParam:logonParam closure:^(NSInteger resultCode, NSString *message, id data) {
            NSLog(@"<logon> resultCode: %ld-%@-%@", resultCode, message, data);
        }];
    }];
    
//    NWHUserLogonParam *param = [[NWHUserLogonParam alloc] init];
//    param.userId = userId;
//    param.password = password;
//    [_networkHandler.user logonWithParam:param closure:^(NSInteger resultCode, NSString *message, id data) {
//        NSLog(@"<登录账号>%ld-%@-%@", resultCode, message, data);
//        id height = [(NSDictionary *)data valueForKey:@"height"];
//        NSLog(@"%@", height);
//    }];
//    
//    //添加设备
//    NWHDeviceParam *deviceParam = [[NWHDeviceParam alloc] init];
//    deviceParam.deviceId = deviceId;
//    deviceParam.macAddress = macaddress;
//    deviceParam.name = @"gan";
//    deviceParam.uuid = @"123fasafd";
//    deviceParam.showName = @"id107 hr";
//    [_networkHandler.device addWithParam:deviceParam closure:^(NSInteger resultCode, NSString *message, id data) {
//        NSLog(@"<添加设备>%ld-%@-%@", resultCode, message, data);
//    }];
//    
//    //上传照片
//    NWHUserUploadParam *uploadParam = [[NWHUserUploadParam alloc] init];
//    uploadParam.image = [UIImage imageNamed:@"headshot.png"];
//    uploadParam.userId = userId;
//    [_networkHandler.user uploadPhotoWithParam:uploadParam closure:^(NSInteger resultCode, NSString *message, id data) {
//        NSLog(@"<上传照片>%ld-%@-%@", resultCode, message, data);
//    }];
    
//    //检查账号是否存在
//    [_networkHandler.user checkExistWithUserId:userId closure:^(NSInteger resultCode, NSString *message, id data) {
//        NSLog(@"resultCode: %ld\nmessage: %@\ndata: %@", (long)resultCode, message, data);
//    }];
    
//    param.password = @"321232132";
//    [_networkHandler.user logonWithParam:param closure:^(NSInteger resultCode, NSString *message, id data) {
//        NSLog(@"%ld-%@-%@", resultCode, message, data);
//        id height = [(NSDictionary *)data valueForKey:@"height"];
//        NSLog(@"%@", height);
//    }];
    
//    //添加用户请求
//    NWHUserRegisterParam *addParam = [[NWHUserRegisterParam alloc] init];
//    addParam.userId = @"283925583@qq.com";
//    addParam.password = @"123456";
//    addParam.confirm = @"123456";
//    
//    weakSelf;
//    [_networkHandler.user registerWithParam:addParam closure:^(NSInteger resultCode, NSString *message, id data){
//        NSLog(@"resultCode: %ld, message: %@, data: %@", (long)resultCode, message, data);
//
//        //登录用户请求
//        NWHUserLogonParam *logonParam = [[NWHUserLogonParam alloc] init];
//        logonParam.userId = @"test@qq.com";
//        logonParam.password = @"123456";
//
//        [[Self networkHandler].user logonWithParam:logonParam closure:^(NSInteger resultCode, NSString *message, id data){
//            NSLog(@"resultCode: %ld, message: %@, data: %@", (long)resultCode, message, data);
//        }];
//    }];

//    //获取验证码
//    NWHUserVerificationCodeParam *verificationCodeParam = [[NWHUserVerificationCodeParam alloc] init];
//    verificationCodeParam.email = @"283925583@qq.com";
//    
//    [_networkHandler.user getVerificationCodeWithParam:verificationCodeParam closure:^(NSInteger resultCode, NSString *message, id data) {
//        NSLog(@"%ld--%@--%@",resultCode,message,data);
//    }];
}

- (void)createContents {
    
}

@end
