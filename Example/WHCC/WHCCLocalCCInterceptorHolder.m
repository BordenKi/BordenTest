//
//  WHCCLocalCCInterceptorHolder.m
//  tztAppV4
//
//  Created by it-kangming on 2019/12/10.
//  Copyright © 2019 king. All rights reserved.
//

#import "WHCCLocalCCInterceptorHolder.h"
#import "WHCCComponentManager.h"
#import "WHCCIComponent.h"
#import "WHCCChain.h"
#import "WHCC.h"
#import "WHCCIMainThread.h"

@interface WHCCLocalCCOperation : NSOperation

- (instancetype)initWithCC:(WHCC *)cc andComponent:(NSObject <WHCCIComponent>*)component;

@end

@implementation WHCCLocalCCOperation
{
    WHCC *_cc;
    NSObject <WHCCIComponent>* _component;
    BOOL _shouldSwitchThread;
    NSString *_callID;
}

- (instancetype)initWithCC:(WHCC *)cc andComponent:(NSObject <WHCCIComponent>*)component
{
    self = [super init];
    if (self) {
        _cc = cc;
        _callID = [cc getCallID];
        _component = component;
    }
    return self;
}

- (void)main
{
    if (self.isCancelled){
        return;
    }
    if ([_cc isFinished]) {
        return;
    }
    @try {
        if ([_component respondsToSelector:@selector(onCall:)]) {
            BOOL callbackDelay = [_component onCall:_cc];
            if (!callbackDelay && ![_cc isFinished]) {
                [self setResult:[WHCCResult errorWithCode:WHCCResultStatus_ERROR_CALLBACK_NOT_INVOKED]];
            }
        }
    } @catch (NSException *exception) {
        
    } @finally {
            
    }
}

- (void)setResult:(WHCCResult *)result
{
    if (_shouldSwitchThread) {
        [_cc setResult4Waiting:result];
    }else{
        [_cc setResult:result];
    }
}


@end


@implementation WHCCLocalCCInterceptorHolder

+ (instancetype)shareIntstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WHCCLocalCCInterceptorHolder alloc] init];
    });
    return instance;
}

- (WHCCResult *)interceptWithChain:(WHCCChain *)chain
{
    WHCC *cc = [chain getCC];
    NSString *className = [[WHCCComponentManager shareInstance] getComponentByName:[cc getComponentName]];
    NSObject <WHCCIComponent> *component = [[NSClassFromString(className) alloc] init];
    if (component == nil) {
        return [WHCCResult errorWithCode:WHCCResultStatus_ERROR_NO_COMPONENT_FOUND];
    }
    @try {
//        NSString *callID = [cc getCallID];
        BOOL shouldSwitchThread = NO;
        WHCCLocalCCOperation *operation = [[WHCCLocalCCOperation alloc] initWithCC:cc andComponent:component];
        if ([component conformsToProtocol:@protocol(WHCCIMainThread)]) {
            BOOL curIsMainThread = [NSThread isMainThread];
            if ([component respondsToSelector:@selector(shouldActionRunOnMainThreadWithAtionName:andCC:)]) {
                NSObject <WHCCIComponent, WHCCIMainThread> *componentNew = component;
                BOOL runOnMainThread = [componentNew shouldActionRunOnMainThreadWithAtionName:[cc getActionName] andCC:cc];
                shouldSwitchThread = (runOnMainThread ^ curIsMainThread);
                if (shouldSwitchThread) {
                    if (runOnMainThread) {
                        [[WHCCComponentManager shareInstance] addThreadToMainQueue:operation];
                    }else{
                        [[WHCCComponentManager shareInstance] addThreadToChildQueue:operation];
                    }
                }
            }
        }
        
        if (!shouldSwitchThread) {
            [operation start];
        }
        
        if (![cc isFinished]) {
            [chain proceed];
        }
    } @catch (NSException *exception) {
        return [WHCCResult defaultExceptionResult:exception];
    }
    return [cc getResult];
}


@end
