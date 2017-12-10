//
//  TagCloudCell.m
//  TagCloud
//
//  Created by tang dixi on 10/12/2017.
//  Copyright © 2017 DC. All rights reserved.
//

#import "TagCloudCell.h"

@interface TagCloudCell ()

@property (nonatomic, strong) CATextLayer *layer;

@end

@implementation TagCloudCell

- (instancetype)initWithString:(NSString *)string weight:(NSUInteger)weight {
	
	if (self = [super init]) {
		_string = string;
		_weight = weight;
	}
	return self;
}

#pragma mark - Public

- (void)determineRandomTagCloudCellCenterWithTagCloudSize:(CGSize)tagCloudSize {
	
	CGPoint randomGaussianPoint = [self randomGaussian];
	
	while (fabs(randomGaussianPoint.x) > 5.0 || fabs(randomGaussianPoint.y) > 5.0) {
		randomGaussianPoint = [self randomGaussian];
	}
	
	CGFloat xOffset = (tagCloudSize.width / 2.0) + (randomGaussianPoint.x * ((tagCloudSize.width - self.size.width) * 0.1));
	CGFloat yOffset = (tagCloudSize.height / 2.0) + (randomGaussianPoint.y * ((tagCloudSize.height - self.size.height) * 0.1));
	
	self.center = CGPointMake(xOffset, yOffset);
}

- (void)determineRandomWordPlacementInContainerWithSize:(CGSize)containerSize scale:(CGFloat)scale {
	
	CGPoint randomGaussianPoint = [self randomGaussian];
	
	while (fabs(randomGaussianPoint.x) > 5.0 || fabs(randomGaussianPoint.y) > 5.0)
	{
		randomGaussianPoint = [self randomGaussian];
	}
	
	CGFloat xOffset = (containerSize.width / 2.0) + (randomGaussianPoint.x * ((containerSize.width - self.size.width) * 0.1));
	CGFloat yOffset = (containerSize.height / 2.0) + (randomGaussianPoint.y * ((containerSize.height - self.size.height) * 0.1));
	
	self.center = CGPointMake(xOffset, yOffset);
}

- (void)determineTagCloudCellWithCenter:(CGPoint)center xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset {
	
	xOffset += center.x;
	yOffset += center.y;
	
	self.center = CGPointMake(xOffset, yOffset);
}

#pragma mark - Private

- (CGPoint)randomGaussian {
	
	CGFloat x1, x2, w;
	
	do {
		x1 = 2.0 * drand48() - 1.0;
		x2 = 2.0 * drand48() - 1.0;
		w = x1 * x1 + x2 * x2;
	} while (w >= 1.0);
	
	w = sqrt((-2.0 * log(w)) / w);
	
	return CGPointMake(x1 * w, x2 * w);
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@: size<%.2f, %.2f> center<%.2f, %.2f> layer:%@", self, self.size.width, self.size.height, self.center.x, self.center.y, self.layer];
}

#pragma mark - Accessor

- (CGRect)rect {
	
	return CGRectMake(self.center.x - self.size.width/2,
					  self.center.y - self.size.height/2,
					  self.size.width,
					  self.size.height);
}

#pragma mark - Lazy Loading

- (CATextLayer *)layer {
	
	if (! _layer) {
		_layer = [CATextLayer layer];
		_layer.fontSize = self.weight;
		_layer.string = self.string;
		_layer.foregroundColor = UIColor.blackColor.CGColor;
		_layer.frame = self.rect;
	}
	return _layer;
}

@end
