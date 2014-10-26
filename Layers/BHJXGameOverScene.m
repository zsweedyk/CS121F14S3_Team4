//
//  BHJXGameOverScene.m
//  Layers
//
//  Created by Jun Hong Park on 10/26/14.
//  Copyright (c) 2014 BHJX. All rights reserved.
//

#import "BHJXGameOverScene.h"

@implementation BHJXGameOverScene

-(id)initWithSize:(CGSize)size score:(int)score {
    if (self = [super initWithSize:size]) {
        //You Lost!
        NSString *message = @"You Lost!";
        SKLabelNode *loseLabel = [SKLabelNode labelNodeWithFontNamed: @"TimesNewRomanPSMT"];
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
        
        
        SKLabelNode *startMenuLabel;
        
    }
    return self;
}

@end
