//
//  main.swift
//  Mapper
//
//  Created by LZephyr on 2017/9/23.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

let text = """
//
//  MyComicsBaseViewController.m
//  NECatoonReader
//
//  Created by LZephyr on 16/6/17.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "MyComicsBaseViewController.h"

@interface _MyComicsBaseViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@interface MyComicsBaseViewController: NSObject <UITableViewDelegate, UITableViewDataSource>

@interface MyComicsBaseViewController (category): NSObject <MyDelegate>

@end

@implementation MyComicsBaseViewController

- (void)viewDidLoad {
[super viewDidLoad];
// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
[super didReceiveMemoryWarning];
// Dispose of any resources that can be recreated.
}

- (void)setNavigationType:(MyComicsNavigationType)aType {
[[MyComicsViewController currentInstance] setNavigationType:aType];
}

- (void)setIsEditMode:(BOOL)isEditMode {
NSAssert(NO, @"请在子类中实现setIsEditMode:方法");
}

- (void)selectedAll {
NSAssert(NO, @"请在子类中实现selectedAll方法");
}

- (void)unselectedAll {
NSAssert(NO, @"请在子类中实现unselectedAll方法");
}

- (BOOL)shouldShowRightNavItem {
NSAssert(NO, @"请在子类中实现shouldShowRightNavItem方法");
return NO;
}

- (NSString *)editModeTitle {
NSAssert(NO, @"请在子类中实现editModeTitle方法");
return nil;
}

- (NSUInteger)numberOfBooksInPage {
NSAssert(NO, @"请在子类中实现numberOfBooksInPage方法");
return 0;
}

- (NSUInteger)numberOfSelectedBooks {
NSAssert(NO, @"请在子类中实现numberOfSelectedBooks方法");
return 0;
}

- (void)refreshViewController {
NSAssert(NO, @"请在子类中实现reloadData方法");
}

@end

"""
let lexer = Lexer(input: text)
let clsParser = ClassParser(lexer: lexer)

print(clsParser.parse())

