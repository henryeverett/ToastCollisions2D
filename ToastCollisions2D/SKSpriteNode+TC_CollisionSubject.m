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
#import "TC_Collision.h"
#import "SKTUtils.h"

@implementation SKSpriteNode (TC_CollisionSubject)

-(void)setTcStatic:(BOOL)tcStatic {
    objc_setAssociatedObject(self,@selector(tcStatic),[NSNumber numberWithBool:tcStatic],OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)tcStatic {
    return [objc_getAssociatedObject(self, @selector(tcStatic)) boolValue];
}

-(void)setTcPassable:(BOOL)tcPassable {
    objc_setAssociatedObject(self,@selector(tcPassable),[NSNumber numberWithBool:tcPassable],OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)tcPassable {
    return [objc_getAssociatedObject(self, @selector(tcPassable)) boolValue];
}

- (void)setTcVelocity:(CGPoint)tcVelocity {
    objc_setAssociatedObject(self,@selector(tcVelocity),[NSValue valueWithCGPoint:tcVelocity],OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGPoint)tcVelocity {
    return [objc_getAssociatedObject(self, @selector(tcVelocity)) CGPointValue];
}

- (void)setTcBoundingBoxSize:(CGSize)tcBoundingBoxSize {
    objc_setAssociatedObject(self,@selector(tcBoundingBoxSize),[NSValue valueWithCGSize:tcBoundingBoxSize],OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGSize)tcBoundingBoxSize {
    
    CGSize boundingBoxSize = [objc_getAssociatedObject(self, @selector(tcBoundingBoxSize)) CGSizeValue];
    
    if (!boundingBoxSize.width || !boundingBoxSize.height) {
        boundingBoxSize = self.size;
    }
    
    return boundingBoxSize;
}

- (CGRect)tcBoundingBox {
    
    CGRect newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.size.width, self.size.height);
    
    return CGRectInset(newFrame, (self.size.height - self.tcBoundingBoxSize.height) / 2, (self.size.width - self.tcBoundingBoxSize.width) / 2);
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
        addTileWidth = self.tcBoundingBox.size.width;
    }
    
    // Work out the position of the object on the tile
    float pos = ( XPosition - self.position.x + addTileWidth ) / self.tcBoundingBox.size.width;
    
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

- (void)attachDebugRectWithSize:(CGSize)s {
    CGPathRef bodyPath = CGPathCreateWithRect( CGRectMake(-s.width/2, -s.height/2, s.width,   s.height),nil);
    [self attachDebugFrameFromPath:bodyPath];
    CGPathRelease(bodyPath);
}

- (void)attachDebugFrameFromPath:(CGPathRef)bodyPath {
    //if (kDebugDraw==NO) return;
    
    for (SKShapeNode *shape in self.children) {
        [shape removeFromParent];
    }
    
    SKShapeNode *shape = [SKShapeNode node];
    shape.path = bodyPath;
    shape.strokeColor = [SKColor colorWithRed:1.0 green:0 blue:0 alpha:0.5];
    shape.lineWidth = 1.0;
    [self addChild:shape];
}

@end
