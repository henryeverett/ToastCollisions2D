//
//  SKSpriteNode+TC_CollisionSubject.h
//  ToastCollisions2D
//
//  Created by Henry Everett on 10/04/2014.
//  Copyright (c) 2014 Henry Everett. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class TC_CollisionResponse, TC_Collision;

@protocol TCCollisionSubjectDelegate <NSObject>

@optional
/* Called before collision resolution. */
- (void)collisionDetected:(TC_Collision *)collision;
/* Called after collision resolution. */
- (void)collisionResolved:(TC_Collision *)collision;
/* Define friction of this node on other colliding nodes. */
- (CGFloat)friction;
/* Define the height of the slope's right edge. */
- (CGFloat)rightSlopeHeight;
/* Define the height of the slope's left edge. */
- (CGFloat)leftSlopeHeight;
/* Check if collision response should ignore a direction. Can be used for one-way tiles. */
- (BOOL)ignoresCollision:(TC_Collision *)collision;

@end

@interface SKSpriteNode (TC_CollisionSubject) <TCCollisionSubjectDelegate>

@property (nonatomic, assign) BOOL tcStatic;
@property (nonatomic, assign) BOOL tcPassable;
@property (nonatomic, assign) CGPoint tcVelocity;
@property (nonatomic, strong) TC_CollisionResponse *tcCollisionResponse;

/* Define getters and setters. (Needed for category properties.) */
- (void)setTcStatic:(BOOL)tcStatic;
- (BOOL)tcStatic;
- (void)setTcPassable:(BOOL)tcPassable;
- (BOOL)tcPassable;
- (void)setTcVelocity:(CGPoint)tcVelocity;
- (CGPoint)tcVelocity;
- (TC_CollisionResponse *)tcCollisionResponse;
/* Calculate the height of a slope at a given X coordinate. */
- (float)heightAtXPosition:(float)XPosition;
/* Return whether this node is a 'slope' based on the presence of the left and right slope heights. */
- (BOOL)isSlope;
/* Apply any calculated velocity to the node's position. */
- (void)applyPositionWithDelta:(NSTimeInterval)delta;

@end
