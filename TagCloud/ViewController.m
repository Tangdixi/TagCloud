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
	
	[self.view addSubview:self.tagCloud];
	
	[self.tagCloud generateCloud];
}

#pragma mark - Lazy Loading

- (TagCloud *)tagCloud {
	
	if (! _tagCloud) {
		
		CGRect cloudRect = CGRectMake(10, 100, CGRectGetWidth([UIScreen mainScreen].bounds) - 20, 400);
		
		_tagCloud = [[TagCloud alloc] initWithCloudRect:cloudRect weightedStrings:self.weightedStrings];
	}
	return _tagCloud;
}

- (NSArray<NSDictionary<NSString *, NSNumber *> *> *)weightedStrings {
	
	return @[
			 @{ @"Hello": @20 },
			 @{ @"Hello": @20 },
			 @{ @"Hello": @20 },
			 @{ @"Hello": @20 },
			 @{ @"Hello": @20 },
			 @{ @"Hello": @20 },
			];
}

@end
