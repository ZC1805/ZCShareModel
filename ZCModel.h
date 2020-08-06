//
//  ZCModel.h
//  ZCKit
//
//  Created by admin on 2018/11/3.
//  Copyright © 2018 Squat in house. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZCModelProtocol <NSObject>  /**< 手动转换需要子类实现的协议 */

@optional

- (void)propertyAssignmentFinish;  /**< 对象解析完成，供子类实现 */

- (void)propertyAssignmentFromJsonDic:(NSDictionary *)jsonDic;  /**< 解析字典对象，供子类实现 */

@end

@interface ZCModel : NSObject <ZCModelProtocol>  /**< 模型对象，供子类实现 */

- (instancetype)initWithJsonDic:(nullable NSDictionary *)jsonDic;  /**< 用json字典初始化 */

+ (NSArray *)instancesWithJsonDicArr:(nullable NSArray <NSDictionary *>*)jsonDicArr;  /**< 用json字典数组初始化实例对象数组 */

@end


@interface ZCShareModel : ZCModel  /**< 简单的字典与对象互转类 */

/** 需要解析的属性类型只能为ZCShareModel子类、NSString、NSArray、float、long五种类型，不需要解析的属性名以var_开头 */
/** 属性字段类型NSString初始值@""、NSArray初始值@[]、long初始值0、float初始值0、ZCShareModel子类初始值为空对象(即所有属性为无效值)或nil */

/** 将对象所有非var_开头的属性按KeyValue构造成一个可变字典对象(容器内为NSMutableDictionary、NSMutableArray、NSNumber、NSString四种类型) */
/** 注意1: shareModelNeedBeExtractKey非nil则按此数组成员作本对象的键来取值(值可能为@"",@[],@{},空ZCShareModel不被提取)，如果为nil则按下面规则 */
/** 注意2: 取值long和float类型属性时，属性未被标记或者属性的值为0时，取值时候都会当无效值而被过滤，不会提取到可变字典中 */
/** 注意3: 其余类型属性值为nil、@""、空ZCShareModel子类、容器的count为0(数组内所有值不会被过滤)会当无效值而被过滤 */
- (NSMutableDictionary *)extractKeyValueToDictionary;

/** 数据的键对应到模型对象的键，供子类实现，不实现则返回nil(即不替换) */
+ (nullable NSDictionary <NSString *, NSString *>*)shareModelDataKeyToObjectKey;

/** 模型对象的键对应到数据的键，供子类实现，不实现则返回nil(即不替换) */
+ (nullable NSDictionary <NSString *, NSString *>*)shareModelObjectKeyToDataKey;

/** 模型对象属性为数组(或多维数组)且数组的终极成员对象类型为ZCShareModel子类类型，在此需要明确指明数组成员对象类型，默认返回nil(即为ZCShareModel类型) */
+ (nullable NSDictionary <NSString *, NSString *>*)shareModelObjectArrayKeyClassName;

/** 模型对象转数据时需要被提取的键名，默认返回nil(即属性被标记或值不为0会被提取，或属性值非nil、非@""、非空ZCShareModel子类、非容器的count为0(数组内数据都会被过滤)会被提取) */
+ (nullable NSArray <NSString *>*)shareModelNeedBeExtractKey;

@end

NS_ASSUME_NONNULL_END
