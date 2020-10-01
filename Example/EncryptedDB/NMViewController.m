//
//  NMViewController.m
//  EncryptedDB
//
//  Created by AgoniNemo on 09/25/2020.
//  Copyright (c) 2020 AgoniNemo. All rights reserved.
//

#import "NMViewController.h"
#import <EncryptedDB.h>
#import "NMStudent.h"
#import "NMTea.h"

@interface NMViewController ()

@end

@implementation NMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    [[DatabaseCenter sharedDatabaseCenter] createDBWithArray:@[NMStudent.class,NMTea.class]];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [[DatabaseCenter sharedDatabaseCenter] insertNewsData:@{@"name":@"zhangsan",@"age":@"3",@"cls":@"1112"} class:NMStudent.class];
    NSArray *ary = [[DatabaseCenter sharedDatabaseCenter] getAllDataClass:NMStudent.class];
    NSLog(@"%@",ary);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
