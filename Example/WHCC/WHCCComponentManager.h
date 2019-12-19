//
//  WHCCComponentManager.h
//  tztAppV4
//
//  Created by it-kangming on 2019/11/28.
//  Copyright © 2019 king. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHCCIComponent.h"
@class WHCC;
@class WHCCResult;

@interface WHCCComponentManager : NSObject

+ (instancetype)shareInstance;

- (WHCCResult *)call:(WHCC *)cc;

- (BOOL)isHaveComponent:(NSString *)componentName;

- (void)registerComponent:(NSString *)componentName;

- (void)unregisterComponent:(NSString *)componentName;

- (NSString *)getComponentByName:(NSString *)componentName;

- (void)addThreadToMainQueue:(NSOperation *)opreation;

- (void)addThreadToChildQueue:(NSOperation *)opreation;

@end

