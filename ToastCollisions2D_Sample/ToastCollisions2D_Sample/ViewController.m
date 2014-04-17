//
//  ViewController.m
//  ToastCollisions2D_Sample
//
//  Created by Henry Everett on 17/04/2014.
//  Copyright (c) 2014 Henry Everett. All rights reserved.
//

#import "ViewController.h"
#import "JSTileMap.h"
#import "MyScene.h"

@implementation ViewController

- (id)init {
    
    if (self = [super init]) {
        SKView *spriteKitView = [[SKView alloc] init];
        spriteKitView.showsFPS = YES;
        spriteKitView.showsNodeCount = YES;
        self.view = spriteKitView;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    // TODO: Load from level map array
    MyScene *scene = [[MyScene alloc] initWithSize:self.view.bounds.size];
    scene.map = [JSTileMap mapNamed:@"map.tmx"];
    
    [(SKView *)self.view presentScene:scene];
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
