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
        _slide1 = [SKSpriteNode spriteNodeWithImageNamed:@"Intro1Scene1.png"];
        _slide1.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self addChild:_slide1];
        
        //Create subsequent slides, but keep them hidden
        _slide2 = [SKSpriteNode spriteNodeWithImageNamed:@"Intro1Scene2.png"];
        _slide2.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self addChild:_slide2];
        _slide3 = [SKSpriteNode spriteNodeWithImageNamed:@"Intro1Scene3.png"];
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
    
    if ([node.name isEqualToString:@"Continue"]) {
        
        if (_countTouches == 0) {
            _slide1.hidden = YES;
            _slide2.hidden = NO;
            _countTouches++;
        } else if (_countTouches == 1) {
            _slide2.hidden = YES;
            _slide3.hidden = NO;
            _countTouches++;
        } else {
            SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
            
            BHJXVictoryScene * scene = [BHJXVictoryScene sceneWithSize:self.view.bounds.size];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            [self.view presentScene:scene transition: reveal];
        }
    }
}

@end
