//
//  FileManager.m
//  XingLiIM
//
//  Created by Mjwon on 2016/12/12.
//  Copyright © 2016年 Nemo. All rights reserved.
//

#import "FileManager.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation FileManager

+(BOOL)removeFileWithPath:(NSString *)path{
    return [self removeWithPath:path];
}

+ (void)removeAllFileForFolderPath:(NSString *)path {
    NSFileManager *fileManager = [self defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:path error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        NSString *p = [path stringByAppendingPathComponent:filename];
        [fileManager removeItemAtPath:p error:NULL];
    }
}
+ (void)removeAllImage {
    [self removeAllFileForFolderPath:[self getPathWithType:@"image"]];
}

+(BOOL)removeImageFileName:(NSString *)name{
    
    return [self removeWithPath:[self getImagePathWithName:name]];
}

+(BOOL)removeVoiceFileName:(NSString *)name{
    return [self removeWithPath:[self getVoicePathWithName:name]];
}
+ (void)removeAllVoice {
    [self removeAllFileForFolderPath:[self getPathWithType:@"voice"]];
}
+ (void)removeAllVideo {
    [self removeAllFileForFolderPath:[self getPathWithType:@"video"]];
}
+ (BOOL)saveImageFileData:(NSData *)data name:(NSString *)name{
    return [data writeToFile:[self getImagePathWithName:name] atomically:NO];
}
+ (BOOL)saveVoiceFileData:(NSData *)data name:(NSString *)name{
    return [data writeToFile:[self getVoicePathWithName:name] atomically:NO];
}
+ (BOOL)saveVideoFileData:(NSData *)data name:(NSString *)name{
    return [data writeToFile:[self getVideoPathWithName:name] atomically:NO];
}

+ (BOOL)saveTemVoiceFileData:(NSData *)data name:(NSString *)name{
    return [data writeToFile:[self getTemVoicePathWithName:name] atomically:NO];
}
+ (BOOL)saveTemVideoFileData:(NSData *)data name:(NSString *)name{
    return [data writeToFile:[self getTemVideoPathWithName:name] atomically:NO];
}
+ (BOOL)saveTemImageFileData:(NSData *)data name:(NSString *)name {
    return [data writeToFile:[self getTemImagePathWithName:name] atomically:NO];
}
+(BOOL)removeWithPath:(NSString *)path{

    NSFileManager *fm = [NSFileManager defaultManager];
    // YES 存在   NO 不存在
    BOOL isYES = [fm fileExistsAtPath:path];
    NSLog(@"文件存在状态-->%d",isYES);
    
    NSError *error = nil;
    if (isYES) {
        [fm removeItemAtPath:path error:&error];
    }
    
    return (error == nil);
    
}

+ (NSString *)getImagePathWithName:(NSString *)name {
    return [NSString stringWithFormat:@"%@/%@",[self getPathWithType:@"image"],name];
}
+ (NSString *)getVoicePathWithName:(NSString *)name {
    return [NSString stringWithFormat:@"%@/%@",[self getPathWithType:@"voice"],name];
}
+ (NSString *)getVideoPathWithName:(NSString *)name {
    return [NSString stringWithFormat:@"%@/%@",[self getPathWithType:@"video"],name];
}

+ (NSString *)getTemImagePathWithName:(NSString *)name {
    return [NSString stringWithFormat:@"%@%@",[self getTemDirectory],name];
}
+ (NSString *)getTemVoicePathWithName:(NSString *)name {
    return [NSString stringWithFormat:@"%@%@",[self getTemDirectory],name];
}
+ (NSString *)getTemVideoPathWithName:(NSString *)name {
    return [NSString stringWithFormat:@"%@%@",[self getTemDirectory],name];
}
+(NSString *)getDatabasePath {
    return [[self getDocumentPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",@"DataStore"]];
}
+ (NSString *)getPathWithType:(NSString *)type{

    NSString *paths = [self getDocumentPath];
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/appdata/%@",paths,type];
    return pngFilePath;
}

+ (NSString *)getDocumentPath{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
}

+ (NSString *)getLibraryPath{
   return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)getCachesPath {
   return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}
+(BOOL)boolWithPath:(NSString *)path {
    BOOL b = [self fileExistsAtPath:[path stringByDeletingLastPathComponent]];
    if(!b){
        [[self defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent]
                         withIntermediateDirectories:YES
                                          attributes:nil
                                               error:nil];
    }
    return b;
}

+(BOOL)fileExistsAtPath:(NSString *)path {
    return [[self defaultManager] fileExistsAtPath:path];
}

+ (NSFileManager *)defaultManager {
    return [NSFileManager defaultManager];
}
+ (NSString *)mimeTypeForFileAtPath:(NSString *)path{
    
    if (![self fileExistsAtPath:path]) {
        return nil;
    }
    
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!MIMEType) {
        return @"application/octet-stream";
    }
    NSString *type = (__bridge NSString *)(MIMEType);
    CFRelease(MIMEType);
    return type;
}

+ (NSString *)getTemDirectory {

    return NSTemporaryDirectory();
}

+ (NSInteger)fileSizeForPath:(NSString *)path {
    // 总大小
    NSInteger size = 0;
    NSFileManager *manager = [self defaultManager];
    BOOL isDir = NO;
    BOOL exist = [manager fileExistsAtPath:path isDirectory:&isDir];
    // 判断路径是否存在
    if (!exist) return size;
    if (isDir) { // 是文件夹
        NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:path];
        for (NSString *subPath in enumerator) {
            NSString *fullPath = [path stringByAppendingPathComponent:subPath];
            size += [manager attributesOfItemAtPath:fullPath error:nil].fileSize;
            
        }
    }else{ // 是文件
        size += [manager attributesOfItemAtPath:path error:nil].fileSize;
    }
    return size;
}
@end
