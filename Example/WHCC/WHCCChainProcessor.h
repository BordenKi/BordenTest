//
//  WHCCChainProcessor.h
//  tztAppV4
//
//  Created by it-kangming on 2019/12/11.
//  Copyright © 2019 king. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WHCCResult;
@class WHCCChain;

@interface WHCCChainProcessor : NSOperation

- (instancetype)initWithChain:(WHCCChain *)chain;

- (WHCCResult *)call;

@end

