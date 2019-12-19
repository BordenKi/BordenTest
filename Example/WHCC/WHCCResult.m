//
//  WHCCResult.m
//  tztAppV4
//
//  Created by it-kangming on 2019/11/26.
//  Copyright © 2019 king. All rights reserved.
//

#import "WHCCResult.h"

static const NSString * WH_CC_NULL_KEY = @"WH_CC_NULL_KEY";

@interface WHCCResult ()

@property (nonatomic, assign) WHCCResultStatus code;

@property (nonatomic, assign) BOOL success;

@property (nonatomic, copy) NSString *errorMessage;

@property (nonatomic, strong) NSMutableDictionary <NSString *, NSObject *> *data;

@end

@implementation WHCCResult

+ (WHCCResult *)error:(NSString *)message
{
    WHCCResult *result = [[WHCCResult alloc] init];
    result.code = WHCCResultStatus_ERROR_BUSINESS;
    result.success = NO;
    result.errorMessage = message;
    return result;
}

+ (WHCCResult *)errorWithKey:(NSString *)key andValue:(NSObject *)value
{
    WHCCResult *result = [[WHCCResult alloc] init];
    result.code = WHCCResultStatus_ERROR_BUSINESS;
    result.success = NO;
    result.data = [[NSMutableDictionary alloc] init];
    [result.data setObject:value forKey:key];
    return result;
}

+ (WHCCResult *)errorWithCode:(NSInteger)code
{
    WHCCResult *result = [[WHCCResult alloc] init];
    result.code = code;
    result.success = false;
    return result;
}

+ (WHCCResult *)errorUnsupportedActionName
{
    return [self errorWithCode:WHCCResultStatus_ERROR_UNSUPPORTED_ACTION_NAME];
}

+ (WHCCResult *)successWithData:(NSMutableDictionary <NSString *, NSObject *> *)data
{
    WHCCResult *result = [[WHCCResult alloc] init];
    result.code = WHCCResultStatus_SUCCESS;
    result.success = YES;
    result.data = data;
    return result;
}

+ (WHCCResult *)successWithKey:(NSString *)key andValue:(NSObject *)value
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:value forKey:key];
    return [WHCCResult successWithData:data];
}

+ (WHCCResult *)successWithNoKey:(NSObject *)value
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:value forKey:WH_CC_NULL_KEY];
    return [WHCCResult successWithData:data];
}

+ (WHCCResult *)success
{
    return [WHCCResult successWithData:nil];
}

+ (WHCCResult *)defaultNullResult
{
    return [WHCCResult errorWithCode:WHCCResultStatus_ERROR_NULL_RESULT];
}

+ (WHCCResult *)defaultExceptionResult:(NSException *)exception
{
    if (exception != nil)
    {
        NSArray * arr = [exception callStackSymbols];
        NSString * reason = [exception reason];
        NSString * name = [exception name];
        NSString * url = [NSString stringWithFormat:@"========WHCC异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@",name,reason,[arr componentsJoinedByString:@"\n"]];
        NSLog(@"%@", url);
    }
    return [WHCCResult errorWithCode:WHCCResultStatus_ERROR_EXCEPTION_RESULT];
}

- (WHCCResult *(^)(NSString *, NSObject *))addData
{
    return ^(NSString *key, NSObject *value){
        [self.data setObject:value forKey:key];
        return self;
    };
}

- (NSString *)getErrorMessage
{
    return self.errorMessage;
}

- (NSInteger)getCode
{
    return self.code;
}

- (NSMutableDictionary <NSString *, NSObject *> *)getDataDic
{
    return self.data;
}

@end
