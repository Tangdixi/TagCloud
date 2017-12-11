//
//  QuadtreeNode.m
//  TagCloud
//
//  Created by 汤迪希 on 30/11/2017.
//  Copyright © 2017 DC. All rights reserved.
//

#import "QuadtreeNode.h"

@interface QuadtreeNode ()

@property (nonatomic, assign) CGRect rect;
@property (nonatomic, strong) NSMutableArray<NSValue *> *boundingRects;

@end

@implementation QuadtreeNode

static NSInteger kQuadtreeBoundingRectThreshold = 8;

#pragma mark - Initialization

- (instancetype)initWithBoundingRect:(CGRect)rect {
    if (self = [super init]) {
        _rect = rect;
    }
    return self;
}

#pragma mark - Public

- (BOOL)insertBoundingRect:(CGRect)boundingRect {
    
    // Impossible to put this boundingRect into the current quadtree
    //
    if (! CGRectContainsRect(self.rect, boundingRect) ) {
        return NO;
    }
    
    // No child node exist, or reach the boundingRect's threshold then we create a sub quadtree (split into 4 nodes)
    //
    if (!self.topLeftNode || self.boundingRects.count > kQuadtreeBoundingRectThreshold) {
        
        // Split the current node (create a quadtree)
        //
        [self splitNode];
        
        // Moving the bounding rects that store in the current node to the suitable child node
        //
        [self movingBoundingRectsIntoChildNodesIfNeeded];
    }
    
    // Quadtree existed, insert the bounding rect into the suitable child node
    //
    if (self.topLeftNode && [self migratedBoundingRect:boundingRect]) {
        return YES;
    }
    
    // Reach here means the current node is brand new, store the bounding rect
    //
    [self.boundingRects addObject:[NSValue valueWithCGRect:boundingRect]];
    
    return YES;
}

- (BOOL)hitBoundingRect:(CGRect)boundingRect {
    
    // Perform the collision detection in the current node first
    //
    __block BOOL hit = NO;
    
    [self.boundingRects enumerateObjectsUsingBlock:^(NSValue * _Nonnull boundingRectValue, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGRect cachedBoundingRect = boundingRectValue.CGRectValue;
        
        if (CGRectIntersectsRect(cachedBoundingRect, boundingRect)) {
            hit = YES;
            
            // End enumeration
            //
            *stop = YES;
            return ;
        }
    }];
    
    // Bounding rect contain in the current bounding rects, collision detected
    //
    if (hit) {
        return YES;
    }
    
    // No collision in current node, perform a reculsive detection in the child nodes
    //
    
    // Detect collision in top left child node
    //
    if (CGRectIntersectsRect(self.topLeftNode.rect, boundingRect)) {
        if ([self.topLeftNode hitBoundingRect:boundingRect]) {
            return YES;
        }
        
        // The bounding rect is completely fits within the top left node's rect, no need to check to other child node
        //
        if (CGRectContainsRect(self.topLeftNode.rect, boundingRect)) {
            return YES;
        }
    }
    
    // Detect collision in top right child node
    //
    if (CGRectIntersectsRect(self.topRightNode.rect, boundingRect)) {
        if ([self.topRightNode hitBoundingRect:boundingRect]) {
            return YES;
        }
        
        // The bounding rect is completely fits within the top right node's rect, no need to check to other child node
        //
        if (CGRectContainsRect(self.topRightNode.rect, boundingRect)) {
            return YES;
        }
    }
    
    // Detect collision in bottom left child node
    //
    if (CGRectIntersectsRect(self.bottomLeftNode.rect, boundingRect)) {
        if ([self.bottomLeftNode hitBoundingRect:boundingRect]) {
            return YES;
        }
        
        // The bounding rect is completely fits within the bottom left node's rect, no need to check to other child node
        //
        if (CGRectContainsRect(self.bottomLeftNode.rect, boundingRect)) {
            return YES;
        }
    }
    
    // Detect collision in bottom right child node
    //
    if (CGRectIntersectsRect(self.bottomRightNode.rect, boundingRect)) {
        if ([self.bottomRightNode hitBoundingRect:boundingRect]) {
            return YES;
        }
        
        // The bounding rect is completely fits within the bottom right node's rect, no need to check to other child node
        //
        if (CGRectContainsRect(self.bottomRightNode.rect, boundingRect)) {
            return YES;
        }
    }
    
    // Reach here means no collision detected in all nodes
    //
    return NO;
}

#pragma mark - Private

- (void)splitNode {
    
    // Already split
    //
    if (self.topLeftNode) {
        return;
    }
    
    // Split into 4 child nodes
    //
    self.topLeftNode = [[QuadtreeNode alloc] initWithBoundingRect:CGRectMake(CGRectGetMinX(self.rect),
                                                                             CGRectGetMinY(self.rect),
                                                                             CGRectGetWidth(self.rect)/2,
                                                                             CGRectGetHeight(self.rect)/2)];

    self.topRightNode = [[QuadtreeNode alloc] initWithBoundingRect:CGRectMake(CGRectGetMidX(self.rect),
                                                                             CGRectGetMinY(self.rect),
                                                                             CGRectGetWidth(self.rect)/2,
                                                                             CGRectGetHeight(self.rect)/2)];

    self.bottomLeftNode = [[QuadtreeNode alloc] initWithBoundingRect:CGRectMake(CGRectGetMinX(self.rect),
                                                                             CGRectGetMidY(self.rect),
                                                                             CGRectGetWidth(self.rect)/2,
                                                                             CGRectGetHeight(self.rect)/2)];

    self.bottomRightNode = [[QuadtreeNode alloc] initWithBoundingRect:CGRectMake(CGRectGetMinX(self.rect),
                                                                             CGRectGetMinY(self.rect),
                                                                             CGRectGetWidth(self.rect)/2,
                                                                             CGRectGetHeight(self.rect)/2)];
}

- (void)movingBoundingRectsIntoChildNodesIfNeeded {
    
    NSMutableArray<NSValue *> *migratedBoundingRects = [[NSMutableArray alloc] init];
    
    [self.boundingRects enumerateObjectsUsingBlock:^(NSValue * _Nonnull boundingRectValue, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGRect boundingRect = boundingRectValue.CGRectValue;
        
        // Successfully move the bounding rect into the child node, mark the bounding rect will be delete later
        //
        if ([self migratedBoundingRect:boundingRect]) {
            [migratedBoundingRects addObject:boundingRectValue];
        }
    }];
    
    // Remove the marked bounding rect
    //
    [self.boundingRects removeObjectsInArray:migratedBoundingRects];
    
    if (self.boundingRects.count == 0) {
        self.boundingRects = nil;
    }

}

- (BOOL)migratedBoundingRect:(CGRect)boundingRect {
    
    // Reclusively insert bounding rect into the child nodes
    //
    if ([self.topLeftNode insertBoundingRect:boundingRect] ||
        [self.topRightNode insertBoundingRect:boundingRect] ||
        [self.bottomLeftNode insertBoundingRect:boundingRect] ||
        [self.bottomRightNode insertBoundingRect:boundingRect]
        ) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Lazy Laading

- (NSMutableArray<NSValue *> *)boundingRects {
    if (! _boundingRects) {
        _boundingRects = [[NSMutableArray alloc] init];
    }
    return _boundingRects;
}

@end
