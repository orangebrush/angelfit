//
//  ViewController.m
//  AngelFitOCSample
//
//  Created by YiGan on 27/07/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) AngelManager *angelManager;
@property (nonatomic, strong) NetworkHandler *networkHandler;
@end

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
    
}

- (void)createContents {
    
}

@end
