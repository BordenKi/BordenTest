//
//  WHCCMonitor.m
//  tztAppV4
//
//  Created by it-kangming on 2019/11/29.
//  Copyright © 2019 king. All rights reserved.
//

#import "WHCCMonitor.h"
#import "WHCC.h"
#import "WHCCThreadSafeDictionary.h"

static volatile double minTimeoutAt = LONG_MAX;

static Boolean stopped = true;

@interface WHCCMonitor ()

@property (nonatomic, strong) WHCCThreadSafeDictionary *ccMap;

@property (nonatomic, strong) dispatch_semaphore_t signal;

@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, strong) NSRecursiveLock *lock;

@end

@implementation WHCCMonitor

+ (instancetype)shareInstance
{
    static id sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[WHCCMonitor alloc] init];
    });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _queue = dispatch_queue_create("com.wanhesec.ccMonitorQueue", DISPATCH_QUEUE_SERIAL);
        _signal = dispatch_semaphore_create(0);
    }
    return self;
}

- (WHCC *)getCCByID:(NSString *)callID
{
    return self.ccMap[callID];
}

- (void)removeCCByID:(NSString *)callID
{
    [self.ccMap removeObjectForKey:callID];
}

- (void)addMonitorFor:(WHCC *)cc
{
    if (cc != nil) {
        [self.ccMap setObject:cc forKey:cc.getCallID];
        double timeOutAt = cc.getTimeoutAt;
        if (timeOutAt > 0) {
            if (minTimeoutAt > timeOutAt) {
                minTimeoutAt = timeOutAt;
                dispatch_semaphore_signal(_signal);
            }
            
            [self.lock lock];
            if (stopped == true) {
                stopped = false;
                [self startQueue];
            }
            [self.lock unlock];
        }
    }
}

- (void)startQueue
{
    if (stopped) {
        return;
    }
    dispatch_async(_queue, ^{
        while (self.ccMap.count > 0 || minTimeoutAt == LONG_MAX) {
            @try {
                double millis = minTimeoutAt - [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
                if (millis > 0) {
                    dispatch_time_t time = dispatch_walltime(DISPATCH_TIME_NOW, millis* NSEC_PER_SEC);
                    dispatch_semaphore_wait(self->_signal, time);
                }
                
                //next cc timeout
                double min = LONG_MAX;
                double now = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
                for (WHCC *cc in self.ccMap.allValues) {
                    if (![cc isFinished]) {
                        double timeoutAt = cc.getTimeoutAt;
                        if (timeoutAt > 0) {
                            if (timeoutAt < now) {
                                [cc setTimeout];
                            } else if (timeoutAt < min) {
                                min = timeoutAt;
                            }
                        }
                    }
                }
                minTimeoutAt = min;
            } @catch (NSException *exception) {
                NSArray * arr = [exception callStackSymbols];
                NSString * reason = [exception reason];
                NSString * name = [exception name];
                NSString * url = [NSString stringWithFormat:@"========WHCC异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@",name,reason,[arr componentsJoinedByString:@"\n"]];
                       NSLog(@"%@", url);
            }
        }
        [self.lock lock];
        stopped = true;
        [self.lock unlock];
    });
}


#pragma mark - property setter or getter
- (WHCCThreadSafeDictionary *)ccMap
{
    if (!_ccMap) {
        _ccMap = @{}.mutableCopy;
    }
    return _ccMap;
}

- (NSRecursiveLock *)lock
{
    if (!_lock) {
        _lock = [[NSRecursiveLock alloc] init];
    }
    return _lock;
}

@end
