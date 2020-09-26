//
//  Database.h
//  EncryptedDB_Example
//
//  Created by Nemo on 2020/9/26.
//  Copyright © 2020 AgoniNemo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface Database : NSObject


@property (nonatomic ,strong) FMDatabase * dataBase;
@property (nonatomic ,strong) FMDatabaseQueue *queue;

+(instancetype)dataManagerForQueue:(FMDatabaseQueue *)queue;

+(instancetype)rootDataBaseManagerForQueue:(FMDatabaseQueue *)queue;

-(BOOL)creatTabelWithKeys:(id)keys isId:(BOOL)is tableName:(NSString *)tableName;

/** 插入数据 */
-(BOOL)insertNewsData:(id)dict tableName:(NSString *)tableName;

/** 插入多条数据 */
-(BOOL)insertNewsDataWithArray:(NSArray *)array tableName:(NSString *)tableName;
/** 生成插入SQL语句*/
-(NSString *)insertSQLForDict:(NSDictionary *)dict tableName:(NSString *)tableName;
/** 事务执行SQL语句（name为线程名字）*/
-(BOOL)tarray:(NSArray *)array asyncName:(char *)name;
/** 通过表名查询所有 */
-(NSArray *)getAllDataTableName:(NSString *)tableName order:(NSString *)order;
-(NSArray *)getAllDataTableName:(NSString *)tableName field:(NSString * _Nullable)field conditions:(NSString *)conditions;

/** 数据是不是存在 */
-(BOOL)verifyDataWithDict:(NSDictionary *)dict relationship:(NSArray *)relationships tableName:(NSString *)tableName;
/** 数据是不是存在(condition为条件语句) */
-(BOOL)verifyDataForCondition:(NSString *)condition tableName:(NSString *)tableName;

/** 更新单条数据 */
-(BOOL)updateDataWithDict:(NSDictionary *)dict condition:(NSString *)condition tableName:(NSString *)tableName;

/** 更新多条数据 */
-(BOOL)updateDataWithArray:(NSArray<NSDictionary *>*)array condition:(NSArray<NSString *>*)conditions tableName:(NSString *)tableName;
/** 生成更新SQL语句 */
-(NSString *)updateSQLForDict:(NSDictionary *)dict condition:(NSString *)condition tableName:(NSString *)tableName;
/** 查询数据 */
-(NSArray *)inquireDataWithDict:(NSDictionary *)dict tableName:(NSString *)tableName;

/** 通过表名与条件查询数据 */
-(NSArray *)getDataWithTableName:(NSString *)tableName condition:(NSString *)condition conditionBack:(NSString *)conditionBack order:(NSString *)order;
/** 通过表名与条件查询数据个数 */
-(NSInteger)getCountDataTableName:(NSString *)tableName condition:(NSString *)condition;
/** 通过表名删除所有数据 */
-(BOOL)deleteAllForTableName:(NSString *)tableName;
/** 通过条件表名批量删除数据 */
-(BOOL)deleteDataForCondition:(NSString *)condition tableName:(NSString *)tableName;

/** 执行sql语句返回数据(数据为字典) */
-(NSArray *)carryOutsql:(NSString *)sql tableName:(NSString *)tableName;

/** 执行sql语句返回数据(数据为字符串)
 -(NSArray *)carryForOutsql:(NSString *)sql tableName:(NSString *)tableName;
 */
/** 判断表中是否有这个字段,没有就添加 */
-(BOOL)isExistDataByArray:(NSArray *)array tableName:(NSString *)tableName;

/** 通过表名添加字段 */
-(BOOL)addFieldByString:(NSString *)name tableName:(NSString *)tableName;
/** 通过表名生成添加字段语句 */
- (NSString *)generateAddFieldSQL:(NSString *)field tableName:(NSString *)tableName;

/** 判断表是否存在 */
-(BOOL)isExistTableForName:(NSString *)tableName;

/** 通过表名删除表 */
-(BOOL)deleteTableForName:(NSString *)tableName;
/** 通过表名生成删除表语句 */
-(NSString *)generateDeleteTableForName:(NSString *)tableName;

/** 查询数据库里所有的表名 */
-(NSArray *)getDatabaseAllTable;

/** 查询表里所有的字段名 */
-(NSArray *)getTableFieldForName:(NSString *)tableName;


@end

NS_ASSUME_NONNULL_END
