//
//  SpatialCollisionManager.h
//  ToastCollisions2D
//
//  Created by Henry Everett on 25/03/2014.
//  Copyright (c) 2014 Henry Everett. All rights reserved.
//
//  Generates a grid in the game screen, splitting GameObjects into separate
//  'buckets' (or grid squares) for broad phase collision detection.
//
//  ** Visual Respresentation **
//  (Objects can span multiple grid spaces, eg. Enemy1 below)
//
//  [ Buckets ]
//    -- [1]
//       -- [Player]
//       -- [Enemy1]
//    -- [2]
//       -- [Enemy1]
//       -- [Enemy2]
//    -- [3]
//       -- [Enemy3]

#import <SpriteKit/SpriteKit.h>

@class GameObject;

@interface TC_SpatialCollisionManager : NSObject

@property (nonatomic, assign) NSUInteger gridCellSize;
@property (nonatomic, assign) NSUInteger columns;
@property (nonatomic, assign) NSUInteger rows;
@property (nonatomic, strong) NSMutableDictionary *buckets;

/* Sets up the SCM with the size of the view it will be sweeping. */
- (id)initWithViewSize:(CGSize)viewSize;
/* Resets the buckets dictionary to prepare for a new sweep. */
- (void)resetBuckets;
/* Assigns a grid square for the node that is passed in. */
- (void)registerNode:(SKSpriteNode *)node;
/* Finds other objects in the same bucket for narrow-phase collision detection. */
- (NSArray *)getNodesNearToNode:(SKSpriteNode *)node;

@end
