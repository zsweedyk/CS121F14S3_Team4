//
//  BHJXViewController.m
//  Layers
//
//  Created by Jun Hong Park on 10/12/14.
//  Copyright (c) 2014 BHJX. All rights reserved.
//

#import "BHJXViewController.h"
#import "BHJXLevel1Scene.h"
#import "BHJXStartMenuScene.h"

@implementation BHJXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Configure the view after it has been sized for the correct orientation.
    SKView *skView = (SKView *)self.view;
    
    
    if (!skView.scene) {
        
        // Create and configure the start menu scene.
        BHJXStartMenuScene *theScene = [BHJXStartMenuScene sceneWithSize:skView.bounds.size];
        theScene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:theScene];
    }
    
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
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
