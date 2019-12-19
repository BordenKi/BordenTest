//
//  WHCCChain.h
//  tztAppV4
//
//  Created by it-kangming on 2019/12/10.
//  Copyright © 2019 king. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "WHCCICCInterceptor.h"
@class WHCCResult;
@class WHCC;

@interface WHCCChain : NSObject

- (instancetype)initWithCC:(WHCC *)cc;

- (void)addInterceptor:(NSObject <WHCCICCInterceptor>*)interceptor;

- (void)addInterceptorWithArr:(NSArray <NSObject <WHCCICCInterceptor>*>*)interceptorsArr;

- (WHCCResult *)proceed;

- (WHCC *)getCC;

@end
