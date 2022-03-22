//
//  QMZhugeDB.m
//  Pods
//
//  Created by ZCZ on 2022/3/18.
//

#import "QMZhugeDB.h"
#import <FMDB/FMDB.h>

NSString *tab_name = @"k_zhuge_tab";

NSString *tab_key_data = @"data";
NSString *tab_key_accessId = @"accessId";
NSString *tab_key_userId = @"userId";
NSString *tab_key_userName = @"userName";
NSString *tab_key_time = @"time";
NSString *tab_key_version = @"version";
NSString *tab_key_sid = @"sid";




@interface QMZhugeDB ()
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

@implementation QMZhugeDB
+ (instancetype)shared {
    static id _qmZhugeDB = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _qmZhugeDB = [QMZhugeDB new];
        [_qmZhugeDB createZhugeDb];
    });
    
    return _qmZhugeDB;
}

- (void)createZhugeDb {
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        if (db.open) {
            NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement, %@ text, %@ text, %@ text, %@ text, %@ text uinque, %@ text, %@ text)", tab_name, tab_key_data, tab_key_userId, tab_key_accessId, tab_key_userName, tab_key_time, tab_key_version, tab_key_sid];
            BOOL rel = [db executeStatements:sql];
            if (rel) {
                NSLog(@"创建成功");
            } else {
                NSLog(@"创建失败");
            }
        }
    }];
}

+ (void)insertData:(NSString *)data accessId:(NSString *)accessId userId:(NSString *)userId userName:(NSString *)userName version:(nonnull NSString *)version sid:(NSString *)sid {
    [QMZhugeDB.shared insertData:data accessId:accessId userId:userId userName:userName version:version sid:sid];
}

- (void)insertData:(NSString *)data accessId:(NSString *)accessId userId:(NSString *)userId userName:(NSString *)userName version:(nonnull NSString *)version sid:(NSString *)sid {
    
    if (data.length == 0) {
        return;
    }
    userId = userId ? : @"";
    accessId = accessId ? : @"";
    
    NSTimeInterval date = [NSDate new].timeIntervalSince1970 * 1000;
    
    NSString *dateString = [NSString stringWithFormat:@"%.0lf",date];
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSString *sql = [NSString stringWithFormat:@"insert into %@ (%@,%@,%@,%@,%@,%@,%@) values (?,?,?,?,?,?,?)", tab_name, tab_key_data, tab_key_userId, tab_key_userName, tab_key_accessId, tab_key_time, tab_key_version, tab_key_sid];
        BOOL rel = [db executeUpdate:sql withArgumentsInArray:@[data, userId, userName, accessId, dateString, version, sid]];
        if (rel) {
            NSLog(@"插入成功");
        } else {
            NSLog(@"插入失败");
        }
    }];
}

+ (BOOL)deleteDataWithTime:(NSString *)time {
    return [QMZhugeDB.shared deleteDataWithTime:time];
}

- (BOOL)deleteDataWithTime:(NSString *)time {
    __block BOOL rel = NO;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@ = ?", tab_name, tab_key_time];
        rel = [db executeUpdate:sql withArgumentsInArray:@[time]];
        if (rel) {
            NSLog(@"删除成功");
        } else {
            NSLog(@"删除失败");
        }
    }];
    return rel;
}

+ (NSArray *)getTrackData {
    return QMZhugeDB.shared.getTrackData;
}

- (NSArray *)getTrackData {
    NSMutableArray *arr = [NSMutableArray array];
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        if (db.isOpen) {
            NSString *sql = [NSString stringWithFormat:@"select *from %@", tab_name];
            FMResultSet *set = [db executeQuery:sql];
            while (set.next) {
                if (set.resultDictionary) {
                    [arr addObject:set.resultDictionary];
                }
            }
        }
    }];
    
    return arr.copy;
}

- (FMDatabaseQueue *)dbQueue {
    if (!_dbQueue) {
        NSString *dbFile = [[self dbFilepath] stringByAppendingPathComponent:@"QM_ZhugeTrack.sqlite"];
        _dbQueue = [[FMDatabaseQueue alloc] initWithPath:dbFile];
    }
    return _dbQueue;
}

- (NSString *)dbFilepath {
    NSString *docFile = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *dbFile = [docFile stringByAppendingPathComponent:@"Zhuge"];
    NSFileManager *mgr = [NSFileManager defaultManager];
    if ([mgr fileExistsAtPath:dbFile] == false) {
        [mgr createDirectoryAtPath:dbFile withIntermediateDirectories:YES attributes:@{} error:nil];
    }
    NSLog(@"filePath = %@",dbFile);
    return dbFile;
}

+ (BOOL)deleteAllData {
    return [QMZhugeDB.shared deleteAllData];
}

- (BOOL)deleteAllData {
    __block BOOL rel = NO;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@", tab_name];
        rel = [db executeUpdate:sql];
        if (rel) {
            NSLog(@"删除成功");
        } else {
            NSLog(@"删除失败");
        }
    }];
    return rel;
}

@end
