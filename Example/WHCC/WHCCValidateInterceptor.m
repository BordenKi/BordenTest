//
//  WHCCValidateInterceptor.m
//  tztAppV4
//
//  Created by it-kangming on 2019/12/10.
//  Copyright © 2019 king. All rights reserved.
//

#import "WHCCValidateInterceptor.h"
#import "WHCCComponentManager.h"
#import "WHCCChain.h"
#import "WHCC.h"
#import "WHCCLocalCCInterceptorHolder.h"
#import "WHCCWait4ResultInterceptor.h"

@implementation WHCCValidateInterceptor

+ (instancetype)shareIntstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WHCCValidateInterceptor alloc] init];
    });
    return instance;
}

- (WHCCResult *)interceptWithChain:(WHCCChain *)chain
{
    WHCC *cc = [chain getCC];
    NSString *componentName = [cc getComponentName];
    int code = 0;
    if (componentName.length == 0 || componentName == nil) {
        code = WHCCResultStatus_ERROR_COMPONENT_NAME_EMPTY;
    }else{
        if (![[WHCCComponentManager shareInstance] isHaveComponent:componentName]) {
            code = WHCCResultStatus_ERROR_NO_COMPONENT_FOUND;
        }
    }
    if (code != 0) {
        return [WHCCResult errorWithCode:code];
    }
    if ([[WHCCComponentManager shareInstance] isHaveComponent:componentName]) {
        [chain addInterceptor:[WHCCLocalCCInterceptorHolder shareIntstance]];
    }
    [chain addInterceptor:[WHCCWait4ResultInterceptor shareIntstance]];
    return [chain proceed];
}

@end
