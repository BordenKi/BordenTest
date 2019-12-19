//
//  WHCCResult.h
//  tztAppV4
//
//  Created by it-kangming on 2019/11/26.
//  Copyright © 2019 king. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WHCCResultStatus) {
    /*
     WHCC调用成功
    */
    WHCCResultStatus_SUCCESS = 1,
    /*
     组件调用成功，但业务逻辑判定为失败
    */
    WHCCResultStatus_ERROR_BUSINESS = 2,
    /*
     保留状态码：默认的请求错误code
    */
    WHCCResultStatus_ERROR_DEFAULT = -1,
    /*
     没有指定组件名称
    */
    WHCCResultStatus_ERROR_COMPONENT_NAME_EMPTY = -2,
    /*
     result不该为null
     例如：组件回调时使用 WHCC.sendCCResult(callId, null) 或 interceptor返回null
    */
    WHCCResultStatus_ERROR_NULL_RESULT = -3,
    /*
     调用过程中出现exception
    */
    WHCCResultStatus_ERROR_EXCEPTION_RESULT = -4,
    /*
     没有找到组件能处理此次调用请求
    */
    WHCCResultStatus_ERROR_NO_COMPONENT_FOUND = -5,
    /*
     context 为null，自动获取application失败。
     需要在首次调用CC之前手动执行CC的初始化： CC.init(application);
    */
    WHCCResultStatus_ERROR_CONTEXT_NULL = -6,
    /*
     取消
    */
    WHCCResultStatus_ERROR_CANCELED = -8,
    /*
     超时
    */
    WHCCResultStatus_ERROR_TIMEOUT = -9,
    /*
     未调用CC.sendCCResult(callId, ccResult)方法
    */
    WHCCResultStatus_ERROR_CALLBACK_NOT_INVOKED = -10,
    /*
     跨进程组件调用时对象传输出错，可能是自定义类型没有共用
    */
    WHCCResultStatus_ERROR_REMOTE_CC_DELIVERY_FAILED = -11,
    /*
     组件不支持该actionName
    */
    WHCCResultStatus_ERROR_UNSUPPORTED_ACTION_NAME = -12,
};

@interface WHCCResult : NSObject
/*
 * 构建一个WHCCResult调用到了组件，但业务失败的WHCCResult
 * success=false, code=1 ({@link #WHCCResultStatus_ERROR_BUSINESS})
 * 可以通过WHCCResult.addData(key, value)来继续添加更多的返回信息
 * @param message 错误信息
 * @return 构造的WHCCResult对象
 */
+ (WHCCResult *)error:(NSString *)message;
/*
 * 构建一个WHCC调用到了组件，但业务失败的WHCCResult，没有errorMessage
 * success=false, code=1 ({@link #WHCCResultStatus_ERROR_BUSINESS})
 * 可以通过WHCCResult.addData(key, value)来继续添加更多的返回信息
 * @param key 存放在data中的key
 * @param value 存放在data中的value
 * @return 构造的WHCCResult对象
 */
+ (WHCCResult *)errorWithKey:(NSString *)key andValue:(NSObject *)value;
/*
 * 构建一个WHCC调用失败的WHCCResult，添加错误状态码
 * @param code 错误状态码
 * @return 构造的CCResult对象
 */
+ (WHCCResult *)errorWithCode:(NSInteger)code;
/*
 * 构建一个WHCC调用失败的WHCCResult：组件调用到了，但是该组件不能处理当前actionName
 * @return 构造的WHCCResult对象
 */
+ (WHCCResult *)errorUnsupportedActionName;
/*
 * 快捷构建一个WHCC调用成功的WHCCResult
 * success=true, code=0 ({@link #WHCCResultStatus_SUCCESS})
 * 可以通过WHCCResult.addData(key, value)来继续添加更多的返回信息
 * @param data 返回的信息
 * @return 构造的WHCCResult对象
 */
+ (WHCCResult *)successWithData:(NSMutableDictionary <NSString *, NSObject *> *)data;
/*
 * 快捷构建一个WHCC调用成功的WHCCResult
 * success=true, code=0 ({@link #WHCCResultStatus_SUCCESS})
 * 可以通过WHCCResult.addData(key, value)来继续添加更多的返回信息
 * @param key 存放在data中的key
 * @param value 存放在data中的value
 * @return 构造的WHCCResult对象
 */
+ (WHCCResult *)successWithKey:(NSString *)key andValue:(NSObject *)value;
/*
 * 快捷构建一个WHCC调用成功的WHCCResult
 * success=true, code=0 ({@link #WHCCResultStatus_SUCCESS})
 * 可以通过WHCCResult.addData(key, value)来继续添加更多的返回信息
 * @param value 存放在data中的value
 * @return 构造的WHCCResult对象
 */
+ (WHCCResult *)successWithNoKey:(NSObject *)value;
/*
 * 快捷构建一个WHCC调用成功的WHCCResult，只包含成功的状态，没有其它信息
 * success=true, code=0 ({@link #WHCCResultStatus_SUCCESS})
 * 可以通过WHCCResult.addData(key, value)来继续添加更多的返回信息
 * @return 构造的CCResult对象
 */
+ (WHCCResult *)success;
/*
 * 快捷构建一个WHCC调用成功的WHCCResult，返回结果集为nil的
 */
+ (WHCCResult *)defaultNullResult;
/*
 * 快捷构建一个WHCC调用成功的WHCCResult，带有异常情况的
 * success=false code=-4 ({@link #WHCCResultStatus_ERROR_EXCEPTION_RESULT})
 * @param exception 异常信息
 */
+ (WHCCResult *)defaultExceptionResult:(NSException *)exception;
/*
 * 链式添加数据到data中
 * @param key 存放在data中的key
 * @param value 存放在data中的value
 */
- (WHCCResult *(^)(NSString *key, NSObject *value))addData;
/*
* 获取错误信息
*/
- (NSString *)getErrorMessage;
/*
* 获取状态码
*/
- (NSInteger)getCode;
/*
* 获取获取返回结果值
 * @param key 存放在data中的key
 * @param value 存放在data中的value
*/
- (NSMutableDictionary <NSString *, NSObject *> *)getDataDic;

@end
