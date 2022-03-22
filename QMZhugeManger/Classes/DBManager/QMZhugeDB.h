//
//  QMZhugeDB.h
//  Pods
//
//  Created by ZCZ on 2022/3/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMZhugeDB : NSObject

+ (instancetype)shared;

+ (void)insertData:(NSString *)data accessId:(NSString *)accessId userId:(NSString *)userId userName:(NSString *)userName version:(NSString *)version sid:(NSString *)sid;
- (void)insertData:(NSString *)data accessId:(NSString *)accessId userId:(NSString *)userId userName:(NSString *)userName version:(NSString *)version sid:(NSString *)sid;

- (BOOL)deleteDataWithTime:(NSString *)time;
+ (BOOL)deleteDataWithTime:(NSString *)time;
+ (BOOL)deleteAllData;
- (BOOL)deleteAllData;
- (NSArray *)getTrackData;
+ (NSArray *)getTrackData;


@end

NS_ASSUME_NONNULL_END
