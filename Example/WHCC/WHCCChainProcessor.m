//
//  WHCCChainProcessor.m
//  tztAppV4
//
//  Created by it-kangming on 2019/12/11.
//  Copyright © 2019 king. All rights reserved.
//

#import "WHCCChainProcessor.h"
#import "WHCCChain.h"
#import "WHCC.h"
#import "WHCCMonitor.h"
#import "WHCCComponentManager.h"

@interface WHCCCallbackOperation : NSOperation

@end

@interface WHCCCallbackOperation ()

@property (nonatomic, strong) WHCC *cc;

@property (nonatomic, strong) WHCCResult *result;

@property (nonatomic, copy) WHCCIComponentCallback callBack;

@end

@implementation WHCCCallbackOperation

- (instancetype)initWithCC:(WHCC *)cc andResult:(WHCCResult *)result andCallback:(WHCCIComponentCallback)callback
{
    self = [super init];
    if (self) {
        _cc = cc;
        _callBack = callback;
        _result = result;
    }
    return self;
}

 - (void)main
{
    @try {
        if (_callBack) {
            _callBack(_cc, _result);
        }
    } @catch (NSException *exception) {
        
    }
}

@end

@interface WHCCChainProcessor ()

@property (nonatomic, strong) WHCCChain *chain;

@end

@implementation WHCCChainProcessor

- (instancetype)initWithChain:(WHCCChain *)chain
{
    self = [super init];
    if (self) {
        _chain = chain;
    }
    return self;
}

- (void)main
{
    if (self.isCancelled) return;
    [self call];
}

- (WHCCResult *)call
{
    WHCC *cc = [_chain getCC];
    NSString *callID = [cc getCallID];
    [[WHCCMonitor shareInstance] addMonitorFor:cc];
    WHCCResult *result;
    @try {
        if ([cc isFinished]) {
            result = [cc getResult];
        }else{
            @try {
                result = [_chain proceed];
            } @catch (NSException *exception) {
                result = [WHCCResult defaultExceptionResult:exception];
            }
        }
    } @catch (NSException *exception) {
         result = [WHCCResult defaultExceptionResult:exception];
    } @finally {
        [[WHCCMonitor shareInstance] removeCCByID:callID];
    }
    
    if (result == nil) {
        result = [WHCCResult defaultNullResult];
    }
    [cc setResult:nil];
    [self performCallbackWithCC:cc andResult:result];
    return result;
}

- (void)performCallbackWithCC:(WHCC *)cc andResult:(WHCCResult *)result
{
    WHCCIComponentCallback callback = [cc getCallback];
    if (callback == nil) {
        return;
    }
    if ([cc isCallbackOnMainThread]) {
        [[WHCCComponentManager shareInstance] addThreadToMainQueue:[[WHCCCallbackOperation alloc] initWithCC:cc andResult:result andCallback:callback]];
    }else{
        @try {
            if (callback) {
                callback(cc, result);
            }
        } @catch (NSException *exception) {
            
        }
    }
}

@end
