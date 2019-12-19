//
//  WHCCWait4ResultInterceptor.h
//  tztAppV4
//
//  Created by it-kangming on 2019/12/11.
//  Copyright © 2019 king. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHCCICCInterceptor.h"

@interface WHCCWait4ResultInterceptor : NSObject<WHCCICCInterceptor>

+ (instancetype)shareIntstance;

@end

