//
//  ViewController.m
//  自定义KVO
//
//  Created by 张文勇 on 2017/12/19.
//  Copyright © 2017年 张文勇. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+ZWYKVO.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self Z_addObserver:self forkey:@"kvOString" withObject:^(id observerObject, NSString *obeserverKey, id oldValue, id NewValue) {
       
        
        
        NSLog(@"数据变化了");
        
    }];
    
    self.kvOString = @"父之操纵";
    
    NSLog(@"==看看附上值没有啊 =%@====",self.kvOString);
    
    Class class = [self class];
    
    
    NSLog(@"===%@==",class);
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
