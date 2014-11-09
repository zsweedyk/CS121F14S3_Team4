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
    SKLabelNode *_survival1Label;
}



-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        _background = [SKSpriteNode spriteNodeWithImageNamed:@"Startmenubackground.png"];
        _background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self addChild:_background];
        
        _titleLabel = [[SKLabelNode alloc] initWithFontNamed:@"TimesNewRomanPSMT"];
        _titleLabel.name = @"titleLabel";
        _titleLabel.text = @"Layers";
        _titleLabel.fontColor = [SKColor redColor];
        _titleLabel.position = CGPointMake(self.frame.size.width/4, self.frame.size.height*0.9);
        [self addChild:_titleLabel];
        
        _survival1Label = [[SKLabelNode alloc] initWithFontNamed:@"TimesNewRomanPSMT"];
        _survival1Label.name = @"survival1Label";
        _survival1Label.text = @"Survival Mode";
        _survival1Label.fontColor = [SKColor blackColor];
        _survival1Label.position = CGPointMake(self.frame.size.width/4, self.frame.size.height*0.8);
        [self addChild:_survival1Label];
        
        
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"survival1Label"]) {
        SKTransition *reveal = [SKTransition fadeWithDuration:3];
        
        BHJXIntroLevel1 *scene = [BHJXIntroLevel1 sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene transition:reveal];
                          
    }

}

@end
