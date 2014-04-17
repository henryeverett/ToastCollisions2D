//
//  TC_CollisionResponse.m
//  ToastCollisions2D
//
//  Created by Henry Everett on 10/04/2014.
//  Copyright (c) 2014 Henry Everett. All rights reserved.
//

#import "TC_CollisionResponse.h"
#import "TC_Collision.h"
#import "SKTUtils.h"

@interface TC_CollisionResponse ()

/* Adjusts the delegate node's position based on a collision with a static object (eg. a tile) */
- (void)respondToStaticCollision:(TC_Collision *)collision;
/* Get the tangent of a point. */
- (CGPoint)tangentOfPoint:(CGPoint)point;
/* Calculate the dot product of a point. */
- (CGFloat)dotProductOfPointA:(CGPoint)pointA andPointB:(CGPoint)pointB;

@end

@implementation TC_CollisionResponse

- (id)initWithDelegate:(id)delegate {
    
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)respondToCollision:(TC_Collision *)collision withDelta:(NSTimeInterval)delta {
    
    /* Respond to collisions with other dynamic objects. This hook allows you to define this behaviour youself. */
    if ([self.delegate respondsToSelector:@selector(collisionDetected:)]) {
        [self.delegate collisionDetected:collision];
    }
    
    /* Respond to a collision with a static node. (ie. a wall/ground tile) */
    if (collision.collidedWith.tcStatic) {
        [self respondToStaticCollision:collision];
    }

}

- (void)respondToStaticCollision:(TC_Collision *)collision {
    
    // Handle embeding by moving the node out of a collision until only 1 pixel embedded.
    if (collision.distance < 0) {
        self.delegate.position = CGPointAdd(self.delegate.position, CGPointMultiplyScalar(collision.normal, fabsf(collision.distance)-1));
    }

    // If the anticipated velocity will cause a collision
    if (collision.normalVelocity < 0) {
        
        if (collision.collidedWith.isSlope && (collision.direction == left || collision.direction == right)) {
            
            // Allow movement into sloped tiles.
            
        } else {
            
            // Reduce the velocity of the node so it comes to a stop before intersecting with it's collision candidate.
            CGPoint resolution = CGPointSubtract(self.delegate.tcVelocity, CGPointMultiplyScalar(collision.normal, collision.normalVelocity));
            self.delegate.tcVelocity = CGPointMake((collision.yAxisOnly) ? self.delegate.tcVelocity.x : resolution.x, resolution.y);
            
        }
        
        // If we are colliding with a sloped tile, adjust the nodes position to the height of the slope.
        if (collision.collidedWith.isSlope) {
                
            float heightToRemove = 0;
        
            // If the slope graduates to the left, adjust the position of the node based on the height of the slope at it's left edge.
            if (collision.collidedWith.rightSlopeHeight < collision.collidedWith.leftSlopeHeight) {
                heightToRemove = collision.collidedWith.frame.size.height - [collision.collidedWith heightAtXPosition:self.delegate.frame.origin.x - (self.delegate.frame.size.width/2)];
                
            // If the slope graduates to the right, adjust the position of the node based on the height of the slope at it's right edge.
            } else {
                heightToRemove = collision.collidedWith.frame.size.height - [collision.collidedWith heightAtXPosition:self.delegate.position.x + self.delegate.frame.size.width];
            }
            
            // Adjust the position
            if (remove > 0) {
                self.delegate.position = CGPointMake(self.delegate.position.x,
                                                     collision.collidedWith.frame.origin.y +
                                                     collision.collidedWith.frame.size.height +
                                                     (self.delegate.frame.size.height/2) - heightToRemove);
            }
            
            
        }

        // Default friction
        CGFloat friction = 0.2f;
        
        // Hook to allow custom adjustment of friction
        if ([collision.collidedWith respondsToSelector:@selector(friction)]) {
            friction = collision.collidedWith.friction;
        }
        
        if (friction != 0) {
            
            // get the tanget from the normal
            CGPoint tangent = [self tangentOfPoint:collision.normal];
            
            // scale tangential velocity by the friction value
            float tv = [self dotProductOfPointA:self.delegate.tcVelocity andPointB:tangent]*friction;
            
            // subtract that from the main velocity
            CGPoint newVelocity = CGPointSubtract(self.delegate.tcVelocity, CGPointMultiplyScalar(tangent, tv));
            self.delegate.tcVelocity = CGPointMake(newVelocity.x, self.delegate.tcVelocity.y);

        }
        
        // Hook to allow processing of a resolved collision.
        if ([self.delegate respondsToSelector:@selector(collisionResolved:)]) {
            [self.delegate collisionResolved:collision];
        }

    }

}

- (CGPoint)tangentOfPoint:(CGPoint)point {
    return CGPointMake(-point.y, point.x);
}

- (CGFloat)dotProductOfPointA:(CGPoint)pointA andPointB:(CGPoint)pointB {
    return pointA.x * pointB.x + pointA.y * pointB.y;
}


@end