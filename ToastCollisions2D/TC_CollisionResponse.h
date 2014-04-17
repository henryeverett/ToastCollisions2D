//
//  TC_CollisionResponse.h
//  ToastCollisions2D
//
//  Created by Henry Everett on 10/04/2014.
//  Copyright (c) 2014 Henry Everett. All rights reserved.
//

#import "SKSpriteNode+TC_CollisionSubject.h"

@class TC_Collision;

@interface TC_CollisionResponse : NSObject

@property (nonatomic, strong) SKSpriteNode <TCCollisionSubjectDelegate> *delegate;

/* Initialize with a delegate. The delegate is the node which is affected by the collision. */
- (id)initWithDelegate:(id)delegate;
/* Respond to a collision. This is called from the TC_CollisionDetector class. */
- (void)respondToCollision:(TC_Collision *)collision withDelta:(NSTimeInterval)delta;

@end
