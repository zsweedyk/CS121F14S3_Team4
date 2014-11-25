//
//  BHJXStartMenuScene.m
//  Layers
//
//  Created by Jun Hong Park on 10/26/14.
//  Copyright (c) 2014 BHJX. All rights reserved.
//

#import "BHJXStartMenuScene.h"
#import "BHJXIntroLevel1.h"

@implementation BHJXStartMenuScene {
    SKSpriteNode *_background;
    SKLabelNode *_titleLabel;
    SKLabelNode *_adventureLabel;
}



-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        //Load the background
        _background = [SKSpriteNode spriteNodeWithImageNamed:@"StartScreen.png"];
        _background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self addChild:_background];
        
        //Load the button to start the game
        _adventureLabel = [[SKLabelNode alloc] initWithFontNamed:@"Zapfino"];
        _adventureLabel.name = @"AdventureLabel";
        _adventureLabel.text = @"- Adventure Mode";
        _adventureLabel.fontColor = [SKColor blackColor];
        _adventureLabel.fontSize = 25;
        _adventureLabel.position = CGPointMake(self.frame.size.width*0.66, self.frame.size.height*0.65);
        [self addChild:_adventureLabel];
        
        
        
    }
    return self;
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    //Start the game when the player presses the button
    if ([node.name isEqualToString:@"AdventureLabel"]) {
        _adventureLabel.fontSize = 26;
        SKTransition *reveal = [SKTransition fadeWithDuration:3];
        
        BHJXIntroLevel1 *scene = [BHJXIntroLevel1 sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene transition:reveal];
                          
    }

}

@end
