//
//  Database.m
//  EncryptedDB_Example
//
//  Created by Nemo on 2020/9/26.
//  Copyright © 2020 AgoniNemo. All rights reserved.
//

#import "Database.h"

@interface Database()
@property (nonatomic, strong) NSString *dbKey;
@end

@implementation Database

static NSString *const DBKEY = @"89FB940530BD285E86D2DE90081FAB6F";

-(void)setDatabaseKey:(NSString *)key {
    _dbKey = key;
}

-(NSString *)dbKey {
    return _dbKey ?: DBKEY;
}

+(instancetype)dataManagerForQueue:(FMDatabaseQueue *)queue {
    Database *dataBase = [[self alloc] init];
    dataBase.queue = queue;
    return dataBase;
}

/** 创建表（用item：模型，name：表名来创建） */

-(BOOL)creatTabelWithKeys:(id)keys isId:(BOOL)is tableName:(NSString *)tableName{
    NSAssert(keys != nil, @"字段数组为空！");
    return [self creatTabelKeys:keys isId:is tableName:tableName];
    
}
+(instancetype)rootDataBaseManagerForQueue:(FMDatabaseQueue *)queue{
    
    Database *db = [[self alloc] init];
    db.queue = queue;
    return db;
}

/** 更新单条数据 */
-(BOOL)updateDataWithDict:(NSDictionary *)dict condition:(NSString *)condition tableName:(NSString *)tableName {
    
    return [self tarray:@[[self updateSQLForDict:dict condition:condition tableName:tableName]] asyncName:"RootDataBaseManagerUpateNewsDataWithArray"];
}

/** 更新多条数据 */
-(BOOL)updateDataWithArray:(NSArray<NSDictionary *>*)array condition:(NSArray<NSString *>*)conditions tableName:(NSString *)tableName{
    
    NSMutableArray *transactionSql= [[NSMutableArray alloc]init];
    
    for (int j = 0; j < array.count; j ++) {
        NSDictionary *dict = array[j];
        [transactionSql addObject:[self updateSQLForDict:dict condition:conditions[j] tableName:tableName]];
    }
    return [self tarray:transactionSql asyncName:"RootDataBaseManagerUpateNewsDataWithArray"];
}

-(NSString *)updateSQLForDict:(NSDictionary *)dict condition:(NSString *)condition tableName:(NSString *)tableName{
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"update %@ set ",tableName];
    NSArray *keys = [dict allKeys];
    for (int i = 0; i < keys.count; i ++) {
        NSString *key = keys[i];
        if (![key isEqualToString:@"userId"]) {
            NSString *value = dict[key];
            if (value == nil ||
                ![value isKindOfClass:NSString.class]) {
                value = @"";
            }
            if ([value containsString:@"'"]) {
                NSMutableString *newValue = [NSMutableString stringWithString:value];
                NSRange range = [newValue rangeOfString:@"'"];
                [newValue insertString:@"'"atIndex:range.location];
                value = newValue;
            }
            NSString *str = [NSString stringWithFormat:@"%@ = '%@'",key,value];
            NSString *tag = (i == keys.count - 1)?@" ":@",";
            [sql appendFormat:@"%@%@",str,tag];
        }else{
            if (i == keys.count - 1) {
                if ([[sql substringFromIndex:sql.length-1] isEqualToString:@","]) {
                    sql = [NSMutableString stringWithFormat:@"%@",[sql substringToIndex:sql.length-1]];
                }
            }
        }
    }
    NSAssert(sql != nil, @"更新SQL的语句为空！");
    [sql appendFormat:@" where %@",condition];
    //    NSLog(@"更新SQL:%@",sql);
    return sql;
    
}

-(NSString *)insertSQLForDict:(NSDictionary *)dict tableName:(NSString *)tableName{
    
    NSString *format = [NSString stringWithFormat:@"insert into %@ (",tableName];
    NSMutableString *valuesFlag = [NSMutableString stringWithString:@" values ("];
    
    NSMutableString *sql = [NSMutableString string];
    
    NSArray *keys = [dict allKeys];
    
    for (int i = 0 ; i < keys.count; i ++) {
        NSString *key = keys[i];
        NSString *value = dict[key];
        if (value == nil ||
            ![value isKindOfClass:NSString.class]) {
            value = @"";
        }
        if ([value containsString:@"'"]) {
            NSMutableString *newValue = [NSMutableString stringWithString:value];
            NSRange range = [newValue rangeOfString:@"'"];
            [newValue insertString:@"'"atIndex:range.location];
            value = newValue;
        }
        if (i == keys.count -1) {
            [sql appendFormat:@"%@)",key];
            [valuesFlag appendFormat:@"'%@') ",value];
        }else{
            [valuesFlag appendFormat:@"'%@',",value];
            [sql appendFormat:@"%@,",key];
        }
    }
    [sql appendString:valuesFlag];
    
    return  [NSString stringWithFormat:@"%@ %@",format,sql];
}

-(BOOL)insertNewsData:(id)dict tableName:(NSString *)tableName{
    return [self insertNewsDataWithArray:@[dict] tableName:tableName];
}


/** 插入多条数据 */
-(BOOL)insertNewsDataWithArray:(NSArray *)array tableName:(NSString *)tableName{
    
    //数据库事务方法 语句组
    NSMutableArray *transactionSql= [[NSMutableArray alloc]init];
    
    for (int j = 0; j < array.count; j ++) {
        id dict = array[j];
        [transactionSql addObject:[self insertSQLForDict:dict tableName:tableName]];
    }
    
    return [self tarray:transactionSql asyncName:"RootDataBaseManagerInsertNewsDataWithArray"];
}
-(BOOL)tarray:(NSArray *)array asyncName:(char *)name{
    
    __block BOOL a = NO;
    
    NSDate *date = [NSDate date];
    
    __weak typeof(self) ws = self;
    dispatch_async(dispatch_queue_create(name, DISPATCH_QUEUE_CONCURRENT), ^{
        __block BOOL b = NO;
        [ws openDB:^(FMDatabase *db) {
            for (int i = 0; i < array.count; ++i) {
                NSString *sql =  array[i];
                b = [db executeUpdate:sql];
                if (!b) {
                    NSLog(@"error to inster data: %@  %@", sql,[NSThread currentThread]);
                }
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            a = b;
        });
    });
    
    CGFloat interval = [[NSDate date] timeIntervalSinceDate:date];
    if (interval > 1) {
        NSLog(@"事务耗时：%f", interval);
    }
    
    return a;
}

#pragma mark 数据是不是存在

-(BOOL)verifyDataForCondition:(NSString *)condition  tableName:(NSString *)tableName{
    
    NSString * sql = [NSString stringWithFormat:@"select count(*) from %@ where %@",tableName,condition];
    __block BOOL b = NO;
    [self openDB:^(FMDatabase *db) {
        b = [db intForQuery:sql] > 0;
    }];
    return b;
}

-(BOOL)verifyDataWithDict:(NSDictionary *)dict relationship:(NSArray *)relationships tableName:(NSString *)tableName{
    
    NSAssert((relationships.count + 1 == dict.count), @"数据与关系不一致！");
    
    NSArray *keys = [dict allKeys];
    
    NSMutableString *vk = [NSMutableString string];
    
    for (int i = 0 ; i < keys.count; i ++) {
        NSString *key = keys[i];
        NSString *value = [NSString stringWithFormat:@"%@",dict[key]];
        [vk appendFormat:@"%@ = '%@'",key,value];
        if (i % 2 == 0 && keys.count > 1 && i > 0) {
            [vk appendFormat:@"%@",relationships[i-1]];
        }
        
    }
    
    NSString * sql = [NSString stringWithFormat:@"select count(*) from %@ where %@",tableName,vk];
    __block BOOL b = NO;
    [self openDB:^(FMDatabase *db) {
        b = [db intForQuery:sql] > 0;
    }];
    return b;
}
/**
 -(NSArray *)carryForOutsql:(NSString *)sql tableName:(NSString *)tableName{
 
 __block NSMutableArray * dataArray = [[NSMutableArray alloc] init];
 [_queue inDatabase:^(FMDatabase *db) {
 [db open];
 [db setKey:DBKEY];
 FMResultSet * result = [db executeQuery:sql];
 //    保存数据库中所有的数据
 while (result.next) {
 if ([result stringForColumn:@"userId"] != nil) {
 [dataArray addObject:[result stringForColumn:@"userId"]];
 }
 }
 }];
 
 return dataArray;
 }*/
/** 执行sql语句返回数据 */
-(NSArray *)carryOutsql:(NSString *)sql tableName:(NSString *)tableName{
    
    __block NSMutableArray * dataArray = [[NSMutableArray alloc] init];
    [self openDB:^(FMDatabase *db) {
        FMResultSet * result = [db executeQuery:sql];
        //    保存数据库中所有的数据
        while (result.next) {
            NSDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[result resultDictionary]];
            [dataArray addObject:dict];
        }
        
    }];
    
    return dataArray;
    
}
/** 通过表名与条件查询数据 */
-(NSArray *)getDataWithTableName:(NSString *)tableName condition:(NSString *)condition conditionBack:(NSString *)conditionBack order:(NSString *)order
{
    NSAssert(condition.length > 0, @" condition 不能为空！");
    if (conditionBack.length == 0) {
        conditionBack = @"*";
    }
    NSString * sql = [NSString stringWithFormat:@"select %@ from %@ where %@ %@",conditionBack,tableName,condition,order];
    __block NSMutableArray * dataArray = [[NSMutableArray alloc] init];
    [self openDB:^(FMDatabase *db) {
        FMResultSet * result = [db executeQuery:sql];
        
        //    保存数据库中所有的数据
        while (result.next) {
            NSDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[result resultDictionary]];
            [dataArray addObject:dict];
        }
        
    }];
    
    return dataArray;
}

/** 通过表名与条件查询数据 */
-(NSArray *)getAllDataTableName:(NSString *)tableName field:(NSString *)field conditions:(NSString *)conditions {
    NSString *fieldString = (field.length > 0)?field:@"*";
    NSString *where = (conditions.length > 0)?[NSString stringWithFormat:@" where %@",conditions]:@"";
    NSString * sql = [NSString stringWithFormat:@"select %@ from %@%@",fieldString,tableName,where];
    __block NSMutableArray * dataArray = [[NSMutableArray alloc] init];
    [self openDB:^(FMDatabase *db) {
        FMResultSet * result = [db executeQuery:sql];
        while (result.next) {
            NSDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[result resultDictionary]];
            [dataArray addObject:dict];
        }
    }];
    return dataArray;
}
/** 通过表名查询所有 */
-(NSArray *)getAllDataTableName:(NSString *)tableName order:(NSString *)order{
    return [self getAllDataTableName:tableName field:nil conditions:order];
}
/** 通过表名与条件查询数据个数 */
-(NSInteger)getCountDataTableName:(NSString *)tableName condition:(NSString *)condition{
    
    NSString * sql = [NSString stringWithFormat:@"select count(*) from %@ where %@",tableName,condition];
    __block NSInteger count = 0;
    [self openDB:^(FMDatabase *db) {
        count = [db intForQuery:sql];
    }];
    return count;
}

-(NSArray *)inquireDataWithDict:(NSDictionary *)dict tableName:(NSString *)tableName{
    
    NSString *key = [[dict allKeys] firstObject];
    NSString * sql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@'",tableName,key,dict[key]];
    __block NSMutableArray * dataArray = [[NSMutableArray alloc] init];
    [self openDB:^(FMDatabase *db) {
        FMResultSet * result = [db executeQuery:sql];
        //    保存数据库中所有的数据
        while (result.next) {
            NSDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[result resultDictionary]];
            [dataArray addObject:dict];
        }
        
    }];
    
    return dataArray;
    
}
-(BOOL)creatTabelKeys:(NSArray *)keys isId:(BOOL)is tableName:(NSString *)tableName{
    
    NSString *Id = @"";
    if (is) {
        Id = @"id integer primary key autoincrement,";
    }
    NSMutableString *sql = [NSMutableString stringWithFormat:@"create table if not exists %@ (%@",tableName,Id];
    NSMutableString *sentence = [NSMutableString string];
    
    NSString *typeStr = @"text";
    for (int i = 0 ; i < keys.count; i ++) {
        NSString *key = keys[i];
        NSString *symbol = (i == keys.count -1)?@")":@",";
        [sentence appendString:[NSString stringWithFormat:@"%@ %@ %@",key,typeStr,symbol]];
    }
    
    [sql appendString:sentence];
    
    BOOL b = NO;
    if ([_dataBase open]){
        [_dataBase setKey:self.dbKey];
        b = [_dataBase  executeUpdate:sql];
        [_dataBase close];
        return b;
    }
    
    if (b) {
        NSLog(@"表格创建或打开成功");
    } else{
        NSLog(@"表格创建失败:%@",[NSThread currentThread]);
    }
    
    return b;
}

/** 判断表中是否有这个字段,没有就添加 */
-(BOOL)isExistDataByArray:(NSArray *)array tableName:(NSString *)tableName{
    
    for (int i = 0; i < array.count; i ++) {
        NSString *name = array[i];
        BOOL a = [self isExistDataByString:name tableName:tableName];
        if (!a) {
            [self addFieldByString:name tableName:tableName];
        }
    }
    
    return NO;
}
-(BOOL)isExistDataByString:(NSString *)name tableName:(NSString *)tableName{
    
    __block BOOL b = NO;
    
    [self openDB:^(FMDatabase *db) {
        b = [db columnExists:name inTableWithName:tableName];
    }];
    
    return b;
}
-(BOOL)addFieldByString:(NSString *)name tableName:(NSString *)tableName{
    
    NSString * sql = [self generateAddFieldSQL:name tableName:tableName];
    
    __block BOOL isOk = NO;
    [self openDB:^(FMDatabase *db) {
        isOk = [db executeUpdate:sql,name];
    }];
    
    return isOk;
}

- (NSString *)generateAddFieldSQL:(NSString *)field tableName:(NSString *)tableName {
    return [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ text",tableName,field];
}
/** 通过条件表名批量删除数据 */
-(BOOL)deleteDataForCondition:(NSString *)condition tableName:(NSString *)tableName{
    
    if (!tableName || tableName.length == 0) {
        return NO;
    }
    
    NSString * sql = [NSString stringWithFormat:@"delete from %@ where %@",tableName,condition];
    __block BOOL isOk = NO;
    
    [self openDB:^(FMDatabase *db) {
        isOk = [db executeUpdate:sql];
    }];
    
    return isOk;
}

/** 通过表名删除所有数据 */
-(BOOL)deleteAllForTableName:(NSString *)tableName{
    
    if (!tableName || tableName.length == 0) {
        return NO;
    }
    
    NSString * sql = [NSString stringWithFormat:@"delete from %@",tableName];
    __block BOOL isOk = NO;
    
    [self openDB:^(FMDatabase *db) {
        isOk = [db executeUpdate:sql];
    }];
    
    return isOk;
}

/** 通过表名删除表 */
-(BOOL)deleteTableForName:(NSString *)tableName{
    if (!tableName || tableName.length == 0) {
        return NO;
    }
    
    NSString * sql = [self generateDeleteTableForName:tableName];
    __block BOOL isOk = NO;
    
    [self openDB:^(FMDatabase *db) {
        isOk = [db executeUpdate:sql];
    }];
    
    return isOk;
}
/** 通过表名生成删除表语句 */
-(NSString *)generateDeleteTableForName:(NSString *)tableName{
    return [NSString stringWithFormat:@"drop table %@",tableName];
}
-(BOOL)isExistTableForName:(NSString *)tableName {
    if (!tableName || tableName.length == 0) {
        return NO;
    }
    
    NSString * sql = [NSString stringWithFormat:@"select count(*) from sqlite_master where type = 'table' and name = '%@'",tableName];
    __block BOOL b = NO;
    
    [self openDB:^(FMDatabase *db) {
        b = [db intForQuery:sql] > 0;;
    }];
    
    return b;
}

-(NSArray *)getDatabaseAllTable {
    
    __block NSMutableArray * dataArray = [[NSMutableArray alloc] init];
    
    [self openDB:^(FMDatabase *db) {
        NSString * sql = @"select * from sqlite_master WHERE type='table'";
        FMResultSet * result = [db executeQuery:sql];
        while (result.next) {
            NSString *tablename = [result stringForColumn:@"name"];
            [dataArray addObject:tablename];
        }
    }];
    
    return dataArray;
}

-(NSArray *)getTableFieldForName:(NSString *)tableName {
    
    __block NSMutableArray * dataArray = [[NSMutableArray alloc] init];
    [self openDB:^(FMDatabase *db) {
        NSString * sql = [NSString stringWithFormat:@"PRAGMA table_info('%@')",tableName];
        FMResultSet * result = [db executeQuery:sql];
        while (result.next) {
            NSString *tablename = [result stringForColumn:@"name"];
            [dataArray addObject:tablename];
        }
    }];
    
    return dataArray;
}

-(void)openDB:(__attribute__((noescape)) void (^)(FMDatabase *db))block {
    if (!block) { return; }
    __weak typeof(self) wsf = self;
    [_queue inDatabase:^(FMDatabase *db) {
        [db open];
        __strong typeof(wsf) strongSelf = wsf;
        [db setKey:strongSelf.dbKey];
        block(db);
    }];
}


@end
