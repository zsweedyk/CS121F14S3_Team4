//
//  BHJXStartMenuScene.m
//  Layers
//
//  Created by Jun Hong Park on 10/26/14.
//  Copyright (c) 2014 BHJX. All rights reserved.
//

#import "BHJXStartMenuScene.h"
#import "BHJXLevel2Scene.h"

@implementation BHJXStartMenuScene {
    SKSpriteNode *_background;
    SKLabelNode *_titleLabel;
    SKLabelNode *_adventureLabel;
}



-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        _background = [SKSpriteNode spriteNodeWithImageNamed:@"Startmenubackground.png"];
        _background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self addChild:_background];
        
        _titleLabel = [[SKLabelNode alloc] initWithFontNamed:@"Zapfino"];
        _titleLabel.name = @"titleLabel";
        _titleLabel.text = @"LAYERS";
        _titleLabel.fontColor = [SKColor redColor];
        _titleLabel.fontSize = 40;
        _titleLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height*0.8);
        [self addChild:_titleLabel];
        
        _adventureLabel = [[SKLabelNode alloc] initWithFontNamed:@"Zapfino"];
        _adventureLabel.name = @"AdventureLabel";
        _adventureLabel.text = @"- Adventure Mode";
        _adventureLabel.fontColor = [SKColor blackColor];
        _adventureLabel.fontSize = 30;
        _adventureLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height*0.5);
        [self addChild:_adventureLabel];
        
        
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"AdventureLabel"]) {
        SKTransition *reveal = [SKTransition fadeWithDuration:3];
        
        BHJXLevel2Scene *scene = [BHJXLevel2Scene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene transition:reveal];
                          
    }

}

@end
