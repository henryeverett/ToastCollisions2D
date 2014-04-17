//
//  MyScene.h
//  ToastCollisions2D_Sample
//

//  Copyright (c) 2014 Henry Everett. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "TC_Direction.h"

@class JSTileMap, TMXLayer, Player, TC_CollisionDetector;

@interface MyScene : SKScene

@property (nonatomic, strong) JSTileMap *map;
@property (nonatomic, strong) TMXLayer *walls;
@property (nonatomic, strong) Player *player;
@property (nonatomic, strong) NSArray *allObjects;
@property (nonatomic, assign) NSTimeInterval lastUpdate;
@property (nonatomic, assign) TC_Direction movementDirection;

@property (nonatomic, strong) TC_CollisionDetector *collisionDetector;

@end
