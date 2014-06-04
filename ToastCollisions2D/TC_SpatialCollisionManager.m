//
//  SpatialCollisionManager.m
//  ToastCollisions2D
//
//  Created by Henry Everett on 25/03/2014.
//  Copyright (c) 2014 Henry Everett. All rights reserved.
//

#import "TC_SpatialCollisionManager.h"
#import "SKSpriteNode+TC_CollisionSubject.h"

@interface TC_SpatialCollisionManager()

/* Establish which buckets the GameNode is occupying. */
- (NSArray *)getBucketAddressesForNode:(SKSpriteNode *)node;
/* Create a bucket if it doesn't already exist. */
- (void)createBucketForPoint:(CGPoint)point andAddToArray:(NSMutableArray *)buckets;

@end

@implementation TC_SpatialCollisionManager

- (id)initWithViewSize:(CGSize)viewSize {
    
    self = [super init];
    if (self) {
        
        // Set up defaults
        self.gridCellSize = 400;
        
        self.rows = (viewSize.height / self.gridCellSize) + 1;
        self.columns = (viewSize.width / self.gridCellSize) + 1;
        
        [self resetBuckets];
    }
    return self;
}

- (void)resetBuckets {
    
    // Release buckets array and re-init
    self.buckets = nil;
    self.buckets = [[NSMutableDictionary alloc] init];
    
    // Create blank arrays for future population.
    for (NSUInteger i = 0; i < self.rows * self.columns; i++) {
        [self.buckets setObject:[[NSMutableArray alloc] init] forKey:[NSString stringWithFormat:@"%lu",(unsigned long)i]];
    }
}

- (void)registerNode:(SKSpriteNode *)node {

    NSArray *bucketAddresses = [self getBucketAddressesForNode:node];
    
    // For each of the bucket addresses for the game node, add the game node to those addresses in the buckets array.
    for (NSNumber *address in bucketAddresses) {
        [self.buckets[address.stringValue] addObject:node];
    }
    
}

- (NSArray *)getBucketAddressesForNode:(SKSpriteNode *)node {

    NSMutableArray *nodeBuckets = [[NSMutableArray alloc] init];
    
    CGPoint positionInView = node.position;
    
    // Get the four corner positions of the GameNode's frame.
    CGPoint nodeTopLeftCorner = positionInView;
    CGPoint nodeBottomLeftCorner = CGPointMake(positionInView.x, positionInView.x + node.tcBoundingBox.size.height);
    CGPoint nodeBottomRightCorner = CGPointMake(positionInView.x + node.tcBoundingBox.size.width, positionInView.y + node.tcBoundingBox.size.height);
    CGPoint nodeTopRightCorner = CGPointMake(positionInView.x + node.tcBoundingBox.size.width, nodeTopLeftCorner.y);

    // For each corner, create a bucket (if it doesn't exist).
    [self createBucketForPoint:nodeBottomLeftCorner andAddToArray:nodeBuckets];
    [self createBucketForPoint:nodeTopLeftCorner andAddToArray:nodeBuckets];
    [self createBucketForPoint:nodeBottomRightCorner andAddToArray:nodeBuckets];
    [self createBucketForPoint:nodeTopRightCorner andAddToArray:nodeBuckets];
    
    return nodeBuckets;
    
}

- (void)createBucketForPoint:(CGPoint)point andAddToArray:(NSMutableArray *)buckets {
    
    // Calculate the bucket's address
    NSNumber *newBucketAddress = [NSNumber numberWithInt:(NSInteger)(floorf(point.x / self.gridCellSize)) + (floorf(point.y / self.gridCellSize)) * self.columns];

    // Check if bucket already exists in the buckets array
    NSUInteger index = [buckets indexOfObjectPassingTest:^BOOL(NSNumber *bucketAddress, NSUInteger idx, BOOL *stop) {
        return  [newBucketAddress integerValue] == [bucketAddress integerValue];
    }];
    
    // If it doesn't exist, create it.
    if (index == NSNotFound) {
        [buckets addObject:newBucketAddress];
    }
    
}

- (NSArray *)getNodesNearToNode:(SKSpriteNode *)node {
 
    NSMutableArray *nearbyNodes = [[NSMutableArray alloc] init];

    NSArray *bucketAddresses = [self getBucketAddressesForNode:node];
    
    // Get all the of the other nodes in the buckets that the node inhabits.
    for (NSNumber *address in bucketAddresses) {
        [nearbyNodes addObjectsFromArray:self.buckets[address.stringValue]];
        
    }
    
    return nearbyNodes;
}

@end
