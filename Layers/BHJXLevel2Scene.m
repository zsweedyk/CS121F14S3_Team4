//
//  BHJXLevel2Scene.m
//  Layers
//
//  Created by Jun Hong Park on 11/9/14.
//  Copyright (c) 2014 BHJX. All rights reserved.
//

#import "BHJXLevel2Scene.h"
#import "BHJXGameOverScene.h"
#import "BHJXIntroLevel3.h"
@import AVFoundation;

#define kNumBoulders 10
#define kNumImages 2

static NSString* playerCategoryName = @"player";

@implementation BHJXLevel2Scene
{
    SKSpriteNode *_player;
    SKSpriteNode *_background1;
    SKSpriteNode *_background2;
    SKLabelNode *_livesLabel;
    SKLabelNode *_scoreLabel;
    
    
    NSArray *_playerFlickerFrames;
    NSMutableArray *_boulders;
    int _nextBoulder;
    double _nextBoulderSpawn;
    
    int _lives;
    int _distance;
    
    bool _gameOver;
    
    SKScene *_gameOverScene;
    AVAudioPlayer *_backgroundAudioPlayer;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        //Setup flickering
        
        NSMutableArray *playerFlickerFrames = [NSMutableArray array];
        SKTextureAtlas *playerAnimatedAtlas = [SKTextureAtlas atlasNamed:@"Player"];

        for (int i=1; i <= kNumImages; i++){
            NSString *textureName = [NSString stringWithFormat:@"Player%d", i];
            SKTexture *temp = [playerAnimatedAtlas textureNamed:textureName];
            [playerFlickerFrames addObject:temp];
        }
        _playerFlickerFrames = playerFlickerFrames;

        
        //Initialize scrolling background
        _background1 = [SKSpriteNode spriteNodeWithImageNamed:@"mantleBackground.png"];
        _background1.anchorPoint = CGPointZero;
        _background1.position = CGPointMake(0, 0);
        [self addChild:_background1];
        
        _background2 = [SKSpriteNode spriteNodeWithImageNamed:@"mantleBackground.png"];
        _background2.anchorPoint = CGPointZero;
        _background2.position = CGPointMake(0, _background2.size.height-1);
        [self addChild:_background2];
        
        
        
        //Create player and place at bottom of screen
        
        SKTexture *temp = _playerFlickerFrames[0];
        
        _player = [SKSpriteNode spriteNodeWithTexture:temp];
        _player.name = playerCategoryName;
        _player.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*1.84);
        [self addChild:_player];
        _player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_player.frame.size];
        _player.physicsBody.restitution = 0.1f;
        _player.physicsBody.friction = 0.4f;
        // make physicsBody static
        _player.physicsBody.dynamic = NO;
        
        //Setup the boulders
        _boulders = [[NSMutableArray alloc] initWithCapacity:kNumBoulders];
        for (int i = 0; i < kNumBoulders; ++i) {
            SKSpriteNode *boulder = [SKSpriteNode spriteNodeWithImageNamed:@"Current.png"];
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
        _livesLabel.position = CGPointMake(self.frame.size.width/9, self.frame.size.height * 0.05);
        _livesLabel.fontColor = [SKColor redColor];
        [self addChild:_livesLabel];
        
        //Setup the score label
        _scoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
        _scoreLabel.name = @"scoreLabel";
        _scoreLabel.text = [NSString stringWithFormat:@"Distance to Baron von Quack: %d", _distance];
        _scoreLabel.scale = 0.9;
        _scoreLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.05);
        _scoreLabel.fontColor = [SKColor redColor];
        [self addChild:_scoreLabel];
        
        //Play the background music
        [self startBackgroundMusic];
        
        //Start the game
        [self startTheGame];
    }
    return self;
}

- (void)startTheGame
{
    _lives = 5;
    _distance = 1500;
    _player.hidden = NO;
    _player.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*1.84);
    [self flickering];
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    /* Called when a touch begins */
    self.isFingerOnDuck = YES;
}


-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    
    if (self.isFingerOnDuck) {
        //Get touch location
        UITouch* touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInNode:self];
        CGPoint previousLocation = [touch previousLocationInNode:self];
        //Get node for player
        SKSpriteNode* duck = (SKSpriteNode*)[self childNodeWithName: playerCategoryName];
        //Calculate new position along x for player
        int playerX = duck.position.x + (touchLocation.x - previousLocation.x);
        //Limit x so that the player will not leave the screen to left or right
        playerX = MAX(playerX, duck.size.width/2);
        playerX = MIN(playerX, self.size.width - duck.size.width/2);
        //Update position of player
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
    _background1.position = CGPointMake(_background1.position.x, _background1.position.y+4);
    _background2.position = CGPointMake(_background2.position.x, _background2.position.y+4);
    if (_background1.position.y > _background1.size.height){
        _background1.position = CGPointMake(_background1.position.x, _background2.position.y - _background2.size.height);
    }
    if (_background2.position.y > _background2.size.height) {
        _background2.position = CGPointMake(_background2.position.x, _background1.position.y - _background1.size.height);
    }
    
    //Falling boulders
    double curTime = CACurrentMediaTime();
    if (curTime > _nextBoulderSpawn) {
        float randSecs = [self randomValueBetween:0.20 andValue:1.0];
        _nextBoulderSpawn = randSecs + curTime;
        
        float randX = [self randomValueBetween:0.0 andValue:self.frame.size.width];
        float randDuration = [self randomValueBetween:1.0 andValue:6.0];
        
        SKSpriteNode *boulder = [_boulders objectAtIndex:_nextBoulder];
        _nextBoulder++;
        
        if (_nextBoulder >= _boulders.count) {
            _nextBoulder = 0;
        }
        
        [boulder removeAllActions];
        boulder.position = CGPointMake(randX, -self.frame.size.height-boulder.size.height/2);
        boulder.hidden = NO;
        
        CGPoint location = CGPointMake(randX, self.frame.size.height);
        
        SKAction *moveAction = [SKAction moveTo:location duration:randDuration];
        SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
            //NSLog(@"Animation Completed");
            boulder.hidden = YES;
        }];
        
        SKAction *moveBoulderActionWithDone = [SKAction sequence:@[moveAction, doneAction ]];
        [boulder runAction:moveBoulderActionWithDone withKey:@"boulderMoving"];
    }
    
    //Update lives and score labels
    _livesLabel.text = [NSString stringWithFormat:@"Lives: %d", _lives];
    _scoreLabel.text = [NSString stringWithFormat:@"Distance to Core: %d", _distance];
    
    //collision detection
    if (!_gameOver) {
        //increment score
        _distance--;
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
                SKAction *hitBoulderSound = [SKAction playSoundFileNamed:@"explosion_small.caf" waitForCompletion:YES];
                SKAction *moveBoulderActionWithDone = [SKAction sequence:@[hitBoulderSound]];
                [boulder runAction:moveBoulderActionWithDone withKey:@"hitBoulder"];
                NSLog(@"a hit!");
                _lives--;
            }
            
            if (_lives <= 0) {
                NSLog(@"you lose");
                [self endTheScene:YES];
            }
            else if (_distance <= 0) {
                [self endTheScene:NO];
            }
        }
    }
}

- (void)endTheScene:(BOOL)didLose {
    if (_gameOver) {
        return;
    }
    
    [self removeAllActions];
    _player.hidden = YES;
    _gameOver = YES;
    
    if (didLose)
    {
        _gameOverScene = [[BHJXGameOverScene alloc] initWithSize:self.size score:_distance];
        [self.view presentScene:_gameOverScene];
    } else {
        BHJXIntroLevel3 * scene = [BHJXIntroLevel3 sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene];
    }
}

- (void)startBackgroundMusic
{
    NSError *err;
    NSURL *file = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Layer.caf" ofType:nil]];
    _backgroundAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:&err];
    if (err) {
        NSLog(@"error in audio play %@",[err userInfo]);
        return;
    }
    [_backgroundAudioPlayer prepareToPlay];
    
    // this will play the music infinitely
    _backgroundAudioPlayer.numberOfLoops = -1;
    [_backgroundAudioPlayer setVolume:1.0];
    [_backgroundAudioPlayer play];
}

-(void)flickering
{
    //This is our general runAction method to make our player flicker.
    [_player runAction:[SKAction repeatActionForever:
                        [SKAction animateWithTextures:_playerFlickerFrames
                                         timePerFrame:0.1f
                                               resize:NO
                                              restore:YES]] withKey:@"flickeringInPlacePlayer"];
    return;
}


@end
