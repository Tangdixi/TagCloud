//
//  ViewController.m
//  TagCloud
//
//  Created by 汤迪希 on 30/11/2017.
//  Copyright © 2017 DC. All rights reserved.
//

#import "ViewController.h"

#import "VVTagCloud.h"
#import "VVTagInfo.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    VVTagCloud *tagCloud = [[VVTagCloud alloc] init];
    [tagCloud generateLabelsWithVVTagInfos:self.infos completion:^(NSArray<UILabel *> *labels) {
        
    }];
    
}

- (NSArray<VVTagInfo *> *)infos {
    
    NSMutableArray *infos = @[].mutableCopy;
    
    for (int i = 0; i < 20; i++) {
        VVTagInfo *info = [[VVTagInfo alloc] init];
        info.name = i%2? @"我是一个长标签":@"标签";
        info.count = arc4random_uniform(10) + 1;
        
        [infos addObject:info];
    }
    
    return infos.copy;
}

@end
