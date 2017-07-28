//
//  ViewController.m
//  AngelFitOCSample
//
//  Created by YiGan on 27/07/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

#import "ViewController.h"
#import <AngelFit/AngelFit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController (){

}
@property (nonatomic, strong) AngelManager *angelManager;
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
    _angelManager = [AngelManager share];
    NSLog(@"angelManager: %@", _angelManager);
    
    _networkHandler = [NetworkHandler share];
    NSLog(@"networkhandler: %@", _networkHandler);

    //添加用户请求
    NWHUserAddParam *addParam = [[NWHUserAddParam alloc] init];
    addParam.userId = @"test";
    addParam.password = @"123456";
    
    weakSelf;
    [_networkHandler.user addWithParam:addParam closure:^(NSInteger resultCode, NSString *message, id data){
        NSLog(@"resultCode: %ld, message: %@, data: %@", (long)resultCode, message, data);

        //登录用户请求
        NWHUserLogonParam *logonParam = [[NWHUserLogonParam alloc] init];
        logonParam.userId = @"test";
        logonParam.password = @"123456";

        [[Self networkHandler].user logonWithParam:logonParam closure:^(NSInteger resultCode, NSString *message, id data){
            NSLog(@"resultCode: %ld, message: %@, data: %@", (long)resultCode, message, data);
        }];
    }];
    
}

- (void)createContents {
    
}

@end
