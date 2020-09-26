//
//  DatabaseCenter.m
//  xiangwan
//
//  Created by mac on 2019/8/22.
//  Copyright © 2019 mac. All rights reserved.
//

#import "DatabaseCenter.h"
#import "Database.h"
#import "FileManager.h"
#import <objc/runtime.h>

const static NSInteger DB_MANAGER_VER = 1;

static NSString *const DBINFORTAB = @"t_db_info";

CG_INLINE NSArray *DBINFO() {
    return @[@"dbVersion",@"appBundleVersion",@"time"];
}

@interface DatabaseCenter ()
/// 数据库表
@property (nonatomic, copy) NSDictionary<NSString *,NSArray *> *tDic;
@property (nonatomic ,strong) FMDatabaseQueue *queue;
@property (nonatomic ,strong) FMDatabase *dataBase;
@property (nonatomic, strong) Database *dbMager;
@end

@implementation DatabaseCenter


//GCD - 开启异步线程
CG_INLINE void kDISPATCH_GLOBAL_QUEUE_DEFAULT(dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

static DatabaseCenter *sharedDatabaseCenter = nil;
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sharedDatabaseCenter == nil) {
            sharedDatabaseCenter = [super allocWithZone:zone];
        }
    });
    return sharedDatabaseCenter;
}
+(instancetype)sharedDatabaseCenter
{
    return [[self alloc] init];
}
-(id)copyWithZone:(NSZone *)zone
{
    return sharedDatabaseCenter;
}
-(id)mutableCopyWithZone:(NSZone *)zone
{
    return sharedDatabaseCenter;
}

-(NSString *)generateTableNameForClass:(Class)cls {
    return [NSString stringWithFormat:@"t_%@",NSStringFromClass(cls)];
}

/** 更新数据 */
-(BOOL)updateDataWithDict:(NSDictionary *)dict
               conditions:(NSString *)conditions
                    class:(Class)className{
    return [self.dbMager updateDataWithDict:dict condition:conditions tableName:[self generateTableNameForClass:className]];
}

/** 更新多条数据 */
-(BOOL)updateDataWithArray:(NSArray<NSDictionary *>*)array
                 condition:(NSArray<NSString *>*)conditions
                     class:(Class)className{
    NSMutableArray *sqls = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < conditions.count; i ++) {
        [sqls addObject:conditions[i]];
    }
    return [self.dbMager updateDataWithArray:array condition:sqls tableName:[self generateTableNameForClass:className]];
}
/** 插入数据 */
-(BOOL)insertNewsData:(NSDictionary *)dict
                class:(Class)className{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithDictionary:dict];
    return [self.dbMager insertNewsData:data tableName:[self generateTableNameForClass:className]];
}
/** 插入多条数据 */
-(BOOL)insertMoreData:(NSArray <NSDictionary *>*)ary
                class:(Class)className{
    return [self.dbMager insertNewsDataWithArray:ary tableName:[self generateTableNameForClass:className]];
}
/** 数据是不是存在(condition为条件语句) */
-(BOOL)verifyDataForCondition:(NSString *)condition
                        class:(Class)className{
    return [self.dbMager verifyDataForCondition:condition tableName:[self generateTableNameForClass:className]];
}

/** 通过表名查询所有 */
-(NSArray *)getAllDataClass:(Class)className{
    return [self.dbMager getAllDataTableName:[self generateTableNameForClass:className] order:@""];
}
/** 删除所有数据 */
-(BOOL)deleteAllConditions:(NSString *)conditions
                     class:(Class)className{
    if (!conditions) {
        return [self.dbMager deleteAllForTableName:[self generateTableNameForClass:className]];
    }
    return [self.dbMager deleteDataForCondition:conditions tableName:[self generateTableNameForClass:className]];
}
/** 通过表名与条件查询数据 */
-(NSArray *)getAllDataWithConditions:(NSString *)conditions
                               class:(Class)className{
    return [self.dbMager getAllDataTableName:[self generateTableNameForClass:className] order:conditions];
}

- (void)createDBWithArray:(NSArray <Class>*)ary {
    if (ary.count == 0) {  return; }
    unsigned int count;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (int i = 0 ; i < ary.count; i ++) {
        Class cls = ary[i];
        Ivar *ivarList = class_copyIvarList(cls, &count);
        NSMutableArray *ivarAry = [[NSMutableArray alloc] init];
        for (unsigned int i = 0; i < count; i++) {
            Ivar myIvar = ivarList[i];
            const char *ivarName = ivar_getName(myIvar);
            NSString *ivarStr = [NSString stringWithUTF8String:ivarName];
            [ivarAry addObject:[ivarStr stringByReplacingOccurrencesOfString:@"_" withString:@""]];
        }
        [dict setValue:ivarAry forKey:NSStringFromClass(cls)];
        count = 0;
        free(ivarList);
    }
    _tDic = [dict copy];
    
    [self createDB];
}
- (void)createDB {
    
    if ([FileManager fileExistsAtPath:[FileManager getDatabasePath]]) {
        [self checkDB];
        return;
    }
    __weak typeof(self) weakSelf = self;
    kDISPATCH_GLOBAL_QUEUE_DEFAULT(^{
        [weakSelf initDB];
    });
}
- (void)initDB {
    
    BOOL a = [self.dbMager creatTabelWithKeys:DBINFO() isId:YES tableName:DBINFORTAB];
    NSLog(@"===========数据库表创建：%d",a);

    NSArray *tableAry  = [_tDic allKeys];
    for (int i = 0; i < tableAry.count; i ++) {
        NSString *tName = tableAry[i];
        NSArray *value = [_tDic objectForKey:tName];
        BOOL r = [self.dbMager creatTabelWithKeys:value isId:YES tableName:[self generateTableNameForClass:objc_getClass([tName UTF8String])]];
        NSLog(@"===========数据库表创建：%d",r);
    }
    
    [self insertNewsVersion];
    
}
- (void)checkDB {
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSDictionary *dict = [self.dbMager getAllDataTableName:DBINFORTAB order:[NSString stringWithFormat:@"appBundleVersion = '%@'",appVersion]].firstObject;
    if (dict.count > 0) {
        NSLog(@"========数据库版本存在 %@",[FileManager getDatabasePath]);
        NSLog(@"%@",dict);
        return;
    }
    NSLog(@"========数据库版本需要更新");
    
    __weak typeof(self) weakSelf = self;
    kDISPATCH_GLOBAL_QUEUE_DEFAULT(^{
        [weakSelf updateDB];
    });
}
- (void)updateDB {
    
    NSArray *tabList = [self.dbMager  getAllDataTableName:DBINFORTAB order:@""];
    NSMutableArray *addFields = [[NSMutableArray alloc] init];
    NSMutableArray *deleteTbs = [[NSMutableArray alloc] init];
    BOOL b = NO;
    for (NSString *name in tabList) {
        NSArray *ary = _tDic[name];
        if (ary.count > 0) {
            NSArray *fields = [self.dbMager getTableFieldForName:name ];
            for (NSString *field in ary) {
                if (![fields containsObject:field] &&
                    ![field isEqualToString:@"id"]) {
                    [addFields addObject:[self.dbMager generateAddFieldSQL:field tableName:name]];
                }
            }
        }else{
            if (![name isEqualToString:@"sqlite_sequence"]) {
                [deleteTbs addObject:[self.dbMager generateDeleteTableForName:name]];
            }
            NSLog(@"%@ 表不存在",name);
        }
    }
    
    for (NSString *name in [_tDic allKeys]) {
        if (![tabList containsObject:name]) {
            b = YES;
            break;
        }
    }
    
    if (addFields.count > 0) {
        [self.dbMager tarray:addFields asyncName:"AddFieldSQL"];
    }
    
    if (deleteTbs.count > 0) {
        [self.dbMager tarray:deleteTbs asyncName:"DeleteTableSQL"];
    }
    
    if (b) {
        [self initDB];
    }else{
        [self insertNewsVersion];
    }
}
- (void)insertNewsVersion {
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *timeString = [NSString stringWithFormat:@"%.f",[[NSDate date] timeIntervalSince1970]*1000];
    [self.dbMager insertNewsData:@{@"dbVersion":[NSString stringWithFormat:@"%ld",(long)DB_MANAGER_VER],@"appBundleVersion":[NSString stringWithFormat:@"%@",appVersion],@"time":timeString} tableName:DBINFORTAB];
}


-(Database *)dbMager {
    if (_dbMager == nil) {
        _dbMager = [Database dataManagerForQueue:self.queue];
        _dbMager.dataBase = self.dataBase;
    }
    return _dbMager;
}
-(FMDatabaseQueue *)queue {
    if (_queue == nil) {
        _queue = [FMDatabaseQueue databaseQueueWithPath:[FileManager getDatabasePath]];
    }
    return _queue;
}
-(FMDatabase *)dataBase {
    if (_dataBase == nil) {
        _dataBase = [[FMDatabase alloc] initWithPath:[FileManager getDatabasePath]];
    }
    return _dataBase;
}

- (NSString *)dbFilePath {
    return [FileManager getDatabasePath];
}
- (void)close {
    FMDBRetain(self);
    dispatch_sync(dispatch_queue_create("DatabaseClose", NULL), ^() {
        [self.dataBase close];
        FMDBRelease(_db);
        self.dataBase = 0x00;
    });
    FMDBRelease(self);
}

@end
