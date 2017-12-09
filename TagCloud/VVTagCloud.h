//
//  VVTagCloud.h
//  TagCloud
//
//  Created by 汤迪希 on 04/12/2017.
//  Copyright © 2017 DC. All rights reserved.
//

@import UIKit;

@class VVTagInfo;
@interface VVTagCloud : NSObject

- (void)generateLabelsWithVVTagInfos:(NSArray<VVTagInfo *> *)infos
                          completion:(void(^)(NSArray<UILabel *> *labels))completion;

@end
