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

static NSString* playerCategoryName = @"player";

@implementation BHJXMyScene
{
    SKSpriteNode *_player;
    SKSpriteNode *_boudler;
    SKSpriteNode *_lava;
    SKSpriteNode *_background1;
    SKSpriteNode *_background2;
    
    NSMutableArray *_boulders;
    int _nextBoulder;
    double _nextBoulderSpawn;
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
        
#pragma mark - TBD - Setup the lava boulders
        
#pragma mark - TBD - Setup the stars to appear as particles
        
#pragma mark - TBD - Start the actual game
        
    }
    return self;
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
        int paddleX = duck.position.x + (touchLocation.x - previousLocation.x);
        // 5 Limit x so that the paddle will not leave the screen to left or right
        paddleX = MAX(paddleX, duck.size.width/2);
        paddleX = MIN(paddleX, self.size.width - duck.size.width/2);
        // 6 Update position of paddle
        duck.position = CGPointMake(paddleX, duck.position.y);
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
        
        SKSpriteNode *asteroid = [_boulders objectAtIndex:_nextBoulder];
        _nextBoulder++;
        
        if (_nextBoulder >= _boulders.count) {
            _nextBoulder = 0;
        }
        
        [asteroid removeAllActions];
        asteroid.position = CGPointMake(randX, self.frame.size.height+asteroid.size.height/2);
        asteroid.hidden = NO;
        
        CGPoint location = CGPointMake(randX, -self.frame.size.height-asteroid.size.height);
        
        SKAction *moveAction = [SKAction moveTo:location duration:randDuration];
        SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
            //NSLog(@"Animation Completed");
            asteroid.hidden = YES;
        }];
        
        SKAction *moveAsteroidActionWithDone = [SKAction sequence:@[moveAction, doneAction ]];
        [asteroid runAction:moveAsteroidActionWithDone withKey:@"asteroidMoving"];
    }
}

@end
