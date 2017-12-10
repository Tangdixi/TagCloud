//
//  VVTagCloud.m
//  TagCloud
//
//  Created by 汤迪希 on 04/12/2017.
//  Copyright © 2017 DC. All rights reserved.
//

#import "TagCloud.h"

#import "TagCloudOperation.h"
#import "TagCloudCell.h"

@interface TagCloud () <
	TagCloudOperationDelegate
>

@property (nonatomic, strong) NSOperationQueue *processQueue;
@property (nonatomic, strong) TagCloudOperation *tagCloudOperation;

@end

@implementation TagCloud

static NSUInteger kTagCloudMaximumSize = 25;
static NSUInteger kTagCloudMimimumSize = 15;

- (instancetype)initWithCloudRect:(CGRect)cloudRect
				  weightedStrings:(NSArray<NSDictionary<NSString *, NSNumber *> *> *)weightedStrings {
	
	if (self = [super initWithFrame:cloudRect]) {
		
		_tagCloudOperation = [[TagCloudOperation alloc] initWithCloudRect:cloudRect
															  weightedStrings:weightedStrings];
		_tagCloudOperation.delegate = self;
	}
	return self;
}

- (void)generateCloud {
	[self.processQueue addOperation:self.tagCloudOperation];
}

#pragma mark - TagCloudOperationDelegate

- (void)tagCloudOperation:(TagCloudOperation *)tagCloudOperation didPlaceTagCloudCell:(TagCloudCell *)tagCloudCell {
	[self.layer addSublayer:tagCloudCell.layer];
}

#pragma mark - Lazy Loading

- (NSOperationQueue *)processQueue {
	
	if (! _processQueue) {
		_processQueue = [[NSOperationQueue alloc] init];
		_processQueue.name = @"com.tagCloud.processQueue";
		_processQueue.maxConcurrentOperationCount = 1;
	}
	return _processQueue;
}

@end
