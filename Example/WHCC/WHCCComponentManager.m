//
//  WHCCComponentManager.m
//  tztAppV4
//
//  Created by it-kangming on 2019/11/28.
//  Copyright © 2019 king. All rights reserved.
//

#import "WHCCComponentManager.h"
#import "WHCC.h"
#import "WHCCChain.h"
#import "WHCCIComponent.h"
#import "WHCCValidateInterceptor.h"
#import "WHCCChainProcessor.h"

@interface WHCCComponentManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString*> *componentsDic;

@property (nonatomic, strong) NSOperationQueue *mainThreadQueue;

@property (nonatomic, strong) NSOperationQueue *childThreadQueue;

@property (nonatomic, strong) NSRecursiveLock *lock;

@end

@implementation WHCCComponentManager

+ (instancetype)shareInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WHCCComponentManager alloc] init];
    });
    return instance;
}

- (WHCCResult *)call:(WHCC *)cc
{
//    NSString *callID = [cc getCallID];
    WHCCChain *chain = [[WHCCChain alloc] initWithCC:cc];
    [chain addInterceptorWithArr:[cc getInterceptors]];
    [chain addInterceptor:[WHCCValidateInterceptor shareIntstance]];
    
    WHCCChainProcessor *processor = [[WHCCChainProcessor alloc] initWithChain:chain];
    if ([cc isAsync]) {
        [[WHCCComponentManager shareInstance] addThreadToChildQueue:processor];
        return nil;
    }else{
        WHCCResult *result;
        @try {
            result = [processor call];
        } @catch (NSException *exception) {
            result = [WHCCResult defaultExceptionResult:exception];
        }
        return result;
    }
}

- (void)registerComponent:(NSString *)componentName
{
    Class implClass = NSClassFromString(componentName);
    if ([implClass conformsToProtocol:@protocol(WHCCIComponent)]) {
        NSObject <WHCCIComponent> *obj = [[implClass alloc] init];
        if ([obj respondsToSelector:@selector(getName)]) {
            NSString *name = [obj getName];
            if (name == nil || name.length == 0) {
            
            }else{
                [self.lock lock];
                [[WHCCComponentManager shareInstance].componentsDic addEntriesFromDictionary:@{name:componentName}];
                [self.lock unlock];
            }
        }
    }
}

- (void)unregisterComponent:(NSString *)componentName
{
    Class implClass = NSClassFromString(componentName);
    if ([implClass conformsToProtocol:@protocol(WHCCIComponent)]) {
        NSObject <WHCCIComponent> *obj = [[implClass alloc] init];
        if ([obj respondsToSelector:@selector(getName)]) {
            NSString *name = [obj getName];
            if (name == nil || name.length == 0) {
            
            }else{
                [self.lock lock];
                [[WHCCComponentManager shareInstance].componentsDic removeObjectForKey:name];
                [self.lock unlock];
            }
        }
    }
}

- (BOOL)isHaveComponent:(NSString *)componentName
{
    BOOL isHave = ([self getComponentByName:componentName] != nil);
    return isHave;
}

- (NSString *)getComponentByName:(NSString *)componentName
{
    return [WHCCComponentManager shareInstance].componentsDic[componentName];
}

- (void)addThreadToMainQueue:(NSOperation *)opreation
{
    [[WHCCComponentManager shareInstance].mainThreadQueue addOperation:opreation];
}

- (void)addThreadToChildQueue:(NSOperation *)opreation
{
    [[WHCCComponentManager shareInstance].childThreadQueue addOperation:opreation];
}

#pragma mark - setter and getter

- (NSMutableDictionary<NSString *,NSString *> *)componentsDic
{
    if (!_componentsDic) {
        _componentsDic = @{}.mutableCopy;
    }
    return _componentsDic;
}

- (NSOperationQueue *)mainThreadQueue
{
    if (!_mainThreadQueue) {
        _mainThreadQueue = [NSOperationQueue mainQueue];
    }
    return _mainThreadQueue;
}

- (NSOperationQueue *)childThreadQueue
{
    if (!_childThreadQueue) {
        _childThreadQueue = [[NSOperationQueue alloc] init];
        _childThreadQueue.maxConcurrentOperationCount = 2;
    }
    return _childThreadQueue;
}

- (NSRecursiveLock *)lock
{
    if (!_lock) {
        _lock = [[NSRecursiveLock alloc] init];
    }
    return _lock;
}

@end
