ToastCollisions2D
=================

Real time collision detection for 2D Sprite Kit games.

This library extends SKSpriteNode and helps you drop a real time AABB collision system into your game. For use primarily with tile-based 2D games, it is not designed to emulate real world collisions - instead allowing you to apply your own custom physics.

It requires Apple's Sprite Kit but the concepts can easily be transferred to other libraries/languages. It is designed to be tile-independent allowing you to use whatever tile system you want to (or none at all). The sample project uses https://github.com/slycrel/JSTileMap.

An excellent explaination of the speculative contacts method used in the narrow-phase of the collision detection can be found here: http://wildbunny.co.uk/blog/2011/12/14/how-to-make-a-2d-platform-game-part-2-collision-detection/

At the moment ToastCollision2D has basic slope support (which needs improvement) and only supports AABB collisions between SKSpriteNode frame rectangles.


How to Install
-------------
Drop the ToastCollisions2D directory into your project and import.
```obj-c
#import "TC_CollisionDetector.h"

- (void)update:(CFTimeInterval)currentTime {

    // ...calculate delta
    
    // ...apply velocity changes
    
    // ToastCollisions2D Collision detection
    [self.collisionDetector detectCollisionsBetweenNodes:self.allObjects withDelta:delta];
    
    // Apply velocity
    CGPoint velocityStep = CGPointMultiplyScalar(self.player.tcVelocity, delta);
    self.player.position = CGPointAdd(self.player.position, velocityStep);
}
```

Contribute
-------------
Please contribute to the project if you can. My aim is to produce an easy drop-in collision solution which will cater for custom physics worlds in 2D Sprite Kit games.

Credits
-------------
Many concepts (and some code) borrowed from the following sources:
http://wildbunny.co.uk/blog/2011/12/14/how-to-make-a-2d-platform-game-part-2-collision-detection/ (Speculative contacts)
http://conkerjo.wordpress.com/2009/06/13/spatial-hashing-implementation-for-fast-2d-collisions/ (Spatial hashing)
https://github.com/raywenderlich/SKTUtils (CGPoint math)
