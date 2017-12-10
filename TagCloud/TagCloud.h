//
//  VVTagCloud.h
//  TagCloud
//
//  Created by 汤迪希 on 04/12/2017.
//  Copyright © 2017 DC. All rights reserved.
//

@import UIKit;

@interface TagCloud : UIView

- (instancetype)initWithCloudRect:(CGRect)cloudRect
				  weightedStrings:(NSArray<NSDictionary<NSString *, NSNumber *> *> *)weightedStrings;

- (void)generateCloud;

@end
