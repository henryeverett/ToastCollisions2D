//
//  MyScene.m
//  ToastCollisions2D_Sample
//
//  Created by Henry Everett on 17/04/2014.
//  Copyright (c) 2014 Henry Everett. All rights reserved.
//

#import "MyScene.h"
#import "JSTileMap.h"
#import "Player.h"
#import "SKTUtils.h"
#import "TC_CollisionDetector.h"

@implementation MyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor whiteColor];
        self.scaleMode = SKSceneScaleModeAspectFit;
        
        self.collisionDetector = [[TC_CollisionDetector alloc] initWithViewSize:self.size];
        
        self.movementDirection = none;
    }
    return self;
}

- (void)didMoveToView:(SKView *)view {
    
    [self addChild:self.map];
    
    self.player = [[Player alloc] initWithColor:[SKColor blueColor] size:CGSizeMake(32, 32)];
    self.player.position = CGPointMake(100, 250);
    
    [self.map addChild:self.player];
    
    self.walls = [self.map layerNamed:@"walls"];
    // Make walls static
    for(SKSpriteNode *wall in [self.walls.children[0] children]) {
        wall.tcStatic = YES;
    }
    
    self.allObjects = [[NSArray arrayWithObject:self.player] arrayByAddingObjectsFromArray:[self.walls.children[0] children]];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    NSTimeInterval delta = currentTime - self.lastUpdate;
    
    // Restrict delta
    if (delta > 0.02) {
        delta = 0.02;
    }
    
    self.lastUpdate = currentTime;
    
    [self applyGravityWithDelta:delta toNode:self.player];
    [self applyMovementWithDelta:delta toNode:self.player];
    
    // This is where you should be adding the collision detection. After any velocity changes and before those changes are applied to movement.
    [self.collisionDetector detectCollisionsBetweenNodes:self.allObjects withDelta:delta];
    
    CGPoint velocityStep = CGPointMultiplyScalar(self.player.tcVelocity, delta);
    self.player.position = CGPointAdd(self.player.position, velocityStep);
}

- (void)applyGravityWithDelta:(NSTimeInterval)delta toNode:(SKSpriteNode *)node {
    
    // Apply gravity, it's strength can be modified by overriding the _gravityFactor property in an Engine subclass
    CGPoint gravity = CGPointMultiplyScalar(CGPointMake(0.0, -3000.0), delta);
    
    // Apply gravity velocity to Game Object
    node.tcVelocity = CGPointAdd(node.tcVelocity, gravity);
    
}

- (void)applyMovementWithDelta:(NSTimeInterval)delta toNode:(SKSpriteNode *)node {
    
    CGPoint speed = CGPointMultiplyScalar(CGPointMake(8000.0, 0.0), delta);
    
    if (self.movementDirection == left) {
        self.player.tcVelocity = CGPointSubtract(self.player.tcVelocity, speed);
    } else if (self.movementDirection == right) {
        self.player.tcVelocity = CGPointAdd(self.player.tcVelocity, speed);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *myTouch = [touches anyObject];
    
    CGPoint touchPoint = [myTouch locationInView:self.view];
    
    if ( touchPoint.x < self.size.width/2 ) { //Left
        self.movementDirection = left;
    } else { // Right
        self.movementDirection = right;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.movementDirection = none;
}

@end
