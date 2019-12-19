//
//  WHCCWait4ResultInterceptor.m
//  tztAppV4
//
//  Created by it-kangming on 2019/12/11.
//  Copyright © 2019 king. All rights reserved.
//

#import "WHCCWait4ResultInterceptor.h"
#import "WHCCChain.h"
#import "WHCC.h"

@implementation WHCCWait4ResultInterceptor

+ (instancetype)shareIntstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WHCCWait4ResultInterceptor alloc] init];
    });
    return instance;
}

- (WHCCResult *)interceptWithChain:(WHCCChain *)chain
{
    WHCC *cc = [chain getCC];
    [cc wait4Result];
    return [cc getResult];
}

@end
