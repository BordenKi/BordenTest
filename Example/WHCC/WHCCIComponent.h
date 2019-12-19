//
//  WHCCIComponent.h
//  tztAppV4
//
//  Created by it-kangming on 2019/12/10.
//  Copyright © 2019 king. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WHCC;

@protocol WHCCIComponent <NSObject>

@required
- (NSString *)getName;

- (BOOL)onCall:(WHCC *)cc;

@end

