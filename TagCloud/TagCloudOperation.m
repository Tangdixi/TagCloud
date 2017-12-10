//
//  TagCloudOperation.m
//  TagCloud
//
//  Created by tang dixi on 10/12/2017.
//  Copyright © 2017 DC. All rights reserved.
//

#import "TagCloudOperation.h"
#import "QuadtreeNode.h"
#import "TagCloudCell.h"

@interface TagCloudOperation ()

@property (nonatomic, strong) NSMutableArray<TagCloudCell *> *tagCloudCells;
@property (nonatomic, copy) NSArray<NSDictionary<NSString *, NSNumber *> *> *weightedStrings;
@property (nonatomic, strong) QuadtreeNode *quadtree;

@end

@implementation TagCloudOperation

#pragma mark - Override

- (instancetype)initWithCloudRect:(CGRect)cloudRect
				  weightedStrings:(NSArray<NSDictionary<NSString *, NSNumber *> *> *)weightedStrings {
	
	if (self = [super init]) {
		self.cloudRect = cloudRect;
		self.weightedStrings = weightedStrings;
	}
	return self;
}

- (void)main {
	
	if (self.isCancelled) { return; }
	
	[self determineTagSizes];
	
	if (self.isCancelled) { return; }
	
	[self determinetagCloudCellsCenterRandomly];
	
	if (self.isCancelled) { return; }
	
	[self determinePerfectCenterOftagCloudCells];
	
}

#pragma mark - Private

- (void)determineTagSizes {
	
	// Just in case
	//
	[self.tagCloudCells removeAllObjects];
	
	// Generate the raw tagCloudCells
	//
	[self.weightedStrings enumerateObjectsUsingBlock:^(NSDictionary<NSString *,NSNumber *> * _Nonnull weightedString, NSUInteger idx, BOOL * _Nonnull stop) {
		
		if (self.isCancelled) { return; }
		
		NSString *string = weightedString.allKeys.firstObject;
		NSUInteger weight = weightedString.allValues.firstObject.unsignedIntegerValue;
		
		TagCloudCell *tagCloudCell = [[TagCloudCell alloc] initWithString:string weight:weight];
		[self.tagCloudCells addObject:tagCloudCell];
	}];
	
	// Determine the maximun and minimum font size
	//
	[self.tagCloudCells enumerateObjectsUsingBlock:^(TagCloudCell * _Nonnull tagCloudCell, NSUInteger idx, BOOL * _Nonnull stop) {
		
		if (self.isCancelled) { return; }
		
		// Temporary size
		//
		tagCloudCell.size = CGSizeMake(60, 30);
		
		
	}];
	
}

- (void)determinetagCloudCellsCenterRandomly {
	
	[self.tagCloudCells enumerateObjectsUsingBlock:^(TagCloudCell * _Nonnull tagCloudCell, NSUInteger idx, BOOL * _Nonnull stop) {
		
		if (self.isCancelled) { return; }
		
		// Generate a random center
		//
		[tagCloudCell determineRandomTagCloudCellCenterWithTagCloudSize:self.cloudRect.size];
		
	}];
}

- (void)determinePerfectCenterOftagCloudCells {

	[self.tagCloudCells enumerateObjectsUsingBlock:^(TagCloudCell * _Nonnull tagCloudCell, NSUInteger idx, BOOL * _Nonnull stop) {
		
		if (self.isCancelled) { return; }
		
		// Placed, skip to next tag cloud cell
		//
		if ([self placedTagCloudCell:tagCloudCell]) {
			return;
		}
		
		for (int index = 0; index < 100; index++) {
		
			if (self.isCancelled) { return; }
			
			if ([self foundConcentricPlacementWithTagCloudCell:tagCloudCell]) {
				break;
			}
			
			if (self.isCancelled) { return; }
		
			[tagCloudCell determineRandomTagCloudCellCenterWithTagCloudSize:self.cloudRect.size];
			
		}
	}];
}

- (BOOL)placedTagCloudCell:(TagCloudCell *)tagCloudCell {
	
	// Hit a previous bounding rect, return and try again
	//
	if ([self.quadtree hitBoundingRect:tagCloudCell.rect]) {
		return NO;
	}
	
	// Notify the Caller to update the UI
	//
	if (self.delegate && [self.delegate respondsToSelector:@selector(tagCloudOperation:didPlaceTagCloudCell:)]) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.delegate tagCloudOperation:self didPlaceTagCloudCell:tagCloudCell];
		});
	}
	
	// Record the bounding rect
	//
	[self.quadtree insertBoundingRect:tagCloudCell.rect];
	
	return YES;
}

- (BOOL)foundConcentricPlacementWithTagCloudCell:(TagCloudCell *)tagCloudCell {
	
	// main rect
	//
	CGRect containerRect = CGRectMake(0.0, 0.0, self.cloudRect.size.width, self.cloudRect.size.height);
	
	// The current label's center
	//
	CGPoint savedCenter = tagCloudCell.center;
	
	NSUInteger radiusMultiplier = 1; // 1, 2, 3, until radius too large for container
	
	BOOL radiusWithinContainerSize = YES;
	
	// Placement terminated once no points along circle are within container
	
	while (radiusWithinContainerSize)
	{
		// Start with random angle and proceed 360 degrees from that point
		
		NSUInteger initialDegree = arc4random_uniform(360);
		NSUInteger finalDegree = initialDegree + 360;
		
		// Try more points along circle as radius increases
		
		// Degree interval
		//
		NSUInteger degreeStep = radiusMultiplier == 1 ? 15 : radiusMultiplier == 2 ? 10 : 5;
		
		CGFloat radius = radiusMultiplier * tagCloudCell.weight;
		
		radiusWithinContainerSize = NO; // NO until proven otherwise
		
		for (NSUInteger degrees = initialDegree; degrees < finalDegree; degrees += degreeStep )
		{
			if (self.isCancelled) { return NO; }
			
			CGFloat radians = degrees * M_PI / 180.0;
			
			CGFloat x = cos(radians) * radius;
			CGFloat y = sin(radians) * radius;
			
			// Change the word's center with the given offsetX and offsetY
			//
			[tagCloudCell determineTagCloudCellWithCenter:savedCenter xOffset:x yOffset:y];
			
			if (CGRectContainsRect(containerRect, tagCloudCell.rect))
			{
				radiusWithinContainerSize = YES;
				if ([self placedTagCloudCell:tagCloudCell]) {
					return YES;
				}
			}
		}
		
		// No placement found for word on points along current radius.  Try larger radius.
		
		radiusMultiplier++;
	}
	
	// The word did not fit along any concentric circles within the bounds of the container
	
	return NO;
}

#pragma mark - Lazy Loading

- (NSMutableArray<TagCloudCell *> *)tagCloudCells {
	
	if (! _tagCloudCells) {
		_tagCloudCells = [[NSMutableArray alloc] init];
	}
	return _tagCloudCells;
}

- (QuadtreeNode *)quadtree {
	
	if (! _quadtree) {
		_quadtree = [[QuadtreeNode alloc] initWithBoundingRect:self.cloudRect];
	}
	return _quadtree;
}

@end
