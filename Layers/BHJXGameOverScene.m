//
//  BHJXGameOverScene.m
//  Layers
//
//  Created by Jun Hong Park on 10/26/14.
//  Copyright (c) 2014 BHJX. All rights reserved.
//

#import "BHJXGameOverScene.h"
#import "BHJXStartMenuScene.h"

@implementation BHJXGameOverScene

-(id)initWithSize:(CGSize)size score:(int)score {
    if (self = [super initWithSize:size]) {
        //You Lost!
        NSString *message = @"You Lost!";
        SKLabelNode *loseLabel = [SKLabelNode labelNodeWithFontNamed:@"TimesNewRomanPSMT"];
        loseLabel.text = message;
        loseLabel.fontSize = 50;
        loseLabel.position = CGPointMake(self.size.width/2, self.size.height/1.8);
        [self addChild:loseLabel];
        
        //Label for the achieved score
        NSString *scoreString = [NSString stringWithFormat:@"Your score: %d", score];
        SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"TimesNewRomanPSMT"];
        scoreLabel.text = scoreString;
        scoreLabel.fontSize = 50;
        scoreLabel.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:scoreLabel];
      
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

    if ([node.name isEqualToString:@"Back to Menu"]) {
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
    
        BHJXStartMenuScene * scene = [BHJXStartMenuScene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene transition: reveal];
    }
}


@end
