//
//  TC_CollisionDetector.m
//  ToastCollisions2D
//
//  Created by Henry Everett on 08/04/2014.
//  Copyright (c) 2014 Henry Everett. All rights reserved.
//

#import "TC_CollisionDetector.h"
#import "SKSpriteNode+TC_CollisionSubject.h"
#import "TC_SpatialCollisionManager.h"
#import "SKTUtils.h"
#import "TC_Collision.h"
#import "TC_Direction.h"
#import "TC_CollisionResponse.h"

#import "TC_SpatialCollisionManager.h"

// Private methods
@interface TC_CollisionDetector()

/* Generate a CGRect representation of a node's trajectory. */
- (CGRect)projectedVelocityAABBForNode:(SKSpriteNode *)node withDelta:(NSTimeInterval)delta tall:(BOOL)tall;
/* Calculate the distance between two nodes. */
- (CGFloat)distanceBetweenNodeA:(SKSpriteNode *)nodeA andNodeB:(SKSpriteNode*)nodeB;
/* Generate a CGPoint representation of the normal between two rectangles. */
- (CGPoint)normalFromRectA:(CGRect)rectA toRectB:(CGRect)rectB;
/* Get the center point of a rectangle. */
- (CGPoint)centerOfRect:(CGRect)rect;
/* Calculate the dot product of two points. */
- (CGFloat)dotProductOfPointA:(CGPoint)pointA andPointB:(CGPoint)pointB;
/* Get the major axis of a vector. */
- (CGPoint)majorAxisFromVector:(CGPoint)vector;
/* Get the sign value of a float. */
- (NSInteger)signOfFloat:(CGFloat)n;

@end

@implementation TC_CollisionDetector

- (id)initWithViewSize:(CGSize)viewSize {
    
    self = [super init];
    if (self) {
    
        self.spatialCollisionManager = [[TC_SpatialCollisionManager alloc] initWithLevel:0 rect:CGRectMake(0, 0, viewSize.width, viewSize.height)];
        
    }
    return self;
}

- (void)detectCollisionsBetweenNodes:(NSArray *)nodes withDelta:(NSTimeInterval)delta {
     
    // Reset spatial collision manager buckets
    [self.spatialCollisionManager resetBuckets];
    
    // Register each node with the spatial collision manager
    for (SKSpriteNode *node in nodes) {
        [self.spatialCollisionManager registerNode:(SKSpriteNode*)node];
    }
    
    // Remove any static nodes from the list of candidates
    NSPredicate *noStaticPredicate = [NSPredicate predicateWithFormat:@"tcStatic != YES"];
    NSArray *noStatic = [nodes filteredArrayUsingPredicate:noStaticPredicate];
    
    // Main detection loop
    for (SKSpriteNode *nodeA in noStatic) {
        
        // For each node, check for potential collision candidates
        for (SKSpriteNode *nodeB in [self.spatialCollisionManager getNodesNearToNode:nodeA]) {
            
            // If node is itself, discard it.
            if ([nodeA isEqual:nodeB]) continue;
            
            // Each node is broken into two thinner rectangles forming a cross shape
            // to avoid sticky corner bugs. The collision detection is then run twice:
            // once for the tall rect and once for the wide.
            for (NSInteger i = 0; i < 2; i++) {
                
                // Set tall check on the first of the two loops. (The Y axis should be resolved first)
                BOOL checkTall = (i % 2);

                // Project the movement of nodeA within the next frame and generate a rectangle that encompasses that projection
                CGRect projection = [self projectedVelocityAABBForNode:nodeA withDelta:delta tall:checkTall];
                
                // If nodeA's projection rectangle intersects with nodeB, they will collide.
                if (CGRectIntersectsRect(projection, nodeB.tcBoundingBox)) {
                    
                    // Get the distance between the two nodes
                    float separationDistance = [self distanceBetweenNodeA:nodeA andNodeB:nodeB];
                    
                    // Generate a collision object and populate it with the data needed for resolution
                    TC_Collision *collision = [[TC_Collision alloc] init];
                    collision.collidedWith = nodeB;
                    collision.yAxisOnly = checkTall; // Pass in whether we are checking the tall or short section of the cross shape
                    collision.normal = [self normalFromRectA:nodeA.tcBoundingBox toRectB:nodeB.tcBoundingBox]; // Get the normal of the collision
                    collision.distance = separationDistance;
                    
                    // Get the normal velocity of nodeA
                    collision.normalVelocity = [self dotProductOfPointA:nodeA.tcVelocity andPointB:collision.normal] + collision.clampedDistance/delta;
                    
                    // If a custom collision response has not been assigned, use the default
                    if (!nodeA.tcCollisionResponse) {
                        nodeA.tcCollisionResponse = [[TC_CollisionResponse alloc] initWithDelegate:nodeA];
                    }
                    
                    // Respond to the collision
                    [nodeA.tcCollisionResponse respondToCollision:collision withDelta:delta];
                }
            }
        }
    }
}

- (CGRect)projectedVelocityAABBForNode:(SKSpriteNode *)node withDelta:(NSTimeInterval)delta tall:(BOOL)tall {
    
    CGRect nodeBounds = CGRectZero;
    
    // Create tall or wide rectangle depending on 'tall' BOOL
    // TODO: These should probably be a percentage of the node's frame dimensions
    if (tall) {
        
        nodeBounds = CGRectMake(node.tcBoundingBox.origin.x + 5,
                                node.tcBoundingBox.origin.y,
                                node.tcBoundingBox.size.width - 10,
                                node.tcBoundingBox.size.height);
    } else {
        
        nodeBounds = CGRectMake(node.tcBoundingBox.origin.x,
                                node.tcBoundingBox.origin.y - 5,
                                node.tcBoundingBox.size.width,
                                node.tcBoundingBox.size.height - 10);
    }
    
    // Get the predicted position of the node
    CGPoint predictedPosition = CGPointAdd(node.position, CGPointMultiplyScalar(node.tcVelocity, delta));
    
    // Increase the rectangle by half the height and width of the node to account for the size of the node.
    CGPoint halfExtents = CGPointMake(nodeBounds.size.width/2, nodeBounds.size.height/2);
    
    CGPoint min = CGPointMake(MIN(node.position.x, predictedPosition.x) - halfExtents.x,
                              MAX(node.position.y, predictedPosition.y) + halfExtents.y);
    CGPoint max = CGPointMake(MAX(node.position.x, predictedPosition.x) + halfExtents.x,
                              MIN(node.position.y, predictedPosition.y) - halfExtents.y);
    
    return CGRectMake(MIN(min.x, max.x),MIN(min.y, max.y),fabs(min.x - max.x),fabs(min.y - max.y));
    
}

- (CGFloat)distanceBetweenNodeA:(SKSpriteNode *)nodeA andNodeB:(SKSpriteNode*)nodeB {
    
    CGPoint halfA = CGPointMake(CGRectGetWidth(nodeA.tcBoundingBox)/2, CGRectGetHeight(nodeA.tcBoundingBox)/2);
    CGPoint halfB = CGPointMake(CGRectGetWidth(nodeB.tcBoundingBox)/2, CGRectGetHeight(nodeB.tcBoundingBox)/2);
    
    CGPoint combinedHalves = CGPointAdd(halfA, halfB);

    CGPoint normal = [self normalFromRectA:nodeA.tcBoundingBox toRectB:nodeB.tcBoundingBox];
    
    CGPoint normalStart = CGPointMake(normal.x * combinedHalves.x, normal.y * combinedHalves.y);
    normalStart = CGPointAdd(normalStart, [self centerOfRect:nodeB.tcBoundingBox]);

    CGPoint planeNormal = CGPointSubtract([self centerOfRect:nodeA.tcBoundingBox], normalStart);
    
    return [self dotProductOfPointA:planeNormal andPointB:normal];

}

- (CGPoint)normalFromRectA:(CGRect)rectA toRectB:(CGRect)rectB {
    
    CGPoint distanceBetweenCenters = CGPointSubtract([self centerOfRect:rectB],
                                                     [self centerOfRect:rectA]);
    CGPoint normal = [self majorAxisFromVector:distanceBetweenCenters];
    
    return CGPointMake(-normal.x, -normal.y);
}

- (CGPoint)centerOfRect:(CGRect)rect {
    return CGPointMake(CGRectGetMidX(rect),CGRectGetMidY(rect));
}

- (CGFloat)dotProductOfPointA:(CGPoint)pointA andPointB:(CGPoint)pointB {
    return pointA.x * pointB.x + pointA.y * pointB.y;
}

- (CGPoint)majorAxisFromVector:(CGPoint)vector {
    
    if (fabsf(vector.x) > fabsf(vector.y)) {
        return CGPointMake([self signOfFloat:vector.x], 0);
    } else {
        return CGPointMake(0, [self signOfFloat:vector.y]);
    }
}

- (NSInteger)signOfFloat:(CGFloat)n {
    return (n < 0) ? -1 : (n > 0) ? +1 : 0;
}




@end
