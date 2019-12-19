//
//  WHCCChain.m
//  tztAppV4
//
//  Created by it-kangming on 2019/12/10.
//  Copyright © 2019 king. All rights reserved.
//

#import "WHCCChain.h"
#import "WHCC.h"
#import "WHCCICCInterceptor.h"

@interface WHCCChain ()

@property (nonatomic, assign) int index;

@property (nonatomic, strong) WHCC *cc;

@property (nonatomic, strong) NSMutableArray <NSObject <WHCCICCInterceptor>* >*interceptors;

@end

@implementation WHCCChain

- (instancetype)initWithCC:(WHCC *)cc
{
    self = [super init];
    if (self)
    {
        _index = 0;
        _cc = cc;
    }
    return self;
}

- (void)addInterceptor:(NSObject <WHCCICCInterceptor>*)interceptor
{
    [self.interceptors addObject:interceptor];
}

- (void)addInterceptorWithArr:(NSArray <NSObject <WHCCICCInterceptor>*>*)interceptorsArr
{
    [self.interceptors addObjectsFromArray:interceptorsArr];
}

- (WHCCResult *)proceed
{
    if (_index > self.interceptors.count) {
        return [WHCCResult defaultNullResult];
    }
    NSObject <WHCCICCInterceptor>*obj = self.interceptors[_index];
    _index ++;
    if (obj == nil) {
        return [self proceed];
    }
    WHCCResult *result;
    if ([_cc isFinished]) {
        result = [_cc getResult];
    }else{
        @try {
            if ([obj respondsToSelector:@selector(interceptWithChain:)]) {
                result = [obj interceptWithChain:self];
            }
        } @catch (NSException *exception) {
            result = [WHCCResult defaultExceptionResult:exception];
        }
    }
    if (result == nil) {
        result = [WHCCResult defaultNullResult];
    }
    return result;
}

#pragma mark - setter and getter

- (NSMutableArray<NSObject <WHCCICCInterceptor>*> *)interceptors
{
    if (!_interceptors) {
        _interceptors = @[].mutableCopy;
    }
    return _interceptors;
}

- (WHCC *)getCC
{
    return _cc;
}


@end
