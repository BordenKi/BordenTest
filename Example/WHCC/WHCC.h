//
//  WHCC.h
//  tztAppV4
//
//  Created by it-kangming on 2019/11/26.
//  Copyright © 2019 king. All rights reserved.
//

@class WHCC;
#import <Foundation/Foundation.h>
#import "WHCCResult.h"
#import "WHCCICCInterceptor.h"
#import "WHCCIComponent.h"

typedef void(^WHCCIComponentCallback)(WHCC *cc, WHCCResult *result);

@interface WHCC : NSObject

- (void)setTimeout;

- (void)setResult4Waiting:(WHCCResult *)result;

- (void)setResult:(WHCCResult *)result;

- (void)wait4Result;

- (NSString *)getCallID;

- (double)getTimeoutAt;

- (WHCCResult *)getResult;

- (NSMutableArray <NSObject <WHCCICCInterceptor>* >*)getInterceptors;

- (WHCC *(^)(NSObject <WHCCICCInterceptor>*))addInterceptor;

- (WHCC *(^)(NSString *))setActionName;

- (WHCC *(^)(NSString *))setComponentName;

- (WHCC *(^)(NSMutableDictionary <NSString *, NSObject *>*))addParams;

- (WHCC *(^)(double))setTimeoutValue;

- (WHCC *(^)( NSString *, NSObject *))addParam;

- (NSString *)getComponentName;

- (NSString *)getActionName;

- (NSMutableDictionary <NSString *, NSObject *> *)getParams;

- (BOOL)isAsync;

- (WHCCIComponentCallback)getCallback;

- (BOOL)isCallbackOnMainThread;

- (BOOL)isFinished;

- (void)cancel;

- (WHCCResult *)call;

- (NSString *)callAsyncWithCallback:(WHCCIComponentCallback)callback;

- (NSString *)callAsyncWithCallbackOnMainThread:(WHCCIComponentCallback)callback;

- (void)sendCCResultWithCallID:(NSString *)callID andResult:(WHCCResult *)result;

+ (void)registerComponent:(NSString *)component;

+ (void)unregisterComponent:(NSString *)component;

@end


