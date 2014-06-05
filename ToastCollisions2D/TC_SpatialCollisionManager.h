//
//  TC_SpatialCollisionManager.h
//  Pixel Toast
//
//  Created by Henry Everett on 04/06/2014.
//  Copyright (c) 2014 Henry Everett. All rights reserved.
//
// The Spatial Collision Manager now uses a quad-tree structure. This allows unrestricted node size and improves performance.

#import <SpriteKit/SpriteKit.h>

@interface TC_SpatialCollisionManager : NSObject

@property (nonatomic, assign) NSInteger depth;
@property (nonatomic, assign) CGRect rect;
@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic, strong) NSMutableArray *buckets;

/* Initialize a new quadtree with a depth and area. */
- (id)initWithLevel:(NSInteger)level rect:(CGRect)rect;
/* Reset the buckets of the quadtree and remove it's objects recursively. */
- (void)resetBuckets;
/* Register a new node and calculate it's address within the quadtree. */
- (void)registerNode:(SKSpriteNode *)node;
/* Find other nodes within the same bucket. */
- (NSArray *)getNodesNearToNode:(SKSpriteNode *)node;

@end
