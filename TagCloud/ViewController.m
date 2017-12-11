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
        
        CGRect cloudRect = CGRectMake(0, 0, 300, 300);
        
		_tagCloud = [[TagCloud alloc] initWithCloudRect:self.view.bounds
                                        weightedStrings:self.weightedStrings];
        _tagCloud.backgroundColor = UIColor.whiteColor;
        _tagCloud.center = self.view.center;
        
	}
	return _tagCloud;
}

- (NSArray<NSDictionary<NSString *, NSNumber *> *> *)weightedStrings {
	
    NSMutableArray *datas = @[
                              @{ @"Hello": @10 },
                              @{ @"Hi": @8 },
                              @{ @"Goodbye": @7 },
                              @{ @"Well": @3 },
                              @{ @"GG": @3 },
                              @{ @"See You": @3 },
                              @{ @"Genius": @3 },
                              @{ @"Over": @2 }].mutableCopy;
    
    for (int i = 0; i < 1; i++) {
        [datas addObject:@{ @"XXXXX !": @1 }];
    }
    
    return datas;
}

@end
