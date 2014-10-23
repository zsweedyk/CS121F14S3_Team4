//
//  BHJXMyScene.m
//  Layers
//
//  Created by Jun Hong Park on 10/12/14.
//  Copyright (c) 2014 BHJX. All rights reserved.
//

#import "BHJXMyScene.h"

#define kNumBoulders 10
#define kNumLavaBoulders 10

typedef enum {
    kEndReasonLose
} EndReason;

static NSString* playerCategoryName = @"player";

@implementation BHJXMyScene
{
    SKSpriteNode *_player;
    SKSpriteNode *_boudler;
    SKSpriteNode *_lava;
    SKSpriteNode *_background1;
    SKSpriteNode *_background2;
    SKLabelNode *_livesLabel;
  
    NSMutableArray *_boulders;
    int _nextBoulder;
    double _nextBoulderSpawn;
    
    int _lives;
    
    bool _gameOver;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        //Initialize scrolling background
        _background1 = [SKSpriteNode spriteNodeWithImageNamed:@"Volcanobackground.png"];
        _background1.anchorPoint = CGPointZero;
        _background1.position = CGPointMake(0, 0);
        [self addChild:_background1];
        
        _background2 = [SKSpriteNode spriteNodeWithImageNamed:@"Volcanobackground.png"];
        _background2.anchorPoint = CGPointZero;
        _background2.position = CGPointMake(0, _background2.size.height-1);
        [self addChild:_background2];
        
        
        
        //2
        NSLog(@"SKScene:initWithSize %f x %f",size.width,size.height);
        
        //3
        self.backgroundColor = [SKColor blackColor];
        
#pragma mark - TBD - Game Backgrounds
        
#pragma mark - Setup Sprite for the ship
        //Create space sprite, setup position on left edge centered on the screen, and add to Scene
        //4
        _player = [[SKSpriteNode alloc] initWithImageNamed:@"Player.png"];
        _player.name = playerCategoryName;
        _player.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*0.1);
        [self addChild:_player];
        _player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_player.frame.size];
        _player.physicsBody.restitution = 0.1f;
        _player.physicsBody.friction = 0.4f;
        // make physicsBody static
        _player.physicsBody.dynamic = NO;
        
#pragma mark - TBD - Setup the boulders
        _boulders = [[NSMutableArray alloc] initWithCapacity:kNumBoulders];
        for (int i = 0; i < kNumBoulders; ++i) {
            SKSpriteNode *boulder = [SKSpriteNode spriteNodeWithImageNamed:@"Boulder.png"];
            boulder.hidden = YES;
            [boulder setXScale:0.5];
            [boulder setYScale:0.5];
            [_boulders addObject:boulder];
            [self addChild:boulder];
        }
        
        _nextBoulderSpawn = 0;
        
        for (SKSpriteNode *boulder in _boulders) {
            boulder.hidden = YES;
        }
        
//Setup the lives label
        _livesLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
        _livesLabel.name = @"livesLabel";
        _livesLabel.text = [NSString stringWithFormat:@"%d", _lives];
        _livesLabel.scale = 0.9;
        _livesLabel.position = CGPointMake(self.frame.size.width/9, self.frame.size.height * 0.9);
        _livesLabel.fontColor = [SKColor redColor];
        [self addChild:_livesLabel];
        
#pragma mark - TBD - Start the actual game
        [self startTheGame];
    }
    return self;
}

- (void)startTheGame
{
    _lives = 5;
    _player.hidden = NO;
    _player.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*0.1);
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    /* Called when a touch begins */
    self.isFingerOnDuck = YES;
}


-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    // 1 Check whether user tapped paddle
    if (self.isFingerOnDuck) {
        // 2 Get touch location
        UITouch* touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInNode:self];
        CGPoint previousLocation = [touch previousLocationInNode:self];
        // 3 Get node for paddle
        SKSpriteNode* duck = (SKSpriteNode*)[self childNodeWithName: playerCategoryName];
        // 4 Calculate new position along x for paddle
        int playerX = duck.position.x + (touchLocation.x - previousLocation.x);
        // 5 Limit x so that the paddle will not leave the screen to left or right
        playerX = MAX(playerX, duck.size.width/2);
        playerX = MIN(playerX, self.size.width - duck.size.width/2);
        // 6 Update position of paddle
        duck.position = CGPointMake(playerX, duck.position.y);
    }
}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    self.isFingerOnDuck = NO;
}

- (float)randomValueBetween:(float)low andValue:(float)high {
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}

-(void)update:(NSTimeInterval)currentTime {
    //Set the background to be scrolling
    _background1.position = CGPointMake(_background1.position.x, _background1.position.y-4);
    _background2.position = CGPointMake(_background2.position.x, _background2.position.y-4);
    if (_background1.position.y < -_background1.size.height){
        _background1.position = CGPointMake(_background1.position.x, _background2.position.y + _background2.size.height);
    }
    if (_background2.position.y < -_background2.size.height) {
        _background2.position = CGPointMake(_background2.position.x, _background1.position.y + _background1.size.height);
    }
    
    //Falling boulders
    double curTime = CACurrentMediaTime();
    if (curTime > _nextBoulderSpawn) {
        float randSecs = [self randomValueBetween:0.20 andValue:1.0];
        _nextBoulderSpawn = randSecs + curTime;
        
        float randX = [self randomValueBetween:0.0 andValue:self.frame.size.width];
        float randDuration = [self randomValueBetween:2.0 andValue:10.0];
        
        SKSpriteNode *boulder = [_boulders objectAtIndex:_nextBoulder];
        _nextBoulder++;
        
        if (_nextBoulder >= _boulders.count) {
            _nextBoulder = 0;
        }
        
        [boulder removeAllActions];
        boulder.position = CGPointMake(randX, self.frame.size.height+boulder.size.height/2);
        boulder.hidden = NO;
        
        CGPoint location = CGPointMake(randX, -self.frame.size.height-boulder.size.height);
        
        SKAction *moveAction = [SKAction moveTo:location duration:randDuration];
        SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
            //NSLog(@"Animation Completed");
            boulder.hidden = YES;
        }];
        
        SKAction *moveBoulderActionWithDone = [SKAction sequence:@[moveAction, doneAction ]];
        [boulder runAction:moveBoulderActionWithDone withKey:@"boulderMoving"];
    }
    
    //Update lives label
    _livesLabel.text = [NSString stringWithFormat:@"Lives: %d", _lives];
    
    //collision detection
    if (!_gameOver) {
        for (SKSpriteNode *boulder in _boulders) {
            if (boulder.hidden) {
                continue;
            }
            if ([_player intersectsNode:boulder]) {
                boulder.hidden = YES;
                SKAction *blink = [SKAction sequence:@[[SKAction fadeOutWithDuration:0.1],
                                                       [SKAction fadeInWithDuration:0.1]]];
                SKAction *blinkForTime = [SKAction repeatAction:blink count:4];
                [_player runAction:blinkForTime];
                NSLog(@"a hit!");
                _lives--;
            }
        }
        
        if (_lives <= 0) {
            NSLog(@"you lose");
            [self endTheScene:kEndReasonLose];
        }
    }
}

- (void)endTheScene:(EndReason)endReason {
    if (_gameOver) {
        return;
    }
    
    [self removeAllActions];
    _player.hidden = YES;
    _gameOver = YES;
    
    NSString *message;
    if (endReason == kEndReasonLose)
    {
        message = @"You lost!";
    }
    
    SKLabelNode *loseLabel;
    loseLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    loseLabel.name = @"loseLabel";
    loseLabel.text = @"YOU LOST.";
    loseLabel.scale = 0.9;
    loseLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.4);
    loseLabel.fontColor = [SKColor redColor];
    [self addChild:loseLabel];
    
    SKAction *labelScaleAction = [SKAction scaleTo:1.0 duration:0.5];
    
    [loseLabel runAction:labelScaleAction];
}


@end
