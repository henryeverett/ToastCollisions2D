//
//  SKSpriteNode+Tile.m
//  ToastCollisions2D_Sample
//
//  Created by Henry Everett on 17/04/2014.
//  Copyright (c) 2014 Henry Everett. All rights reserved.
//

#import "SKSpriteNode+Tile.h"
#import "MyScene.h"
#import "JSTileMap.h"

@implementation SKSpriteNode (Tile)

- (int)GIDForTile {
    TMXLayer *layer = ((MyScene *)self.scene).walls;
    TMXLayerInfo *layerInfo = layer.layerInfo;
    
    CGPoint mapCoord = [layer coordForPoint:self.position];
    return [layerInfo tileGidAtCoord:mapCoord];
}

- (CGFloat)rightSlopeHeight {
    
    JSTileMap *map = ((MyScene *)self.scene).map;
    return [[[map propertiesForGid:self.GIDForTile] objectForKey:@"rightHeight"] floatValue];
    
}

- (CGFloat)leftSlopeHeight {
    
    JSTileMap *map = ((MyScene *)self.scene).map;
    return [[[map propertiesForGid:self.GIDForTile] objectForKey:@"leftHeight"] floatValue];
}

@end
