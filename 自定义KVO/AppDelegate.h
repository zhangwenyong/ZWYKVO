//
//  AppDelegate.h
//  自定义KVO
//
//  Created by 张文勇 on 2017/12/19.
//  Copyright © 2017年 张文勇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

