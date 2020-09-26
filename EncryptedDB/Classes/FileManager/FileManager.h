//
//  FileManager.h
//  XingLiIM
//
//  Created by Mjwon on 2016/12/12.
//  Copyright © 2016年 Nemo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileManager : NSObject

+ (BOOL)removeFileWithPath:(NSString *)path;

+ (BOOL)removeImageFileName:(NSString *)name;
+ (void)removeAllImage;
+ (BOOL)removeVoiceFileName:(NSString *)name;
+ (void)removeAllVoice;
+ (void)removeAllVideo;

+ (BOOL)saveImageFileData:(NSData *)data name:(NSString *)name;
+ (BOOL)saveVoiceFileData:(NSData *)data name:(NSString *)name;
+ (BOOL)saveVideoFileData:(NSData *)data name:(NSString *)name;

/// 临时文件
+ (BOOL)saveTemVoiceFileData:(NSData *)data name:(NSString *)name;
+ (BOOL)saveTemVideoFileData:(NSData *)data name:(NSString *)name;
+ (BOOL)saveTemImageFileData:(NSData *)data name:(NSString *)name;

+ (NSString *)getPathWithType:(NSString *)type;

+ (NSString *)getDatabasePath;
+ (NSString *)getDocumentPath;
+ (NSString *)getImagePathWithName:(NSString *)name;
+ (NSString *)getVoicePathWithName:(NSString *)name;
+ (NSString *)getVideoPathWithName:(NSString *)name;

/// 临时文件
+ (NSString *)getTemImagePathWithName:(NSString *)name;
+ (NSString *)getTemVoicePathWithName:(NSString *)name;
+ (NSString *)getTemVideoPathWithName:(NSString *)name;

/// 传入文件绝对路径(如果没有就创建) 返回bool
+(BOOL)boolWithPath:(NSString *)path;
/// 文件是否存在 返回bool
+(BOOL)fileExistsAtPath:(NSString *)path;

/// 返回文件类型
+ (NSString *)mimeTypeForFileAtPath:(NSString *)path;
/// 传入文件绝对路径返回文件大小
+ (NSInteger)fileSizeForPath:(NSString *)path;

+ (NSString *)getTemDirectory;
+ (NSString *)getLibraryPath;
+ (NSString *)getCachesPath;

@end
