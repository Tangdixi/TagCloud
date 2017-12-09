//
//  QuadtreeNode.h
//  TagCloud
//
//  Created by 汤迪希 on 30/11/2017.
//  Copyright © 2017 DC. All rights reserved.
//

@import UIKit;

@interface QuadtreeNode : NSObject

@property (nonatomic, strong) QuadtreeNode *topLeftNode;
@property (nonatomic, strong) QuadtreeNode *topRightNode;
@property (nonatomic, strong) QuadtreeNode *bottomLeftNode;
@property (nonatomic, strong) QuadtreeNode *bottomRightNode;

/**
 @brief Return a node by the given frame
 */  
- (instancetype)initWithBoundingRect:(CGRect)rect;

/**
 @brief Insert a boundingRect into the quadtree
 @discussion If the rect has been occupied by another node
 */
- (BOOL)insertBoundingRect:(CGRect)boundingRect;

/**
 @brief Perform a collision detection in the current quadtree
 */
- (BOOL)hitBoundingRect:(CGRect)boundingRect;

@end
