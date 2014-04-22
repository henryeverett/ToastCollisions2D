//
//  TC_Collision.h
//  ToastCollisions2D
//
//  Created by Henry Everett on 10/04/2014.
//  Copyright (c) 2014 Henry Everett. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "TC_Direction.h"

@interface TC_Collision : NSObject

@property (nonatomic, strong) SKSpriteNode *collidedWith;
@property (nonatomic, assign) CGPoint normal;
@property (nonatomic, assign) CGFloat distance;
@property (nonatomic, assign) CGFloat normalVelocity;
@property (nonatomic, assign) BOOL yAxisOnly;

/* Convert the normal property into a direction value. */
- (TC_Direction)direction;
/* Return clamped distance to prevent a negative value. */
- (CGFloat)clampedDistance;

@end
