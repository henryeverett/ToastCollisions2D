//
//  TC_SpatialCollisionManager.m
//  Pixel Toast
//
//  Created by Henry Everett on 04/06/2014.
//  Copyright (c) 2014 Henry Everett. All rights reserved.
//

#import "TC_SpatialCollisionManager.h"
#import "SKSpriteNode+TC_CollisionSubject.h"

const NSInteger max_objects = 10;
const NSInteger max_depth = 5;

@interface TC_SpatialCollisionManager ()

/* Split a bucket into four sub-buckets. Private method. */
- (void)split;
/* Get the bucket address for a particular node. Private method.  */
- (NSInteger)getBucketAddressForNode:(SKSpriteNode *)node;

@end

@implementation TC_SpatialCollisionManager

- (id)initWithLevel:(NSInteger)depth rect:(CGRect)rect {
    
    self = [super init];
    if (self) {
        self.depth = depth;
        self.rect = rect;
        self.objects = [[NSMutableArray alloc] init];
        self.buckets = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)resetBuckets {
    
    // Remove all objects from current bucket.
    [self.objects removeAllObjects];
    
    // Recursively reset all sub-buckets.
    for (NSInteger i = 0; i < self.buckets.count; i++) {
        
        if (self.buckets[i]) {
            [self.buckets[i] resetBuckets];
            [self.buckets[i] removeAllObjects];
        }
    }
}

- (void)split {
    
    // Get dimensions of the bucket size
    NSInteger halfWidth = self.rect.size.width/2;
    NSInteger halfHeight = self.rect.size.height/2;
    NSInteger x = self.rect.origin.x;
    NSInteger y = self.rect.origin.y;
    
    // Create the sub-buckets
    self.buckets[0] = [[TC_SpatialCollisionManager alloc] initWithLevel:self.depth+1 rect:CGRectMake(x + halfWidth, y, halfWidth, halfHeight)];
    self.buckets[1] = [[TC_SpatialCollisionManager alloc] initWithLevel:self.depth+1 rect:CGRectMake(x, y, halfWidth, halfHeight)];
    self.buckets[2] = [[TC_SpatialCollisionManager alloc] initWithLevel:self.depth+1 rect:CGRectMake(x, y - halfHeight, halfWidth, halfHeight)];
    self.buckets[3] = [[TC_SpatialCollisionManager alloc] initWithLevel:self.depth+1 rect:CGRectMake(x + halfWidth, y - halfHeight, halfWidth, halfHeight)];
}

- (NSInteger)getBucketAddressForNode:(SKSpriteNode *)node {
    
    // Set index default value to -1.
    // This signals that the node cannot fit in a sub-node and is in this depth's main bucket
    NSInteger index = -1;
    
    // Set up some useful vars
    CGFloat verticalMidpoint = CGRectGetMidX(self.rect);
    CGFloat horizontalMidpoint = CGRectGetMidY(self.rect);
    CGRect frame = node.tcBoundingBox;
    
    // Define the top and bottom half of the bucket.
    BOOL top = (frame.origin.y > horizontalMidpoint && frame.origin.y + frame.size.height > horizontalMidpoint);
    BOOL bottom = (frame.origin.y < horizontalMidpoint);
    
    // Check whether the node lies within the left and right half of the current bucket.
    // Assign a bucket if it fits in a quadrant.
    if (frame.origin.x < verticalMidpoint && frame.origin.x + frame.size.width < verticalMidpoint) {
        if (top) {
            index = 1;
        } else if (bottom) {
            index = 2;
        }
    } else if (frame.origin.x > verticalMidpoint) {
        if (top) {
            index = 0;
        } else if (bottom) {
            index = 3;
        }
    }
    
    return index;
}

- (void)registerNode:(SKSpriteNode *)node {
    
    // If there are sub-buckets, get an address for the node.
    if (self.buckets.count && self.buckets[0]) {
        
        NSInteger index = [self getBucketAddressForNode:node];
        
        // If the node fits in a sub-bucket, add to the bucket.
        if (index != -1) {
            self.buckets[index] = node;
            return;
        }
    }

    [self.objects addObject:node];
    
    // If the maximum object cluster size has been reached and we are still above the max depth,
    // split the current bucket into sub buckets.
    if (self.objects.count > max_objects && self.depth < max_depth) {
        
        // Split bucket if not already split
        if (self.buckets.count && !self.buckets[0]) {
            [self split];
        }
        
        NSInteger i = 0;
        
        // Recursively loop downwards until the node is in the correct bucket.
        while (i < self.objects.count) {
            
            NSInteger index = [self getBucketAddressForNode:[self.objects objectAtIndex:i]];
            
            if (index != -1 && self.buckets.count) {
                [self.buckets[index] registerNode:self.objects[i]];
                [self.objects removeObjectAtIndex:i];
            } else {
                i++;
            }
        }
    }
}

- (NSArray *)getNodesNearToNode:(SKSpriteNode *)node {
    
    // Get the address of the node
    NSInteger index = [self getBucketAddressForNode:node];
    NSMutableArray *collected = [[NSMutableArray alloc] init];
    
    // Recurseively look for nodes occupying same bucket.
    if (index != -1 && self.buckets.count && self.buckets[0]) {
        [collected addObjectsFromArray:[self.buckets[index] getNodesNearToNode:node]];
    }
    
    [collected addObjectsFromArray:self.objects];
    
    return collected;
}

@end
