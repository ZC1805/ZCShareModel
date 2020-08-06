//
//  ZCModel.m
//  ZCKit
//
//  Created by admin on 2018/11/3.
//  Copyright © 2018 Squat in house. All rights reserved.
//

#import "ZCModel.h"
#import <objc/runtime.h>
#import "NSDictionary+ZC.h"

#pragma mark - ~ ZCModel ~
@implementation ZCModel

- (void)willPropertyAssignment:(NSDictionary *)jsonDic {
    //sub class override
}

- (instancetype)initWithJsonDic:(nullable NSDictionary *)jsonDic {
    if (self = [super init]) {
        if (!jsonDic || ![jsonDic isKindOfClass:NSDictionary.class])  {
            jsonDic = [NSDictionary dictionary];
        }
        [self willPropertyAssignment:jsonDic];
        if ([self respondsToSelector:@selector(propertyAssignmentFromJsonDic:)]) {
            [self propertyAssignmentFromJsonDic:jsonDic];
        }
        if ([self respondsToSelector:@selector(propertyAssignmentFinish)]) {
            [self propertyAssignmentFinish];
        }
    }
    return self;
}

+ (NSArray *)instancesWithJsonDicArr:(nullable NSArray *)jsonDicArr {
    if (!jsonDicArr || ![jsonDicArr isKindOfClass:NSArray.class]) {
        jsonDicArr = [NSArray array];
    }
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:jsonDicArr.count];
    for (int i = 0; i < jsonDicArr.count; i ++) {
        [items addObject:[[self alloc] initWithJsonDic:[jsonDicArr dictionaryValueForIndex:i]]];
    }
    return items.copy;
}

@end


#pragma mark - ~ ZCShareModel ~
@interface ZCShareModel ()

@property (nonatomic, assign) int var_blankCount;

@property (nonatomic, assign) unsigned long var_aimMask;

@end

@implementation ZCShareModel

- (instancetype)init {
    if (self = [super init]) {
        self.var_blankCount = 0;
        [self assignmentPropertyFromParameter:nil];
    }
    return self;
}

- (instancetype)initWithBlankCount:(int)blankCount {
    if (self = [super init]) {
        self.var_blankCount = blankCount + 1;
        [self assignmentPropertyFromParameter:nil];
    }
    return self;
}

- (void)willPropertyAssignment:(NSDictionary *)jsonDic {
    self.var_blankCount = 0;
    [self assignmentPropertyFromParameter:jsonDic];
}

#pragma mark - Core
- (NSMutableDictionary *)extractKeyValueToDictionary {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *arrayType = NSStringFromClass(NSArray.class);
    NSString *stringType = NSStringFromClass(NSString.class);
    NSString *longType = [NSString stringWithCString:@encode(long) encoding:NSASCIIStringEncoding];
    NSString *floatType = [NSString stringWithCString:@encode(float) encoding:NSASCIIStringEncoding];
    [self.class.validPropertyKvs enumerateKeysAndObjectsUsingBlock:^(NSString *ivar_name, NSArray <NSString *>*ivar_arr, BOOL *stop) {
        BOOL isAppointExtractKey = NO;
        id ivar_value = [self valueForKey:ivar_name];
        long ivar_mask = (int)[ivar_arr longValueForIndex:1];
        NSString *ivar_type = [ivar_arr stringValueForIndex:0];
        NSString *ivar_arr_name = [ivar_arr stringValueForIndex:2];
        BOOL isAppointExtractMap = self.class.shareModelNeedBeExtractKey != nil;
        if (isAppointExtractMap) isAppointExtractKey = [self.class.shareModelNeedBeExtractKey containsObject:ivar_name];
        NSString *aimKey = [self dataKeyFromObjectKey:ivar_name];
        if (ivar_value != nil) {
            if ([ivar_value isKindOfClass:NSString.class] && [ivar_type isEqualToString:stringType]) {
                if (isAppointExtractMap) {
                    if (isAppointExtractKey) {
                        [parameters setObject:ivar_value forKey:aimKey];
                    }
                } else {
                    if (((NSString *)ivar_value).length) {
                        [parameters setObject:ivar_value forKey:aimKey];
                    }
                }
            } else if ([ivar_value isKindOfClass:NSNumber.class] && [ivar_type isEqualToString:longType]) {
                if (isAppointExtractMap) {
                    if (isAppointExtractKey) {
                        [parameters setObject:ivar_value forKey:aimKey];
                    }
                } else {
                    if (self.var_aimMask & (1 << ivar_mask)) {
                        [parameters setObject:ivar_value forKey:aimKey];
                    } else if (((NSNumber *)ivar_value).longValue != 0) {
                        [parameters setObject:ivar_value forKey:aimKey];
                    }
                }
            } else if ([ivar_value isKindOfClass:NSNumber.class] && [ivar_type isEqualToString:floatType]) {
                if (isAppointExtractMap) {
                    if (isAppointExtractKey) {
                        [parameters setObject:ivar_value forKey:aimKey];
                    }
                } else {
                    if (self.var_aimMask & (1 << ivar_mask)) {
                        [parameters setObject:ivar_value forKey:aimKey];
                    } else if (((NSNumber *)ivar_value).floatValue != 0) {
                        [parameters setObject:ivar_value forKey:aimKey];
                    }
                }
            } else if ([ivar_value isKindOfClass:NSArray.class] && [ivar_type isEqualToString:arrayType]) {
                if (isAppointExtractMap) {
                    if (isAppointExtractKey) {
                        NSMutableArray *submArr = [self.class objectToArr:(NSArray *)ivar_value itemModelType:ivar_arr_name];
                        [parameters setObject:submArr forKey:aimKey];
                    }
                } else {
                    NSMutableArray *submArr = [self.class objectToArr:(NSArray *)ivar_value itemModelType:ivar_arr_name];
                    if (submArr.count) {
                        [parameters setObject:submArr forKey:aimKey];
                    }
                }
            } else if ([ivar_value isKindOfClass:ZCShareModel.class] && [NSClassFromString(ivar_type) isSubclassOfClass:ZCShareModel.class]) {
                if (isAppointExtractMap) {
                    if (isAppointExtractKey && ((ZCShareModel *)ivar_value).var_blankCount == 0) { //此处做特殊处理，即使被制定了取值但是ZCShareModel对象无有效值也会被过滤
                        NSMutableDictionary *subParm = [(id)ivar_value extractKeyValueToDictionary];
                        [parameters setObject:subParm forKey:aimKey];
                    }
                } else {
                    NSMutableDictionary *subParm = [(id)ivar_value extractKeyValueToDictionary];
                    if (subParm.count) {
                        [parameters setObject:subParm forKey:aimKey];
                    }
                }
            } else {
                NSAssert(0, @"parameter type is mistake");
            }
        }
    }];
    return parameters;
}

- (void)assignmentPropertyFromParameter:(NSDictionary *)jsonDic {
    NSString *arrayType = NSStringFromClass(NSArray.class);
    NSString *stringType = NSStringFromClass(NSString.class);
    NSString *longType = [NSString stringWithCString:@encode(long) encoding:NSASCIIStringEncoding];
    NSString *floatType = [NSString stringWithCString:@encode(float) encoding:NSASCIIStringEncoding];
    [self.class.validPropertyKvs enumerateKeysAndObjectsUsingBlock:^(NSString *ivar_name, NSArray <NSString *>*ivar_arr, BOOL *stop) {
        NSString *ivar_arr_name = [ivar_arr stringValueForIndex:2];
        NSString *ivar_type = [ivar_arr stringValueForIndex:0];
        long ivar_mask = (int)[ivar_arr longValueForIndex:1];
        if ([ivar_type isEqualToString:longType]) {
            [self setValue:[self json:jsonDic objectKey:ivar_name objectCalss:ivar_type type:0 mask:ivar_mask] forKey:ivar_name];
        } else if ([ivar_type isEqualToString:floatType]) {
            [self setValue:[self json:jsonDic objectKey:ivar_name objectCalss:ivar_type type:1 mask:ivar_mask] forKey:ivar_name];
        } else if ([ivar_type isEqualToString:stringType]) {
            [self setValue:[self json:jsonDic objectKey:ivar_name objectCalss:ivar_type type:2 mask:ivar_mask] forKey:ivar_name];
        } else if ([ivar_type isEqualToString:arrayType]) {
            [self setValue:[self.class arrToObject:[self json:jsonDic objectKey:ivar_name objectCalss:ivar_type type:3 mask:ivar_mask] itemModelType:ivar_arr_name] forKey:ivar_name];
        } else if ([NSClassFromString(ivar_type) isSubclassOfClass:ZCShareModel.class]) {
            [self setValue:[self json:jsonDic objectKey:ivar_name objectCalss:ivar_type type:4 mask:ivar_mask] forKey:ivar_name];
        } else {
            NSAssert(0, @"parameter type is mistake");
        }
    }];
}

#pragma mark - Misc
- (NSString *)dataKeyFromObjectKey:(NSString *)objectKey {
    NSString *aimKey = [self.class.shareModelObjectKeyToDataKey stringValueForKey:objectKey];
    if (!aimKey.length) aimKey = objectKey;
    return aimKey;
}

- (id)json:(NSDictionary *)jsonDic objectKey:(NSString *)objectKey objectCalss:(NSString *)objectCalss type:(int)type mask:(long)mask {
    __block NSString *aimKey = objectKey;
    if (!jsonDic) jsonDic = [NSDictionary dictionary];
    [self.class.shareModelDataKeyToObjectKey enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        if ([obj isEqualToString:objectKey]) {aimKey = key; *stop = YES;} //找到第一个就返回
    }];
    if (type == 0) {
        if ([jsonDic.allKeys containsObject:aimKey]) {
            self.var_aimMask |= (1 << mask);
            return [NSNumber numberWithLong:[jsonDic longValueForKey:aimKey]];
        } else {
            self.var_aimMask &= ~(1 << mask);
            return [NSNumber numberWithLong:0];
        }
    } else if (type == 1) {
        if ([jsonDic.allKeys containsObject:aimKey]) {
            self.var_aimMask |= (1 << mask);
            return [NSNumber numberWithFloat:[jsonDic floatValueForKey:aimKey]];
        } else {
            self.var_aimMask &= ~(1 << mask);
            return [NSNumber numberWithFloat:0];
        }
    } else if (type == 2) {
        return [jsonDic stringValueForKey:aimKey];
    } else if (type == 3) {
        return [jsonDic arrayValueForKey:aimKey];
    } else {
        id value = [jsonDic objectForKey:aimKey];
        if (value && [value isKindOfClass:ZCShareModel.class]) {
            return value;
        } else {
            NSDictionary *subJsonDic = [jsonDic dictionaryValueForKey:aimKey];
            if (subJsonDic.count) {
                return [[NSClassFromString(objectCalss) alloc] initWithJsonDic:subJsonDic];
            } else if (self.var_blankCount < 4) {
                return [[NSClassFromString(objectCalss) alloc] initWithBlankCount:self.var_blankCount];
            } else {
                return nil; //最多空4次
            }
        }
    }
}

#pragma mark - Override
+ (NSDictionary <NSString *, NSString *>*)shareModelDataKeyToObjectKey {
    return nil; //返回键值都是唯一且一一对应
}

+ (NSDictionary <NSString *, NSString *>*)shareModelObjectKeyToDataKey {
    return nil; //返回键值都是唯一且一一对应
}

+ (NSDictionary <NSString *, NSString *>*)shareModelObjectArrayKeyClassName {
    return nil; //需要明确指明数组属性成员对象的类型(就是指明是哪个子类的类型，多维数组此处key为最外层键)
}

+ (NSArray <NSString *>*)shareModelNeedBeExtractKey {
    return nil; //返回当前对象的需要被提属性类型long或float类型取键名
}

#pragma mark - Private
+ (NSArray *)arrToObject:(NSArray *)originArr itemModelType:(NSString *)itemModelType {
    NSMutableArray *newmArr = [NSMutableArray array];
    for (id originItem in originArr) {
        if ([originItem isKindOfClass:NSDictionary.class]) {
            [newmArr addObject:[[NSClassFromString(itemModelType) alloc] initWithJsonDic:(NSDictionary *)originItem]];
        } else if ([originItem isKindOfClass:NSArray.class]) {
            [newmArr addObject:[NSClassFromString(itemModelType) arrToObject:(NSArray *)originItem itemModelType:itemModelType]];
        } else if ([originItem isKindOfClass:ZCShareModel.class]) {
            [newmArr addObject:originItem];
        } else if ([originItem isKindOfClass:NSString.class]) {
            [newmArr addObject:originItem];
        } else if ([originItem isKindOfClass:NSNumber.class]) {
            [newmArr addObject:originItem];
        } else {
            NSAssert(0, @"parameter type is mistake");
        }
    }
    return newmArr.copy;
}

+ (NSMutableArray *)objectToArr:(NSArray *)originArr itemModelType:(NSString *)itemModelType {
    NSMutableArray *newmArr = [NSMutableArray array];
    for (id originItem in originArr) {
        if ([originItem isKindOfClass:NSDictionary.class]) {
            [newmArr addObject:((NSDictionary *)originItem).mutableCopy];
        } else if ([originItem isKindOfClass:ZCShareModel.class]) {
            [newmArr addObject:[(id)originItem extractKeyValueToDictionary]];
        } else if ([originItem isKindOfClass:NSArray.class]) {
            [newmArr addObject:[NSClassFromString(itemModelType) objectToArr:(NSArray *)originItem itemModelType:itemModelType]];
        } else if ([originItem isKindOfClass:NSString.class]) {
            [newmArr addObject:originItem];
        } else if ([originItem isKindOfClass:NSNumber.class]) {
            [newmArr addObject:originItem];
        } else {
            NSAssert(0, @"parameter type is mistake");
        }
    }
    return newmArr;
}

+ (NSDictionary *)validPropertyKvs {
    if ([ZCShareModel.subClassPropertyInfo containsObjectForKey:NSStringFromClass(self)]) {
        return [ZCShareModel.subClassPropertyInfo dictionaryValueForKey:NSStringFromClass(self)];
    }
    NSMutableDictionary *aimKvs = [NSMutableDictionary dictionary];
    NSMutableArray *supClassNameArr = [NSMutableArray array];
    for (Class model = self; [model isSubclassOfClass:ZCShareModel.class]; model = model.superclass) {
        [supClassNameArr insertObject:NSStringFromClass(model) atIndex:0];
    }
    int initMask = 0;
    for (NSString *model in supClassNameArr) {
        NSArray *modelInfo = [NSClassFromString(model) modelPropertyInfo:initMask];
        NSDictionary *ipaKvs = modelInfo.firstObject;
        NSDictionary *maskInfo = modelInfo.lastObject;
        initMask = (int)[maskInfo longValueForKey:@"initMask"];
        [aimKvs addEntriesFromDictionary:ipaKvs];
        if (![ZCShareModel.subClassPropertyInfo containsObjectForKey:model]) {
            [ZCShareModel.subClassPropertyInfo setObject:aimKvs.copy forKey:model];
        }
    }
    return aimKvs.copy;
}

+ (NSArray <NSDictionary *>*)modelPropertyInfo:(int)initMask {
    NSString *arrayType = NSStringFromClass(NSArray.class);
    NSString *stringType = NSStringFromClass(NSString.class);
    NSString *longType = [NSString stringWithCString:@encode(long) encoding:NSASCIIStringEncoding];
    NSString *floatType = [NSString stringWithCString:@encode(float) encoding:NSASCIIStringEncoding];
    unsigned int propertyCount = 0;
    NSMutableDictionary *ipaKvs = [NSMutableDictionary dictionary];
    objc_property_t *propertys = class_copyPropertyList(self, &propertyCount);
    for (int i = 0; i < propertyCount; i ++) {
        objc_property_t property = propertys[i];
        const char *propertyName = property_getName(property);
        NSString *name = [NSString stringWithUTF8String:propertyName];
        if (name && name.length && ![name hasPrefix:@"var_"] && ![ZCShareModel.basePropertyNames containsObject:name]) {
            NSString *ipaType = [ZCShareModel obtainPropertyType:property];
            if ([ipaType isEqualToString:longType] || [ipaType isEqualToString:floatType] ||
                [ipaType isEqualToString:stringType] || [ipaType isEqualToString:arrayType] ||
                [NSClassFromString(ipaType) isSubclassOfClass:ZCShareModel.class]) {
                int ipaMask = 0;
                if ([ipaType isEqualToString:longType] || [ipaType isEqualToString:floatType]) {initMask ++; ipaMask = initMask;}
                if (ipaMask > 60) {NSAssert(0, @"parameter count is mistake");}
                NSString *arrSubClassType = [[self shareModelObjectArrayKeyClassName] stringValueForKey:name];
                if (!arrSubClassType.length) arrSubClassType = NSStringFromClass(ZCShareModel.class);
                if (![NSClassFromString(arrSubClassType) isSubclassOfClass:ZCShareModel.class]) {
                    NSAssert(0, @"array must sub ZCShareModel type");
                    arrSubClassType = NSStringFromClass(ZCShareModel.class);
                }
                NSArray *ipaArr = @[ipaType, [NSString stringWithFormat:@"%d", ipaMask], arrSubClassType];
                [ipaKvs setObject:ipaArr forKey:name];
            }
        }
    }
    free(propertys);
    return @[ipaKvs.copy, @{@"initMask":@(initMask)}];
}

+ (NSArray *)basePropertyNames {
    static NSArray *basePropertyNames = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *arrayType = NSStringFromClass(NSArray.class);
        NSString *stringType = NSStringFromClass(NSString.class);
        NSString *longType = [NSString stringWithCString:@encode(long) encoding:NSASCIIStringEncoding];
        NSString *floatType = [NSString stringWithCString:@encode(float) encoding:NSASCIIStringEncoding];
        unsigned int superPropertyCount = 0;
        NSMutableArray *superNames = [NSMutableArray array];
        objc_property_t *superPropertys = class_copyPropertyList(ZCShareModel.class, &superPropertyCount);
        for (int i = 0; i < superPropertyCount; i ++) {
            objc_property_t superProperty = superPropertys[i];
            const char *superPropertyName = property_getName(superProperty);
            NSString *superName = [NSString stringWithUTF8String:superPropertyName];
            if (superName && superName.length && ![superName hasPrefix:@"var_"]) {
                NSString *superType = [ZCShareModel obtainPropertyType:superProperty];
                if ([superType isEqualToString:longType] || [superType isEqualToString:floatType] ||
                    [superType isEqualToString:stringType] || [superType isEqualToString:arrayType] ||
                    [NSClassFromString(superType) isSubclassOfClass:ZCShareModel.class]) {
                    [superNames addObject:superName];
                }
            }
        }
        free(superPropertys);
        basePropertyNames = superNames.copy;
    });
    return basePropertyNames;
}

+ (NSMutableDictionary *)subClassPropertyInfo {
    static NSMutableDictionary *subPropertyInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        subPropertyInfo = [NSMutableDictionary dictionary];
    });
    return subPropertyInfo;
}

+ (NSString *)obtainPropertyType:(objc_property_t)property {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    NSString *type = @"";
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (strlen(attribute) < 2) continue;
        if (attribute[0] == 'T') {
            if (attribute[1] != '@') {
                type = [[NSString alloc] initWithBytes:(attribute + 1) length:(strlen(attribute) - 1) encoding:NSASCIIStringEncoding];
            } else if (strlen(attribute) > 4) {
                type = [[NSString alloc] initWithBytes:(attribute + 3) length:(strlen(attribute) - 4) encoding:NSASCIIStringEncoding];
            } break;
        }
    }
    return type;
}

@end
