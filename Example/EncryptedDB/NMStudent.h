//
//  NMStudent.h
//  EncryptedDB_Example
//
//  Created by Nemo on 2020/9/26.
//  Copyright © 2020 AgoniNemo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NMStudent : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) NSInteger age;

@property (nonatomic, strong) NSString *cls;

@end

NS_ASSUME_NONNULL_END
