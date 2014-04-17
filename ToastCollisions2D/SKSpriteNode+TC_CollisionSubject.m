//
//  SKSpriteNode+TC_CollisionSubject.m
//  ToastCollisions2D
//
//  Created by Henry Everett on 10/04/2014.
//  Copyright (c) 2014 Henry Everett. All rights reserved.
//

#import "SKSpriteNode+TC_CollisionSubject.h"
#import <objc/runtime.h>
#import "TC_Direction.h"
#import "SKTUtils.h"

@implementation SKSpriteNode (TC_CollisionSubject)

-(void)setTcStatic:(BOOL)tcStatic {
    objc_setAssociatedObject(self,@selector(tcStatic),[NSNumber numberWithBool:tcStatic],OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)tcStatic {
    return [objc_getAssociatedObject(self, @selector(tcStatic)) boolValue];
}

- (void)setTcVelocity:(CGPoint)tcVelocity {
    objc_setAssociatedObject(self,@selector(tcVelocity),[NSValue valueWithCGPoint:tcVelocity],OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGPoint)tcVelocity {
    return [objc_getAssociatedObject(self, @selector(tcVelocity)) CGPointValue];
}

- (void)setTcCollisionResponse:(TC_CollisionResponse *)tcCollisionResponse {
    objc_setAssociatedObject(self,@selector(tcCollisionResponse),tcCollisionResponse,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (TC_CollisionResponse *)tcCollisionResponse {
    return objc_getAssociatedObject(self, @selector(tcCollisionResponse));
}

- (float)heightAtXPosition:(float)XPosition {
    
    float rightHeight = 0;
    float leftHeight = 0;
    float addTileWidth = 0;
    
    if ([self respondsToSelector:@selector(rightSlopeHeight)]) {
        rightHeight = self.rightSlopeHeight;
    }
    
    if ([self respondsToSelector:@selector(leftSlopeHeight)]) {
        leftHeight = self.leftSlopeHeight;
    }
    
    // If slope is from left to right, add tile width to equation
    if (self.leftSlopeHeight > self.rightSlopeHeight) {
        addTileWidth = self.size.width;
    }
    
    // Work out the position of the object on the tile
    float pos = ( XPosition - self.position.x + addTileWidth ) / self.size.width;
    
    // Work out the floor height at that position
    float floorHeight = (1-pos) * self.leftSlopeHeight + pos * self.rightSlopeHeight;
    return (floorHeight < 0) ? 0 : floorHeight;
    
}

- (BOOL)isSlope {
    
    if ([self respondsToSelector:@selector(rightSlopeHeight)] && [self respondsToSelector:@selector(leftSlopeHeight)]) {
        return (self.rightSlopeHeight || self.leftSlopeHeight);
    }
    
    return NO;
}

- (void)applyPositionWithDelta:(NSTimeInterval)delta {
    
    // Get delta time of velocity and update the actor's desired position.
    CGPoint velocityStep = CGPointMultiplyScalar(self.tcVelocity, delta);
    self.position = CGPointAdd(self.position, velocityStep);
    
}


@end
