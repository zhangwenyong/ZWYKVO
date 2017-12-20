//
//  NSObject+ZWYKVO.m
//  自定义KVO
//
//  Created by 张文勇 on 2017/12/19.
//  Copyright © 2017年 张文勇. All rights reserved.
//

#import "NSObject+ZWYKVO.h"
#import <objc/runtime.h>
#import <objc/message.h>

//记清楚这几个关键词的顺醋。记清楚这几个关键词的顺序 记清楚这几个关键词的顺序 记清楚这几个关键词的顺序 记清楚这几个关键词的顺序
NSString *const _Nonnull Z_addObSerVerSubClassName = @"Z_addObSerVerSubClassName";//子类名称的前缀
NSString *const  Z_associal = @"Z_associal";//属性数组的名字

//声明一个私有类 来存储我们的 观察信息
@interface Z_ObserverInfo:NSObject
/**
 注释  观察者对象
 */
@property (nonatomic,strong)NSObject *obserer;
/**
 注释 观察者对象
 */
@property (nonatomic,strong)NSString *key;
/**
 注释
 */
@property (nonatomic,copy)MyObeserverBlock blcok;

-(instancetype)initWithObervver:(NSObject *)obserer Key:(NSString*)key MyObeserverblock:(MyObeserverBlock)block;

@end
// 私有类的实现 私有类的实现。牛逼 哄哄的 这个 主要 把 观察这 对象话
@implementation Z_ObserverInfo
-(instancetype)initWithObervver:(NSObject *)obserer Key:(NSString*)key MyObeserverblock:(MyObeserverBlock)block
{
    
    self = [super init];
    if(self)
    {
        self.obserer = obserer;
        self.key = key;
        self.blcok= block;
    }
    return self;
}

@end

//这个static 的意思就是只能在本文见中使用这个函数。只能在本文见中使用这个函数 只能在本文见总使用这个函数


/**
 根据setter方法 敢回getter方法明
*/
static NSString *getterNameForSetterKey(NSString *key){
    
    NSString *getterS = [key substringWithRange:NSMakeRange(3, key.length-4)];
    
    NSString *first = [[getterS substringToIndex:1] lowercaseString];
    
    
    getterS = [getterS stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:first];
    
    return getterS;
}

static void  Observer_IMP(id self,SEL _cmd,id newValue)
{
    
    NSString *setterName = NSStringFromSelector(_cmd);
    
    NSString *getterName =  getterNameForSetterKey(setterName);
    
    NSLog(@"%@",getterName);
    
    id Odvalue = [self valueForKey:getterName];
    
    
    // 指定一个实例的父类
    struct objc_super superclass = {
        .receiver = self,
        .super_class =  class_getSuperclass(object_getClass(self))
    };
    
    void (*messesend)(void*,SEL,id) = (void *)objc_msgSendSuper;
    //屌用父类的当啊。屌用父类的放啊法 屌用父类的方法。
    messesend(&superclass,_cmd,newValue);
    
    NSMutableArray *obserVerArr = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(Z_associal));
    for(Z_ObserverInfo *obc in obserVerArr)
    {
        if([obc.key isEqualToString:getterName])
        {
            obc.blcok(self, getterName,Odvalue, newValue);
        }
    }
    
    
    
    
    
}
// IMP函数指针的固定模式。这就是IMP函数指针的固定模式。前两个参数必须是 id self还有 就是SEL _cmd   _cmd 代表的就是我们函数本身名字
// 我们的函数本身的名字 我们函数的本身的名字。
static Class observerClass(id self,SEL _cmd)
{
    //  为啥我们不屌用【self class】这个方法呢 因为这样的话就变成了循环了。
    return  class_getSuperclass(object_getClass(self));
}

@implementation NSObject (ZWYKVO)


-(void)Z_addObserver:(NSObject *)obj forkey:(NSString *)key withObject:(MyObeserverBlock)block
{
    //第一步 检查这个属性存在不存在
    //获取 这个属性的SEL字符串
    NSString *SELString = [self setterForKey:key];
    NSLog(@"==%@==",SELString);
    //根据字符串 获取SEL
    SEL SELsetter= NSSelectorFromString(SELString);
    //根据SEL获取 method
    Method M_setter = class_getInstanceMethod([self class], SELsetter);
    //通过检查这个的 method 存在不存在从而检查 属性 存在不存在或者这个属性的setter方法存在不存在
    if(!M_setter)
    {
        //如果属性不存在 直接 抛出异常。 如果 属性不存在直接抛出异常 如果属性不存子直接抛出异常 如果属性不存在直接抛出异常。如果属性不存在直接抛出异常 吐过谁像你个不存在直接抛出异常
       @throw  [NSException exceptionWithName:NSInvalidArgumentException reason:@"属性不存在或者类没有这个属性的setter方法" userInfo:nil];
    }

    // 获取这个类的类名字
    NSString *className = [NSString stringWithUTF8String:class_getName([self class])] ;
    //定义这个类的子类的雷鸣

    //为了确认这不是KVO类 为了确认这不是KVO类 为了确认这不是KVO类
    if(![className hasPrefix:Z_addObSerVerSubClassName])
    {
        // 生成 KVO类
        Class subclass = [self makeKVOClass:className];
        //把本对象的isa 指针指向这个KVO子类
        object_setClass(self, subclass);
    }
    //从现在开始的self 就是指的是子类的 对象的。 这是这里的一个坑 从现在开始这里的self 就是指子类的对象了。这里你要明白
    //给这个子类 的setter方法 重写一下。换成自己的setter方法；  基本到这里就基本解决了 大部分的问题  还有一个小问题
    // 如果这个类已经改变了。就不用再这样设置了
    
    
    // 如果没有这个setter方法已经被实现了的话在子类中 就不需要重复设置了
    if(![self hasSetter:SELString])
    {
        
        //在这里不能用 【self class】这个方法了。这个方法 现在不能 返回自己这个类了。只能返回 self这个对象的父类
        class_addMethod(object_getClass(self), SELsetter, (IMP)Observer_IMP, method_getTypeEncoding(M_setter));
    }
    Z_ObserverInfo *observerObject = [[Z_ObserverInfo alloc]initWithObervver:obj Key:key MyObeserverblock:block];
    //把这个对象存储在 数组中 把这个对象存储在数组中   利用runtime 给这个类添加一个数组属性存储这些东西
    NSMutableArray *observers = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(Z_associal));
    if(!observers)
    {
        observers = [NSMutableArray array]; //修改了 这里面的一个bug 如果是这样的 就回出现bug NSMutableArray * observers = [NSMutableArray array];
        
        
        //给这个子类 添加一个数组属性来存储 这些的东西饿
        objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(Z_associal), observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [observers addObject:observerObject];
    
    
    
    
}


//判断子类有没有实现setter方法

-(BOOL)hasSetter:(NSString *)Setter
{
    
    unsigned int methodCount;
    
   Method *methodArray =   class_copyMethodList(object_getClass(self), &methodCount);
    
    
    for (int i=0; i<methodCount;i++)
    {
        
      SEL name =  method_getName(methodArray[i]);
        
        
        if(name == NSSelectorFromString(Setter))
        {
            
            return YES;
        }
    }
    return NO ;
}

/**
 返回新建的子类
 */
-(id)makeKVOClass:(NSString *)className
{
    
    NSString *subclassName = [NSString stringWithFormat:@"%@%@",Z_addObSerVerSubClassName,className];
    // 如果已经生成过一遍了 就不用再一次的生成了
    
    Class Zclass =  NSClassFromString(subclassName);
    
    
    if(Zclass)
    {
        return Zclass;
    }
    
    
    //生成类的子类
    Class subClass = objc_allocateClassPair([self class], subclassName.UTF8String, 0);
    //给类添加一个setter方法=====method_getTypeEncoding 这个方法是获取 Method 的参数 返回值类型 types
    
    //重写class 的方法。 对外面的人继续以为这个对象 还是原来的对象。 这种小伎俩 绝对是apple常用 的 太贱了
    Method classMethod = class_getInstanceMethod([self class], @selector(class));
    class_addMethod(subClass, @selector(class), (IMP)observerClass, method_getTypeEncoding(classMethod));
    // 注册这个类
    objc_registerClassPair(subClass);
    return subClass;
}

/**
   根据属性的值 生成setter方法。生成setter方法字符串
 
 */
-(NSString *)setterForKey:(NSString *)key
{
    NSString *Hkey = [[key substringWithRange:NSMakeRange(0, 1)] uppercaseString];
    
    NSString *Hey = [NSString stringWithFormat:@"%@%@",Hkey,[key substringFromIndex:1]];
    
    NSString *setterString = [NSString stringWithFormat:@"set%@:",Hey];
    
    return setterString;
}

- (void)PG_removeObserver:(NSObject *)observer forKey:(NSString *)key
{
    NSMutableArray* observers = objc_getAssociatedObject(self, (__bridge const void *)(Z_associal));
    
    Z_ObserverInfo *infoToRemove;
    for (Z_ObserverInfo* info in observers) {
        if (info.obserer == observer && [info.key isEqual:key]) {
            infoToRemove = info;
            break;
        }
    }
    
    [observers removeObject:infoToRemove];
}


@end
