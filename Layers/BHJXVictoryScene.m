//
//  BHJXVictoryScene.m
//  Layers
//
//  Created by Jun Hong Park on 11/16/14.
//  Copyright (c) 2014 BHJX. All rights reserved.
//

#import "BHJXVictoryScene.h"
#import "BHJXStartMenuScene.h"

@implementation BHJXVictoryScene



-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        //You won!
        NSString *message = @"You Won!";
        SKLabelNode *loseLabel = [SKLabelNode labelNodeWithFontNamed:@"TimesNewRomanPSMT"];
        loseLabel.text = message;
        loseLabel.fontSize = 50;
        loseLabel.position = CGPointMake(self.size.width/2, self.size.height/1.8);
        [self addChild:loseLabel];
        
        //Button for getting back to menu
        NSString * retrymessage;
        retrymessage = @"Back to Menu";
        SKLabelNode *retryButton = [SKLabelNode labelNodeWithFontNamed:@"TimeNewRomanPSMT"];
        retryButton.text = retrymessage;
        retryButton.fontSize = 50;
        retryButton.position = CGPointMake(self.size.width/2, self.size.height/1.6);
        retryButton.name = @"Back to Menu";
        [self addChild:retryButton];
        
    }
    return self;
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    //Return to menu if menu button is pressed
    if ([node.name isEqualToString:@"Back to Menu"]) {
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        
        BHJXStartMenuScene * scene = [BHJXStartMenuScene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene transition: reveal];
    }
}



@end
