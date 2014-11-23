//
//  BHJXIntroLevel2.m
//  Layers
//
//  Created by Ben Leader on 11/16/14.
//  Copyright (c) 2014 BHJX. All rights reserved.
//

#import "BHJXIntroLevel2.h"
#import "BHJXLevel2Scene.h"

@implementation BHJXIntroLevel2

SKLabelNode *_continueButton;
SKSpriteNode *_slide1;
SKSpriteNode *_slide2;
SKSpriteNode *_slide3;
SKSpriteNode *_slide4;
SKSpriteNode *_slide5;

int _countTouches;



-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        //Initialize touch counter to 0
        _countTouches = 0;
        
        //Present first slide
        _slide1 = [SKSpriteNode spriteNodeWithImageNamed:@"Intro2Scene1.png"];
        _slide1.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self addChild:_slide1];
        
        //Create subsequent slides, but keep them hidden
        _slide2 = [SKSpriteNode spriteNodeWithImageNamed:@"Intro2Scene2.png"];
        _slide2.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self addChild:_slide2];
        _slide3 = [SKSpriteNode spriteNodeWithImageNamed:@"Intro2Scene3.png"];
        _slide3.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self addChild:_slide3];
        _slide4 = [SKSpriteNode spriteNodeWithImageNamed:@"Intro2Scene4.png"];
        _slide4.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self addChild:_slide4];
        _slide5 = [SKSpriteNode spriteNodeWithImageNamed:@"Intro2Scene5.png"];
        _slide5.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self addChild:_slide5];
        
        _slide2.hidden = YES;
        _slide3.hidden = YES;
        _slide4.hidden = YES;
        _slide5.hidden = YES;
        
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
        
        //Show and hide the slides in order
        if (_countTouches == 0) {
            _slide1.hidden = YES;
            _slide2.hidden = NO;
            _countTouches++;
        } else if (_countTouches == 1) {
            _slide2.hidden = YES;
            _slide3.hidden = NO;
            _countTouches++;
        } else if (_countTouches == 2) {
            _slide3.hidden = YES;
            _slide4.hidden = NO;
            _countTouches++;
        } else if (_countTouches == 3) {
            _slide4.hidden = YES;
            _slide5.hidden = NO;
            _countTouches++;
            
            //change position of continue button so players don't accidentally start next level
            _continueButton.position = CGPointMake(self.size.width/2, self.size.height/3);
            _continueButton.text = @"Start Level?";
        } else {
            //Start the next level
            SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
            
            BHJXLevel2Scene * scene = [BHJXLevel2Scene sceneWithSize:self.view.bounds.size];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            [self.view presentScene:scene transition: reveal];
        }
    }
}


@end
