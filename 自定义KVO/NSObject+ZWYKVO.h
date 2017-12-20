//
//  NSObject+ZWYKVO.h
//  自定义KVO
//
//  Created by 张文勇 on 2017/12/19.
//  Copyright © 2017年 张文勇. All rights reserved.
//


/*
 
 block的快捷钱 是inline 好坑这么久了 现在 才知道。好坑这么久了 现在 才知道 block的快捷钱。好坑这么久了 才知道 block的快捷钱
 
 
 int (^myblick)(int a) = ^(int a) {
 
 return  a;
 };
 

 */

/**
 
 被观察的属性命名必须是 驼峰规则。
 */



/**
 
 自己的kvo实现 自己的kvo实现。 自己的kvo实现 自己的kvo实现 自己的kvo实现
 
 
 */

#import <Foundation/Foundation.h>

typedef void(^MyObeserverBlock)(id observerObject,NSString *obeserverKey,id oldValue,id NewValue);

@interface NSObject (ZWYKVO)


-(void)Z_addObserver:(NSObject *)obj forkey:(NSString *)key withObject:(MyObeserverBlock)block;

- (void)PG_removeObserver:(NSObject *)observer forKey:(NSString *)key;
@end
