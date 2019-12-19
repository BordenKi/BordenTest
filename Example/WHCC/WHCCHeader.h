//
//  WHCCHeader.h
//  tztAppV4
//
//  Created by it-kangming on 2019/12/12.
//  Copyright © 2019 king. All rights reserved.
//

#ifndef WHCCHeader_h
#define WHCCHeader_h

#ifdef DEBUG
#define WHCCErrorLog(fmt, ...) NSLog((@"WHCCError------->:" fmt), ##__VA_ARGS__)
#define WHCCInfoLog(fmt, ...) NSLog((@"WHCCInfo------->:" fmt), ##__VA_ARGS__)
#else
#define WHCCErrorLog(...)
#define WHCCInfoLog(...)
#endif

#import "WHCC.h"
#import "WHCCChain.h"
#import "WHCCResult.h"
#import "WHCCICCInterceptor.h"
#import "WHCCIComponent.h"
#import "WHCCAnnotation.h"
#import "WHCCThreadSafeDictionary.h"

#endif /* WHCCHeader_h */
