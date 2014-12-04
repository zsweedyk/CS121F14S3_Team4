//
//  BHJXEndingCutscene.m
//  Layers
//
//  Created by Ben Leader on 11/16/14.
//  Copyright (c) 2014 BHJX. All rights reserved.
//

#import "BHJXEndingCutscene.h"
#import "BHJXVictoryScene.h"

@implementation BHJXEndingCutscene

SKLabelNode *_continueButton;
SKSpriteNode *_slide1;
SKSpriteNode *_slide2;
SKSpriteNode *_slide3;
int _countTouches;



-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        //Initialize touch counter to 0
        _countTouches = 0;
        
        //Present first slide
        _slide1 = [SKSpriteNode spriteNodeWithImageNamed:@"EndScene1.png"];
        _slide1.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self addChild:_slide1];
        
        //Create subsequent slides, but keep them hidden
        _slide2 = [SKSpriteNode spriteNodeWithImageNamed:@"EndScene2.png"];
        _slide2.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self addChild:_slide2];
        _slide3 = [SKSpriteNode spriteNodeWithImageNamed:@"EndScene3.png"];
        _slide3.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self addChild:_slide3];
        
        _slide2.hidden = YES;
        _slide3.hidden = YES;
        
        //Button for continuing slide show
        
        _continueButton = [SKLabelNode labelNodeWithFontNamed:@"TimeNewRomanPSMT"];
        _continueButton.text = @"Continue";
        _continueButton.fontSize = 50;
        _continueButton.fontColor = [UIColor blueColor];
        _continueButton.position = CGPointMake(self.size.width/2, self.size.height/15);
        _continueButton.name = @"Continue";
        [self addChild:_continueButton];
        
    }
    return self;
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    //Show and hide the slides in order
    if ([node.name isEqualToString:@"Continue"]) {
        
        if (_countTouches == 0) {
            [self transit:_slide1 and:_slide2];
        } else if (_countTouches == 1) {
            [self transit:_slide2 and:_slide3];
        } else {
            //Start the next level
            SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
            
            BHJXVictoryScene * scene = [BHJXVictoryScene sceneWithSize:self.view.bounds.size];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            [self.view presentScene:scene transition: reveal];
        }
    }
}



// a customizable SKbutton simulation for highlight event
- (void)transit:(SKSpriteNode *)silde1 and:(SKSpriteNode *)silde2 {
    SKAction *changeFontSize = [SKAction runBlock:^{
        _continueButton.fontSize = 48;
    }];
    SKAction *wait = [SKAction waitForDuration:0.16];
    SKAction *transitScene = [SKAction runBlock:^{
        silde1.hidden = YES;
        silde2.hidden = NO;
        _countTouches++;
        _continueButton.fontSize = 50;
    }];
    [self runAction:[SKAction sequence:@[changeFontSize,wait,transitScene]]];
}

@end
