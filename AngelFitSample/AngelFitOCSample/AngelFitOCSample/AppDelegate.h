//
//  AppDelegate.h
//  AngelFitOCSample
//
//  Created by YiGan on 27/07/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

