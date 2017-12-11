//
//  TagCloudCell.h
//  TagCloud
//
//  Created by tang dixi on 10/12/2017.
//  Copyright © 2017 DC. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface TagCloudCell : NSObject

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint center;
@property (nonatomic, assign) CGRect rect;
@property (nonatomic, strong, readonly) CATextLayer *layer;
@property (nonatomic, copy) NSDictionary *info;
@property (nonatomic, copy) NSString *string;
@property (nonatomic, strong) NSNumber *weight;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, strong) NSNumber *area;

- (instancetype)initWithString:(NSString *)string weight:(NSNumber *)weight;

- (void)determineRandomTagCloudCellCenterWithTagCloudSize:(CGSize)tagCloudSize;

- (void)determineTagCloudCellWithCenter:(CGPoint)center xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset;

- (void)determineTagCloudCellWithSize:(CGSize)size;

@end
