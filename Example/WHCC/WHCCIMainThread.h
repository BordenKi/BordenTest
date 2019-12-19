//
//  WHCCIMainThread.h
//  tztAppV4
//
//  Created by it-kangming on 2019/12/11.
//  Copyright © 2019 king. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WHCC;

@protocol WHCCIMainThread <NSObject>

- (BOOL)shouldActionRunOnMainThreadWithAtionName:(NSString *)ationName andCC:(WHCC *)cc;

@end

