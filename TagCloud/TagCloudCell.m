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

static CGFloat kTagCloudCellPadding = 5;

- (instancetype)initWithString:(NSString *)string weight:(NSNumber *)weight {
	
	if (self = [super init]) {
		_string = string;
		_weight = weight;
	}
	return self;
}

#pragma mark - Public

- (void)determineRandomTagCloudCellCenterWithTagCloudSize:(CGSize)tagCloudSize {
	
	CGPoint randomRatioPoint = [self randomRatio];
	
	while (fabs(randomRatioPoint.x) > 5.0 || fabs(randomRatioPoint.y) > 5.0) {
		randomRatioPoint = [self randomRatio];
	}
	
	CGFloat xOffset = (tagCloudSize.width / 2.0) + (randomRatioPoint.x * ((tagCloudSize.width - self.size.width) * 0.1));
	CGFloat yOffset = (tagCloudSize.height / 2.0) + (randomRatioPoint.y * ((tagCloudSize.height - self.size.height) * 0.1));
	
	self.center = CGPointMake(xOffset, yOffset);
}

- (void)determineTagCloudCellWithCenter:(CGPoint)center xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset {
	
	xOffset += center.x;
	yOffset += center.y;
	
	self.center = CGPointMake(xOffset, yOffset);
}

- (void)determineTagCloudCellWithSize:(CGSize)size {
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName : [UIFont systemFontOfSize:self.fontSize]
                                 };
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.string attributes:attributes];
    CGSize attributedStringSize = [attributedString size];
    
    self.size = CGSizeMake(attributedStringSize.width + kTagCloudCellPadding * 2, attributedStringSize.height);
}

#pragma mark - Private

- (CGPoint)randomRatio {
	
	CGFloat x1, x2, w;
	
	do {
        x1 = (arc4random() % 100 + 1) / 100.0;
        x2 = (arc4random() % 100 + 1) / 100.0;
//        x1 = 2.0 * drand48() - 1.0;
//        x2 = 2.0 * drand48() - 1.0;
		w = x1 * x1 + x2 * x2;
	} while (w >= 1.0);
	
	w = sqrt((-2.0 * log(w)) / w);
	
	return CGPointMake(x1 * w, x2 * w);
}

#pragma mark - Accessor

- (CGRect)rect {
	
	return CGRectMake(self.center.x - self.size.width/2,
					  self.center.y - self.size.height/2,
					  self.size.width,
					  self.size.height);
}

- (NSNumber *)area {
    return @(self.rect.size.width * self.rect.size.height);
}

#pragma mark - Lazy Loading

- (CATextLayer *)layer {
	
	if (! _layer) {
		_layer = [CATextLayer layer];
		_layer.string = self.string;
		_layer.foregroundColor = UIColor.blackColor.CGColor;
		_layer.frame = self.rect;
        _layer.contentsScale = [UIScreen mainScreen].scale;
        _layer.fontSize = self.fontSize;
        _layer.borderColor = UIColor.redColor.CGColor;
        _layer.borderWidth = 1;
	}
	return _layer;
}

@end
