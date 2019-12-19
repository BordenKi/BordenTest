//
//  WHCCLocalCCInterceptorHolder.h
//  tztAppV4
//
//  Created by it-kangming on 2019/12/10.
//  Copyright © 2019 king. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHCCICCInterceptor.h"

@interface WHCCLocalCCInterceptorHolder : NSObject<WHCCICCInterceptor>

+ (instancetype)shareIntstance;

@end

