//
//  BHJXInfoScene.m
//  Layers
//
//  Created by 王小天 on 14/12/7.
//  Copyright (c) 2014年 BHJX. All rights reserved.
//

#import "BHJXInfoScene.h"
#import "BHJXStartMenuScene.h"

@implementation BHJXInfoScene {
    SKLabelNode *_backToMenuLabel;
}



-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        //Load the button to go back to main menu
        _backToMenuLabel = [[SKLabelNode alloc] initWithFontNamed:@"Zapfino"];
        _backToMenuLabel.name = @"BackToMenuLabel";
        _backToMenuLabel.text = @"Back to Menue";
        _backToMenuLabel.fontColor = [SKColor whiteColor];
        _backToMenuLabel.fontSize = 25;
        _backToMenuLabel.position = CGPointMake(self.frame.size.width*0.50, self.frame.size.height*0.65);
        [self addChild:_backToMenuLabel];
        
    }
    return self;
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    //Back to the main menue when the player presses the button
    if ([node.name isEqualToString:@"BackToMenuLabel"]) {
        SKAction *modifyFont = [SKAction runBlock:^{
            _backToMenuLabel.fontSize = 22;
            _backToMenuLabel.fontColor = [SKColor redColor];
        }];
        SKAction *wait = [SKAction waitForDuration:0.16];
        BHJXStartMenuScene *scene = [BHJXStartMenuScene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        SKAction *transit = [SKAction runBlock:^{
            [self.view presentScene:scene];
        }];
        [self runAction:[SKAction sequence:@[modifyFont,wait,transit]]];
    }
}

@end
