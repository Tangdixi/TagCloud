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
    [self prepareRawTagCloudCells];
    
	if (self.isCancelled) { return; }
    [self configureTagCloudCellsWeight];
	
	if (self.isCancelled) { return; }
	[self randomlyPlaceTagCloudCell];
	
	if (self.isCancelled) { return; }
	[self perfectlyPlaceTagCloudCell];
	
}

#pragma mark - Private

- (void)prepareRawTagCloudCells {
	
	// Just in case
	//
	[self.tagCloudCells removeAllObjects];
	
	// Generate the raw tagCloudCells
	//
	[self.weightedStrings enumerateObjectsUsingBlock:^(NSDictionary<NSString *,NSNumber *> * _Nonnull weightedString, NSUInteger idx, BOOL * _Nonnull stop) {
		
		if (self.isCancelled) { return; }
		
		NSString *string = weightedString.allKeys.firstObject;
		NSNumber *weight = weightedString.allValues.firstObject;
		
		TagCloudCell *tagCloudCell = [[TagCloudCell alloc] initWithString:string weight:weight];
		[self.tagCloudCells addObject:tagCloudCell];
	}];
}



- (void)configureTagCloudCellsWeight {
    
    // Determine minimum and maximum weight of words
    
    CGFloat minimumWeight = [[self.tagCloudCells valueForKeyPath:@"@min.weight"] doubleValue];
    CGFloat maximumWeight = [[self.tagCloudCells valueForKeyPath:@"@max.weight"] doubleValue];
    
    CGFloat deltaWordCount = maximumWeight - minimumWeight;
    CGFloat ratioCap = 20.0;
    CGFloat maxMinRatio = MIN((maximumWeight / minimumWeight), ratioCap);
    
    // Start with these values, which will be decreased as needed that all the words may fit the container
    
    __block CGFloat fontMin = 12.0;
    __block CGFloat fontMax = fontMin * maxMinRatio;
    __block BOOL tagCellAreaExceedsContainerSize = NO;
    
    NSInteger dynamicTypeDelta = 6;
    
    CGFloat containerArea = self.cloudRect.size.width * self.cloudRect.size.height * 0.9;
    
    do {
       
        __block CGFloat tagCellArea = 0.0;
        tagCellAreaExceedsContainerSize = NO;
        
        CGFloat fontRange = fontMax - fontMin;
        CGFloat fontStep = 3.0;
        
        // Normalize word weights
        
        [self.tagCloudCells enumerateObjectsUsingBlock:^(TagCloudCell * _Nonnull tagCloudCell, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (self.isCancelled) { return; }
            
            CGFloat scale = (tagCloudCell.weight.integerValue - minimumWeight) / deltaWordCount;
            tagCloudCell.fontSize = fontMin + (fontStep * floor(scale * (fontRange / fontStep))) + dynamicTypeDelta;
            
            [tagCloudCell determineTagCloudCellWithSize:self.cloudRect.size];
            
            // Check to see if the current word fits in the container
            
            tagCellArea += tagCloudCell.area.doubleValue;
            
            if (tagCellArea >= containerArea || tagCloudCell.size.width >= self.cloudRect.size.width || tagCloudCell.size.height >= self.cloudRect.size.height) {
                
                tagCellAreaExceedsContainerSize = YES;
                fontMin--;
                fontMax = fontMin * maxMinRatio;
                return;
            }
        }];
        
    } while (tagCellAreaExceedsContainerSize);
    
    return;
}

- (void)randomlyPlaceTagCloudCell {
	
	[self.tagCloudCells enumerateObjectsUsingBlock:^(TagCloudCell * _Nonnull tagCloudCell, NSUInteger idx, BOOL * _Nonnull stop) {
		
		if (self.isCancelled) { return; }
		
		// Generate a random center
		//
		[tagCloudCell determineRandomTagCloudCellCenterWithTagCloudSize:self.cloudRect.size];
	}];
}

- (void)perfectlyPlaceTagCloudCell {

    // Sort the tag cloud cells for the following collision detection
    //
    NSSortDescriptor *primarySortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"area" ascending:NO];
    NSSortDescriptor *secondarySortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fontSize" ascending:NO];
    self.tagCloudCells = [self.tagCloudCells sortedArrayUsingDescriptors:@[primarySortDescriptor, secondarySortDescriptor]].mutableCopy;
    
    // Collision detectionfi
    //
	[self.tagCloudCells enumerateObjectsUsingBlock:^(TagCloudCell * _Nonnull tagCloudCell, NSUInteger idx, BOOL * _Nonnull stop) {
		
		if (self.isCancelled) { return; }
		
		// Placed, skip to next tag cloud cell
		//
		if ([self hasPlacedTagCloudCell:tagCloudCell]) {
			return;
		}
		
		for (int index = 0; index < 50; index++) {
		
			if (self.isCancelled) { return; }
			
			if ([self foundConcentricPlacementWithTagCloudCell:tagCloudCell]) {
                return;
			}
			
			if (self.isCancelled) { return; }
		
			[tagCloudCell determineRandomTagCloudCellCenterWithTagCloudSize:self.cloudRect.size];
		}
	}];
    
}

- (BOOL)hasPlacedTagCloudCell:(TagCloudCell *)tagCloudCell {
	
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
		
		CGFloat radius = radiusMultiplier * tagCloudCell.fontSize;
		
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
			
			if (CGRectContainsRect(containerRect, tagCloudCell.rect)) {
                
				radiusWithinContainerSize = YES;
				if ([self hasPlacedTagCloudCell:tagCloudCell]) {
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
