//
//  TagCloudOperation.h
//  TagCloud
//
//  Created by tang dixi on 10/12/2017.
//  Copyright © 2017 DC. All rights reserved.
//

@import Foundation;
@import UIKit;

@class TagCloudOperation, TagCloudCell;

@protocol TagCloudOperationDelegate <NSObject>

- (void)tagCloudOperation:(TagCloudOperation *)tagCloudOperation
	 didPlaceTagCloudCell:(TagCloudCell *)tagCloudCell;

@end

@interface TagCloudOperation : NSOperation

/**
 @brief The tag cloud field's rect
 @discussion Default is screen.bounds
 */
@property (nonatomic, assign) CGRect cloudRect;

@property (nonatomic, weak) id<TagCloudOperationDelegate> delegate;

/**
 @brief return a operation with the given weighted string
 @discussion dictionary example { @"Hello": @10 }, means @"Hello" appear 10 times;
 */
- (instancetype)initWithCloudRect:(CGRect)cloudRect
				  weightedStrings:(NSArray<NSDictionary<NSString *, NSNumber *> *> *)weightedStrings;

@end
