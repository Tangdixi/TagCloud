//
//  ViewController.m
//  TagCloud
//
//  Created by 汤迪希 on 30/11/2017.
//  Copyright © 2017 DC. All rights reserved.
//

#import "ViewController.h"

#import "TagCloud.h"

@interface ViewController ()

@property (nonatomic, strong) TagCloud *tagCloud;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
	
    self.view.backgroundColor = UIColor.grayColor;
	[self.view addSubview:self.tagCloud];
    
    [self.tagCloud generateCloud];
}

#pragma mark - Lazy Loading

- (TagCloud *)tagCloud {
	
	if (! _tagCloud) {
        
        CGRect cloudRect = CGRectMake(0, 0, 365, 365);
        
		_tagCloud = [[TagCloud alloc] initWithCloudRect:cloudRect
                                        weightedStrings:self.weightedStrings];
        _tagCloud.backgroundColor = UIColor.whiteColor;
        _tagCloud.center = self.view.center;
        
	}
	return _tagCloud;
}

- (NSArray<NSDictionary<NSString *, NSNumber *> *> *)weightedStrings {
	
    NSMutableArray *datas = @[
                              @{ @"会撩人": @3 },
                              @{ @"唱湿了我": @2 },
                              @{ @"哈哈哈": @2 },
                              @{ @"嘿嘿": @2 },
                              @{ @"怎么那么帅": @2 },
                              @{ @"我的天啊": @2 },
                              @{ @"吴彦祖！": @2 },
                              @{ @"你好啊": @2 }].mutableCopy;
    
    for (int i = 0; i < 22; i++) {
        [datas addObject:@{ @"Kawaii": @1 }];
    }
    
    return datas;
}

@end
