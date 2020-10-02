//
//  DatabaseCenter.h
//  xiangwan
//
//  Created by mac on 2019/8/22.
//  Copyright © 2019 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DatabaseCenter : NSObject

/// 单例
+ (DatabaseCenter *)sharedDatabaseCenter;

@property (nonatomic, copy) NSString *dbKey;

/**
 * 通过模型数组创建数据库表
 * 生成的表名为：t_模型类名
 *
 */
- (void)createDBWithArray:(NSArray <Class>*)ary;

/** 更新数据 */
-(BOOL)updateDataWithDict:(NSDictionary *)dict
               conditions:(NSString *)conditions
                    class:(Class)className;
/** 更新多条数据 */
-(BOOL)updateDataWithArray:(NSArray<NSDictionary *>*)array
                 condition:(NSArray<NSString *>*)conditions
                     class:(Class)className;
/** 插入数据 */
-(BOOL)insertNewsData:(NSDictionary *)dict
                class:(Class)className;
/** 插入多条数据 */
-(BOOL)insertMoreData:(NSArray <NSDictionary *>*)ary
                class:(Class)className;

/** 数据是不是存在(condition为条件语句) */
-(BOOL)verifyDataForCondition:(NSString *)condition
                        class:(Class)className;

/** 通过表名查询所有 */
-(NSArray *)getAllDataClass:(Class)className;

/** 删除所有数据 */
-(BOOL)deleteAllConditions:(NSString *)conditions
                     class:(Class)className;

/** 通过表名与条件查询数据 */
-(NSArray *)getAllDataWithConditions:(NSString *)conditions
                               class:(Class)className;


@end

NS_ASSUME_NONNULL_END
