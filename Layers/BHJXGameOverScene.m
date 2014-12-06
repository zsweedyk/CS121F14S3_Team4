//
//  BHJXGameOverScene.m
//  Layers
//
//  Created by Jun Hong Park on 10/26/14.
//  Copyright (c) 2014 BHJX. All rights reserved.
//

#import "BHJXGameOverScene.h"
#import "BHJXStartMenuScene.h"
#import "BHJXLevel1Scene.h"
#import "BHJXLevel2Scene.h"
#import "BHJXLevel3Scene.h"

@implementation BHJXGameOverScene

int _level;



-(id)initWithSize:(CGSize)size level:(int)level {
    if (self = [super initWithSize:size]) {
        
        //Keep track of the level that you came from, so retry goes to the correct place
        _level = level;
        
        //You Lost!
        NSString *message = @"You Lost!";
        SKLabelNode *loseLabel = [SKLabelNode labelNodeWithFontNamed:@"TimesNewRomanPSMT"];
        loseLabel.text = message;
        loseLabel.fontSize = 50;
        loseLabel.position = CGPointMake(self.size.width/2, self.size.height/1.8);
        [self addChild:loseLabel];
        
      
        //Button for retrying previous level
        NSString * retryLevelmessage;
        retryLevelmessage = @"Retry Level?";
        SKLabelNode *retryLevelButton = [SKLabelNode labelNodeWithFontNamed:@"TimeNewRomanPSMT"];
        retryLevelButton.text = retryLevelmessage;
        retryLevelButton.fontSize = 50;
        retryLevelButton.position = CGPointMake(self.size.width/2, self.size.height/2);
        retryLevelButton.name = @"Retry Level?";
        [self addChild:retryLevelButton];
        
        //Button for getting back to menu
        NSString * retrymessage;
        retrymessage = @"Back to Menu";
        SKLabelNode *retryButton = [SKLabelNode labelNodeWithFontNamed:@"TimeNewRomanPSMT"];
        retryButton.text = retrymessage;
        retryButton.fontSize = 50;
        retryButton.position = CGPointMake(self.size.width/2, self.size.height/2.3);
         retryButton.name = @"Back to Menu";
        [self addChild:retryButton];

    }
    return self;
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];

    //On touch, return to menu if menu button is pressed, or last level if level button is pressed
    if ([node.name isEqualToString:@"Back to Menu"]) {
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        BHJXStartMenuScene * scene = [BHJXStartMenuScene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene transition: reveal];
    } else if ([node.name isEqualToString:@"Retry Level?"]) {
        [self retryLevel];
    }
}



// Retry level that you came from
- (void)retryLevel {
    if (_level == 1) {
        BHJXLevel1Scene * scene = [BHJXLevel1Scene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene];
    } else if (_level == 2) {
        BHJXLevel2Scene * scene = [BHJXLevel2Scene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene];
    } else if (_level == 3) {
        BHJXLevel3Scene * scene = [BHJXLevel3Scene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene];
    }
}


@end
