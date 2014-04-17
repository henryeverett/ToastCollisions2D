//
//  TC_CollisionDetector.h
//  ToastCollisions2D
//
//  Created by Henry Everett on 08/04/2014.
//  Copyright (c) 2014 Henry Everett. All rights reserved.
//

@class TC_SpatialCollisionManager;

@interface TC_CollisionDetector : NSObject

@property (nonatomic, strong) TC_SpatialCollisionManager *spatialCollisionManager;

/* Initialize collision detector with a viewport size. */
- (id)initWithViewSize:(CGSize)viewSize;

/* Loops though nodes and generates Collision objects for potential collisions. */
- (void)detectCollisionsBetweenNodes:(NSArray *)nodes withDelta:(NSTimeInterval)delta;

@end
