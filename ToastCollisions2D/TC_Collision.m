//
//  TC_Collision.m
//  ToastCollisions2D
//
//  Created by Henry Everett on 10/04/2014.
//  Copyright (c) 2014 Henry Everett. All rights reserved.
//

#import "TC_Collision.h"

@implementation TC_Collision

- (TC_Direction)direction {
    
    if (self.normal.y == 1) {
        return down;
    } else if (self.normal.y == -1) {
        return up;
    } else if (self.normal.x == 1) {
        return left;
    } else if (self.normal.x == -1) {
        return right;
    }
    
    return none;
}


@end
