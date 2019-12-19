//
//  WHCCMonitor.h
//  tztAppV4
//
//  Created by it-kangming on 2019/11/29.
//  Copyright © 2019 king. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WHCC;

@interface WHCCMonitor : NSObject

+ (instancetype)shareInstance;

- (WHCC *)getCCByID:(NSString *)callID;

- (void)removeCCByID:(NSString *)callID;

- (void)addMonitorFor:(WHCC *)cc;

@end
