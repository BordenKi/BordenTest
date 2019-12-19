//
//  WHCC.m
//  tztAppV4
//
//  Created by it-kangming on 2019/11/26.
//  Copyright © 2019 king. All rights reserved.
//

#import "WHCC.h"
#import "WHCCMonitor.h"
#import "WHCCComponentManager.h"

static const double DEFAULT_TIMEOUT = 2;

static int flowNo = 0;

@interface WHCC ()

@property (nonatomic, assign) BOOL async;

@property (nonatomic, assign) double timeout;

@property (nonatomic, assign) double timeoutAt;

@property (nonatomic, copy) NSString *callId;

@property (nonatomic, assign) BOOL canceled;

@property (nonatomic, assign) BOOL timeoutStatus;

@property (nonatomic, assign) BOOL finished;

@property (nonatomic, assign) BOOL waiting;

@property (nonatomic, assign) BOOL callbackOnMainThread;

@property (nonatomic, strong) NSRecursiveLock *lock;

@property (nonatomic, strong) NSCondition *wait4resultLock;

@property (nonatomic, strong )  WHCCResult *result;

@property (nonatomic, copy) NSString *actionName;

@property (nonatomic, copy) NSString *componentName;

@property (nonatomic, copy) WHCCIComponentCallback callback;

@property (nonatomic, strong) NSMutableArray <NSObject <WHCCICCInterceptor>* >*interceptors;

@property (nonatomic, strong) NSMutableDictionary <NSString *, NSObject *> *params;

@end

@implementation WHCC

- (instancetype)init
{
    self = [super init];
    if (self) {
        _timeout = -1;
        _finished = false;
        _interceptors = @[].mutableCopy;
        _params = @{}.mutableCopy;
    }
    return self;
}

- (void)setTimeoutAt
{
    if (_timeout > 0){
        _timeoutAt = (double)([[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] + _timeout);
    }else{
        _timeoutAt = 0;
    }
}

- (WHCCResult *)call
{
    _callback = nil;
    _async = NO;
    BOOL mainThreadCallWithNoTimeout = _timeout == 0 && [NSThread isMainThread];
    //主线程下的同步调用必须设置超时时间，默认为2秒
    if (mainThreadCallWithNoTimeout || _timeout < 0) {
        _timeout = DEFAULT_TIMEOUT;
    }
    [self setTimeoutAt];
    _callId = [NSString stringWithFormat:@"WHCCCallID%d",[self getNextCallID]];
    _canceled = NO;
    _timeoutStatus = NO;
    WHCCInfoLog(@"%@start to call:%@", _callId, self);
    return [[WHCCComponentManager shareInstance] call:self];
}

- (NSString *)callAsyncWithCallback:(WHCCIComponentCallback)callback
{
    _callbackOnMainThread = NO;
    return [self processCallAsyncWithCallback:callback];
}

- (NSString *)callAsyncWithCallbackOnMainThread:(WHCCIComponentCallback)callback
{
    _callbackOnMainThread = YES;
    return [self processCallAsyncWithCallback:callback];
}

- (NSString *)processCallAsyncWithCallback:(WHCCIComponentCallback)callback
{
    if (callback != nil) {
        _callback = callback;
    }
    _async = YES;
    if (_timeout < 0) {
        _timeout = 0;
    }
    [self setTimeoutAt];
    _callId = [NSString stringWithFormat:@"WHCCCallID%d",[self getNextCallID]];
    _canceled = NO;
    _timeoutStatus = NO;
    WHCCInfoLog(@"%@start to callAsync:%@", _callId, self);
    [[WHCCComponentManager shareInstance] call:self];
    return _callId;
}

+ (void)registerComponent:(NSString *)component
{
    [[WHCCComponentManager shareInstance] registerComponent:component];
}

+ (void)unregisterComponent:(NSString *)component
{
    [[WHCCComponentManager shareInstance] unregisterComponent:component];
}

- (void)cancel
{
    if ([self markFinished]) {
        _canceled = YES;
        [self setResult4Waiting:[WHCCResult errorWithCode:WHCCResultStatus_ERROR_CANCELED]];
        WHCCInfoLog(@"%@call cancel", _callId);
    }else{
        WHCCInfoLog(@"%@call cancel. but this cc is already finished", _callId);
    }
}

- (void)cancelByID:(NSString *)callID
{
    WHCCInfoLog(@"%@call [WHCC cancel]", _callId);
    WHCC *cc = [[WHCCMonitor shareInstance] getCCByID:callID];
    if (cc != nil) {
        [cc cancel];
    }
}

- (void)timeoutByID:(NSString *)callID
{
    WHCCInfoLog(@"%@call [WHCC cancel]", _callId);
    WHCC *cc = [[WHCCMonitor shareInstance] getCCByID:callID];
    if (cc != nil) {
        [cc cancel];
    }
}

- (WHCCResult *)getResult
{
    [self.lock lock];
    WHCCResult *result = _result;
    [self.lock unlock];
    return result;
}


- (void)setTimeout
{
    if ([self markFinished]) {
        _timeoutStatus = true;
        [self setResult4Waiting:[WHCCResult errorWithCode:WHCCResultStatus_ERROR_TIMEOUT]];
        WHCCInfoLog(@"%@timeout", _callId);
    } else {
         WHCCInfoLog(@"%@call timeout. but this cc is already finished", _callId);
    }
}

- (void)setResult4Waiting:(WHCCResult *)result
{
    [self setResult:result];
    [self.wait4resultLock lock];
    WHCCInfoLog(@"%@setResult%@.WHCCResult:%@", _callId, (_waiting ? @"4Waiting" : @"") , result);
    if (_waiting) {
        _waiting = NO;
        [_wait4resultLock broadcast];
    }
    [self.wait4resultLock unlock];
}

- (void)wait4Result
{
    [self.wait4resultLock lock];
    if (!_finished) {
        @try {
            WHCCInfoLog(@"%@start waiting for WHCC.sendCCResult(...)", _callId);
            _waiting = YES;
            [_wait4resultLock wait];
            WHCCInfoLog(@"%@end waiting for WHCC.sendCCResult(...)", _callId);
        } @catch (NSException *exception) {
            
        }
    }
    [self.wait4resultLock unlock];
}

- (void)setResult:(WHCCResult *)result
{
    [self.lock lock];
    _finished = YES;
    _result = result;
    [self.lock unlock];
}

- (void)sendCCResultWithCallID:(NSString *)callID andResult:(WHCCResult *)result
{
    WHCCInfoLog(@"%@WHCCResult received by WHCC.sendCCResult(...).WHCCResult:%@", _callId, self);
    WHCC *cc = [[WHCCMonitor shareInstance] getCCByID:callID];
    if (cc != nil) {
        if ([cc markFinished]) {
            if (result == nil) {
                result = [WHCCResult defaultNullResult];
                WHCCErrorLog(@"WHCC.sendCCResult called, But WHCCResult is null, set it to WHCCResult.defaultNullResult().ComponentName=%@", [cc getComponentName]);
            }
            [cc setResult4Waiting:result];
        }else{
            WHCCErrorLog(@"WHCC.sendCCResult called, But WHCCResult is null.ComponentName=%@", [cc getComponentName]);
        }
    }else{
        WHCCErrorLog(@"WHCCResult received, but cannot found callId:%@", _callId);
    }
}

- (int)getNextCallID
{
    [self.lock lock];
    int callIdInt = [WHCC nextCallID];
    [self.lock unlock];
    return callIdInt;
}

+ (int)nextCallID
{
    flowNo = (flowNo < INT32_MAX) ? (flowNo + 1) : 0;
    return flowNo;
}

- (BOOL)markFinished
{
    [self.lock lock];
    if (_finished == NO) {
        _finished = YES;
    }
    [self.lock unlock];
    return _finished;
}

- (BOOL)isFinished
{
    [self.lock lock];
    BOOL isFinished = _finished;
    [self.lock unlock];
    return isFinished;
}

- (NSString *)getComponentName
{
    return _componentName;
}

- (WHCCIComponentCallback)getCallback
{
    return _callback;
}

- (BOOL)isCallbackOnMainThread
{
    return _callbackOnMainThread;
}

- (BOOL)isAsync
{
    return _async;
}

- (WHCC *(^)(NSObject <WHCCICCInterceptor>*))addInterceptor
{
    WHWS(ws);
    return ^(NSObject <WHCCICCInterceptor>* component){
        [ws.interceptors addObject:component];
        return self;
    };
}

- (WHCC *(^)(NSString *))setActionName
{
    WHWS(ws);
    return ^(NSString *actionName){
        ws.actionName = actionName;
           return self;
       };
}

- (WHCC *(^)(NSMutableDictionary <NSString *, NSObject *>*))addParams
{
    WHWS(ws);
    return ^(NSMutableDictionary <NSString *, NSObject *>* params){
        [ws.params addEntriesFromDictionary:params];
        return self;
    };
}

- (WHCC *(^)( NSString *, NSObject *))addParam
{
    WHWS(ws);
    return ^( NSString *key, NSObject *value){
        [ws.params setObject:value forKey:key];
        return self;
    };
}

- (WHCC *(^)(NSString *))setComponentName
{
    WHWS(ws);
    return ^(NSString *componentName){
        ws.componentName = componentName;
           return self;
       };
}

- (WHCC *(^)(double))setTimeoutValue
{
    WHWS(ws);
    return ^(double timeout){
        if (timeout > 0) {
            ws.timeout = timeout;
        }else{
            WHCCErrorLog(@"Invalid timeout value:%f, timeout should >= 0. timeout will be set as default:%f", timeout, DEFAULT_TIMEOUT);
        }
           return self;
       };
}

#pragma mark - setter and getter
- (NSRecursiveLock *)lock
{
    if (!_lock) {
        _lock = [[NSRecursiveLock alloc] init];
    }
    return _lock;
}

- (NSCondition *)wait4resultLock
{
    if (!_wait4resultLock) {
        _wait4resultLock = [[NSCondition alloc] init];
    }
    return _wait4resultLock;
}

- (NSString *)getCallID
{
    return _callId;
}

- (double)getTimeoutAt
{
    return _timeoutAt;
}

- (NSMutableArray <NSObject <WHCCICCInterceptor>* >*)getInterceptors
{
    return _interceptors;
}

- (NSString *)getActionName
{
    return _actionName;
}

- (NSMutableDictionary <NSString *, NSObject *> *)getParams
{
    return _params;
}

@end
