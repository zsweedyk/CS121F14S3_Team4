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
    SKLabelNode *_authorLabel;
    SKLabelNode *_author1Label;
    SKLabelNode *_author2Label;
    SKLabelNode *_author3Label;
    SKLabelNode *_author4Label;
}



-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        //Load the button to go back to main menu
        _backToMenuLabel = [[SKLabelNode alloc] initWithFontNamed:@"Zapfino"];
        _backToMenuLabel.name = @"BackToMenuLabel";
        _backToMenuLabel.text = @"Back to Menu";
        _backToMenuLabel.fontColor = [SKColor whiteColor];
        _backToMenuLabel.fontSize = 25;
        _backToMenuLabel.position = CGPointMake(self.frame.size.width*0.50, self.frame.size.height*0.30);
        [self addChild:_backToMenuLabel];
        
        //Information of the game
        _authorLabel = [[SKLabelNode alloc] initWithFontNamed:@"Georgia"];
        _authorLabel.name = @"Information";
        _authorLabel.text = @"Developers:";
        _authorLabel.fontColor = [SKColor whiteColor];
        _authorLabel.fontSize = 20;
        _authorLabel.position = CGPointMake(self.frame.size.width*0.26, self.frame.size.height*0.75);
        [self addChild:_authorLabel];
        
        _author1Label = [[SKLabelNode alloc] initWithFontNamed:@"Georgia"];
        _author1Label.name = @"Information";
        _author1Label.text = @"Ben Leader, Hannah Long, John Park, Xiaotian Wang";
        _author1Label.fontColor = [SKColor whiteColor];
        _author1Label.fontSize = 20;
        _author1Label.position = CGPointMake(self.frame.size.width*0.50, self.frame.size.height*0.70);
        [self addChild:_author1Label];
        
        _author2Label = [[SKLabelNode alloc] initWithFontNamed:@"Georgia"];
        _author2Label.name = @"Information";
        _author2Label.text = @"Developed as part of CS121 at Harvey Mudd College";
        _author2Label.fontColor = [SKColor whiteColor];
        _author2Label.fontSize = 20;
        _author2Label.position = CGPointMake(self.frame.size.width*0.48, self.frame.size.height*0.60);
        [self addChild:_author2Label];
        
        _author3Label = [[SKLabelNode alloc] initWithFontNamed:@"Georgia"];
        _author3Label.name = @"Information";
        _author3Label.text = @"as part of the Games Network";
        _author3Label.fontColor = [SKColor whiteColor];
        _author3Label.fontSize = 20;
        _author3Label.position = CGPointMake(self.frame.size.width*0.36, self.frame.size.height*0.55);
        [self addChild:_author3Label];
        
        _author4Label = [[SKLabelNode alloc] initWithFontNamed:@"Georgia"];
        _author4Label.name = @"Information";
        _author4Label.text = @"funded by NSF Grant #1042472";
        _author4Label.fontColor = [SKColor whiteColor];
        _author4Label.fontSize = 20;
        _author4Label.position = CGPointMake(self.frame.size.width*0.37, self.frame.size.height*0.50);
        [self addChild:_author4Label];
        
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
            _backToMenuLabel.fontSize = 23;
            _backToMenuLabel.fontColor = [SKColor redColor];
        }];
        SKAction *wait = [SKAction waitForDuration:0.16];
        BHJXStartMenuScene *scene = [BHJXStartMenuScene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        SKAction *transit = [SKAction runBlock:^{
            [self.view presentScene:scene];
        }];
        
        SKAction *buttonSound = [SKAction playSoundFileNamed:@"010dj031.caf" waitForCompletion:YES];
        
        [self runAction:[SKAction sequence:@[modifyFont,buttonSound,wait,transit]]];
    }
}

@end
