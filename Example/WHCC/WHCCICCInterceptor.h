//
//  WHCCICCInterceptor.h
//  tztAppV4
//
//  Created by it-kangming on 2019/12/10.
//  Copyright © 2019 king. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WHCCChain;
@class WHCCResult;

@protocol WHCCICCInterceptor <NSObject>

- (WHCCResult *)interceptWithChain:(WHCCChain *)chain;

@end

