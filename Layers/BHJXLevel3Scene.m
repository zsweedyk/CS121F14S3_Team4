//
//  BHJXLevel3Scene.m
//  Layers
//
//  Created by 王小天 on 14/11/11.
//  Copyright (c) 2014年 BHJX. All rights reserved.
//

#import "BHJXLevel3Scene.h"
#import "BHJXGameOverScene.h"
#import "BHJXEndingCutscene.h"
@import AVFoundation;

//Boulder and laser array sizes
#define kNumBoulders 10
#define kNumLasers 5
#define kNumImages 2


static NSString* playerCategoryName = @"player";

@implementation BHJXLevel3Scene
{
    SKSpriteNode *_player;
    SKSpriteNode *_boulder1;
    SKSpriteNode *_boulder2;
    SKSpriteNode *_background;
    SKSpriteNode *_evilDuck;
    
    SKLabelNode *_livesLabel;
    SKLabelNode *_evilDuckLivesLabel;
    SKLabelNode *_scoreLabel;
    
    NSArray *_playerFlickerFrames;

    NSMutableArray *_boulders1;
    NSMutableArray *_boulders2;
    NSMutableArray *_playerLasers;

    int _nextBoulder1;
    int _nextBoulder2;
    int _nextPlayerLaser;
    int fireAtZero;

    double _nextBoulderSpawn1;
    double _nextBoulderSpawn2;

    int _lives;
    int _evilDuckLives;
    int _invulnerability;

    bool _gameOver;
    bool _finishBoss;
    bool canShoot;

    SKScene *_gameOverScene;
    SKScene *_victoryScene;
    AVAudioPlayer *_backgroundAudioPlayer;
}



-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        [self initFlickering];
        [self initBackground];
        [self initPlayer];
        [self initEvilDuck];
        [self initBoulders];
        [self initLasers];
        [self initLabels];
        [self startBackgroundMusic];
      
        [self startTheGame];
    }
    return self;
}



- (void)startTheGame
{
    //Initialize state of player and boss
    _lives = 5;
    _evilDuckLives = 10;
    _invulnerability = 0;
    _player.hidden = NO;
    _player.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*0.1);
    for (SKSpriteNode *laser in _playerLasers) {
        laser.hidden = YES;
    }
    [self flickering];
}



-(void)update:(NSTimeInterval)currentTime {
    
    [self boulderSpawn];
    [self updateLabels];
    
    // Duck will get closer to being able to fire if it can't
    if (fireAtZero > 0){
        fireAtZero--;
    }
    
    //Only do collision detection if the level is not over
    if (!_gameOver) {
        [self playerCollisionDetection];
        [self evilDuckCollisionDetection];
        [self evilDuckMovement];
    }
    
    //Multiple explosions at the end of game
    if (_finishBoss == YES) {
        if (_invulnerability % 5 == 0) {
            SKAction *hitLazerSound = [SKAction playSoundFileNamed:@"explosion_large.caf" waitForCompletion:YES];
            SKAction *moveLazerActionWithDone = [SKAction sequence:@[hitLazerSound]];
            [self runAction:moveLazerActionWithDone withKey:@"hitBoulder"];
            [self addExplosion:_evilDuck.position];
        }
        _invulnerability--;
    }
}



-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    /* Called when a touch begins */
    self.isFingerOnDuck = YES;
  
    //Only fire a laser if the cooldown period is over
    if (fireAtZero == 0 && canShoot){
        SKSpriteNode *playerLaser = [_playerLasers objectAtIndex:_nextPlayerLaser];
        _nextPlayerLaser++;
        if (_nextPlayerLaser >= _playerLasers.count) {
            _nextPlayerLaser = 0;
        }
        
        //Fire the laser from the position the player is currently in
        playerLaser.position = CGPointMake(_player.position.x,_player.position.y);
        playerLaser.hidden = NO;
        [playerLaser removeAllActions];
        
        //Start laser moving upward
        CGPoint location = CGPointMake(_player.position.x, self.frame.size.height);
        SKAction *laserMoveAction = [SKAction moveTo:location duration:0.5];
        
        //Hide the laser when it has reached the top
        SKAction *laserDoneAction = [SKAction runBlock:(dispatch_block_t)^() {
            playerLaser.hidden = YES;
        }];
        
        //Create and run the laser action
        SKAction *moveLaserActionWithDone = [SKAction sequence:@[laserMoveAction,laserDoneAction]];
        [playerLaser runAction:moveLaserActionWithDone withKey:@"laserFired"];
        
        //Player can't fire for 20 updates (cooldown period)
        fireAtZero = 20;
    }
    
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


//Generate a random value
- (float)randomValueBetween:(float)low andValue:(float)high {
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}



- (void)addExplosion:(CGPoint)position {
    //Add explosion
    NSString *explosionPath = [[NSBundle mainBundle] pathForResource:@"explosion" ofType:@"sks"];
    SKEmitterNode *explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:explosionPath];
  
    explosion.position = position;
    [self addChild:explosion];
  
    SKAction *removeExplosion = [SKAction sequence:@[[SKAction waitForDuration:1.5],
                                                     [SKAction removeFromParent]]];
  
    [explosion runAction:removeExplosion];
}



- (void)endTheScene:(BOOL)didLose {
    
    if (_gameOver) {
        return;
    }

    [self removeAllActions];
    _player.hidden = YES;
    _gameOver = YES;
  
    //Load game over scene if player lost, or ending cutscene if player won
    if (didLose) {
        _gameOverScene = [[BHJXGameOverScene alloc] initWithSize:self.size level:3];
        [self.view presentScene:_gameOverScene];
    } else {
        _victoryScene = [[BHJXEndingCutscene alloc] initWithSize:self.size];
        [self.view presentScene:_victoryScene];
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



- (void)flickering
{
    //This is our general runAction method to make our player flicker.
    [_player runAction:[SKAction repeatActionForever:
                        [SKAction animateWithTextures:_playerFlickerFrames
                                         timePerFrame:0.1f
                                               resize:NO
                                              restore:YES]] withKey:@"flickeringInPlacePlayer"];
    return;
}



- (void)initFlickering {
    //Setup flickering
    NSMutableArray *playerFlickerFrames = [NSMutableArray array];
    SKTextureAtlas *playerAnimatedAtlas = [SKTextureAtlas atlasNamed:@"Player"];
    
    for (int i=1; i <= kNumImages; i++){
        NSString *textureName = [NSString stringWithFormat:@"Player%d", i];
        SKTexture *temp = [playerAnimatedAtlas textureNamed:textureName];
        [playerFlickerFrames addObject:temp];
    }
    _playerFlickerFrames = playerFlickerFrames;
}



- (void)initBackground {
    //Initialize background
    _background = [SKSpriteNode spriteNodeWithImageNamed:@"coreBackground.png"];
    _background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:_background];
}



- (void)initPlayer {
    //Create player and place at bottom of screen
    SKTexture *temp = _playerFlickerFrames[0];
    
    _player = [SKSpriteNode spriteNodeWithTexture:temp];
    _player.name = playerCategoryName;
    _player.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*0.1);
    [self addChild:_player];
    _player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_player.frame.size];
    _player.physicsBody.restitution = 0.1f;
    _player.physicsBody.friction = 0.4f;
    // make physicsBody static
    _player.physicsBody.dynamic = NO;
}



- (void)initEvilDuck {
    //Create evil duck (boss) and place at top of screen
    _evilDuck = [[SKSpriteNode alloc] initWithImageNamed:@"EvilDuck.png"];
    _evilDuck.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*1.7);
    [self addChild:_evilDuck];
    _evilDuck.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_evilDuck.frame.size];
    _evilDuck.physicsBody.restitution = 0.1f;
    _evilDuck.physicsBody.friction = 0.4f;
    _finishBoss = NO;
    // make physicsBody static
    _evilDuck.physicsBody.dynamic = NO;
}



- (void)initBoulders {
    //Setup the boulders for left hand
    _boulders1 = [[NSMutableArray alloc] initWithCapacity:kNumBoulders];
    for (int i = 0; i < kNumBoulders; ++i) {
        SKSpriteNode *boulder1 = [SKSpriteNode spriteNodeWithImageNamed:@"coreChunk.png"];
        boulder1.hidden = YES;
        [boulder1 setXScale:0.5];
        [boulder1 setYScale:0.5];
        [_boulders1 addObject:boulder1];
        [self addChild:boulder1];
    }
    
    //Setup the boulder for right hand
    _boulders2 = [[NSMutableArray alloc] initWithCapacity:kNumBoulders];
    for (int i = 0; i < kNumBoulders; ++i) {
        SKSpriteNode *boulder2 = [SKSpriteNode spriteNodeWithImageNamed:@"coreChunk.png"];
        boulder2.hidden = YES;
        [boulder2 setXScale:0.5];
        [boulder2 setYScale:0.5];
        [_boulders2 addObject:boulder2];
        [self addChild:boulder2];
    }
    
    //Set the boulders to begin spawning immediately
    _nextBoulderSpawn1 = 0;
    _nextBoulderSpawn2 = 0;
    
    //Hide the boulders while they haven't yet been thrown
    for (SKSpriteNode *boulder1 in _boulders1) {
        boulder1.hidden = YES;
    }
    for (SKSpriteNode *boulder2 in _boulders2) {
        boulder2.hidden = YES;
    }
}



- (void)initLasers {
    //Setup the lasers
    _playerLasers = [[NSMutableArray alloc] initWithCapacity:kNumLasers];
    for (int i = 0; i < kNumLasers; ++i) {
        SKSpriteNode *playerLaser = [SKSpriteNode spriteNodeWithImageNamed:@"laser.png"];
        playerLaser.hidden = YES;
        [_playerLasers addObject:playerLaser];
        [self addChild:playerLaser];
    }
    canShoot = YES;
}



- (void)initLabels {
    //Setup the label for player lives
    _livesLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    _livesLabel.name = @"livesLabel";
    _livesLabel.text = [NSString stringWithFormat:@"%d", _lives];
    _livesLabel.scale = 0.9;
    _livesLabel.position = CGPointMake(self.frame.size.width/9, self.frame.size.height * 0.9);
    _livesLabel.fontColor = [SKColor redColor];
    [self addChild:_livesLabel];
    
    //Setup the label for the evil duck's lives
    _evilDuckLivesLabel = [[SKLabelNode alloc] initWithFontNamed:@"ChalkboardSE-Bold"];
    _evilDuckLivesLabel.name = @"evilDuckLivesLabel";
    _evilDuckLivesLabel.text = [NSString stringWithFormat:@"%d", _evilDuckLives];
    _evilDuckLivesLabel.scale = 0.9;
    _evilDuckLivesLabel.position = CGPointMake(_evilDuck.position.x, _evilDuck.position.y * 0.80);
    _evilDuckLivesLabel.fontColor = [SKColor blackColor];
    [self addChild:_evilDuckLivesLabel];
}



- (void)boulderSpawn {
    //Falling boulders
    double curTime = CACurrentMediaTime();
    
    //Deal with boulders from both hands
    if (curTime > _nextBoulderSpawn1) {
        
        //Get ready to fire the next boulder from the left hand if it is time for it to spawn
        float randSecs1 = [self randomValueBetween:1.0 andValue:1.8];
        _nextBoulderSpawn1 = randSecs1 + curTime;
        float randDuration1 = [self randomValueBetween:2.0 andValue:10.0];
        SKSpriteNode *boulder1 = [_boulders1 objectAtIndex:_nextBoulder1];
        _nextBoulder1++;
        if (_nextBoulder1 >= _boulders1.count) {
            _nextBoulder1 = 0;
        }
        
        //Put the boulder in position to be thrown
        [boulder1 removeAllActions];
        boulder1.position = CGPointMake(_evilDuck.position.x - 220, _evilDuck.position.y + 120);
        boulder1.hidden = NO;
        
        CGPoint location1 = CGPointMake(_evilDuck.position.x, -self.frame.size.height-boulder1.size.height);
        
        SKAction *moveAction1 = [SKAction moveTo:location1 duration:randDuration1];
        SKAction *doneAction1 = [SKAction runBlock:(dispatch_block_t)^() {boulder1.hidden = YES;}];
        
        //Throw the boulder
        SKAction *moveBoulderActionWithDone1 = [SKAction sequence:@[moveAction1, doneAction1]];
        [boulder1 runAction:moveBoulderActionWithDone1 withKey:@"boulderMoving"];
        
        //Get ready to fire the next boulder from the right hand if it is time for it to spawn
        float randSecs2 = [self randomValueBetween:1.0 andValue:1.8];
        _nextBoulderSpawn2 = randSecs2 + curTime;
        float randDuration2 = [self randomValueBetween:2.0 andValue:10.0];
        SKSpriteNode *boulder2 = [_boulders2 objectAtIndex:_nextBoulder2];
        _nextBoulder2++;
        if (_nextBoulder2 >= _boulders2.count) {
            _nextBoulder2 = 0;
        }
        
        //Put the boulder in position to be thrown
        [boulder2 removeAllActions];
        boulder2.position = CGPointMake(_evilDuck.position.x + 220, _evilDuck.position.y + 120);
        boulder2.hidden = NO;
        
        CGPoint location2 = CGPointMake(_evilDuck.position.x, -self.frame.size.height-boulder2.size.height);
        
        SKAction *moveAction2 = [SKAction moveTo:location2 duration:randDuration2];
        SKAction *doneAction2 = [SKAction runBlock:(dispatch_block_t)^() {boulder2.hidden = YES;}];
        
        //Throw the boulder
        SKAction *moveBoulderActionWithDone2 = [SKAction sequence:@[moveAction2, doneAction2 ]];
        [boulder2 runAction:moveBoulderActionWithDone2 withKey:@"boulderMoving"];
    }
}



- (void)updateLabels {
    //Update lives and score labels
    _livesLabel.text = [NSString stringWithFormat:@"Lives: %d", _lives];
    _evilDuckLivesLabel.text = [NSString stringWithFormat:@"%d", _evilDuckLives];
    _evilDuckLivesLabel.position = CGPointMake(_evilDuck.position.x, _evilDuck.position.y * 0.80);
}



- (void)evilDuckMovement {
    //update the position of evilDuck to follow the player
    if (_player.position.x - 6 < _evilDuck.position.x || _player.position.x + 6 > _evilDuck.position.x) {
        _evilDuck.position = _evilDuck.position;
    }
    if (_player.position.x > _evilDuck.position.x) {
        _evilDuck.position = CGPointMake(_evilDuck.position.x + 5, _evilDuck.position.y);
    }
    if (_player.position.x < _evilDuck.position.x) {
        _evilDuck.position = CGPointMake(_evilDuck.position.x - 5, _evilDuck.position.y);
    }
}



- (void)playerCollisionDetection {
    
    //Detect collisions for boulders thrown from the left hand
    for (SKSpriteNode *boulder1 in _boulders1) {
        if (boulder1.hidden) {
            continue;
        }
        
        //Only hit player if it is not invulnerable
        if (_invulnerability == 0) {
            if ([_player intersectsNode:boulder1]) {
                boulder1.hidden = YES;
                SKAction *blink = [SKAction sequence:@[[SKAction fadeOutWithDuration:0.1],
                                                       [SKAction fadeInWithDuration:0.1]]];
                SKAction *blinkForTime = [SKAction repeatAction:blink count:4];
                [_player runAction:blinkForTime];
                SKAction *hitBoulderSound = [SKAction playSoundFileNamed:@"explosion_small.caf" waitForCompletion:YES];
                SKAction *moveBoulderActionWithDone = [SKAction sequence:@[hitBoulderSound]];
                [boulder1 runAction:moveBoulderActionWithDone withKey:@"hitBoulder"];
                NSLog(@"a hit!");
                _lives--;
                _invulnerability = 30;
            }
        }
    }
    
    //Detect collisions for boulders thrown from the right hand
    for (SKSpriteNode *boulder2 in _boulders2) {
        if (boulder2.hidden) {
            continue;
        }
        
        //Only hit player if it is not invulnerable
        if (_invulnerability == 0) {
            if ([_player intersectsNode:boulder2]) {
                boulder2.hidden = YES;
                SKAction *blink = [SKAction sequence:@[[SKAction fadeOutWithDuration:0.1],
                                                       [SKAction fadeInWithDuration:0.1]]];
                SKAction *blinkForTime = [SKAction repeatAction:blink count:4];
                [_player runAction:blinkForTime];
                SKAction *hitBoulderSound = [SKAction playSoundFileNamed:@"explosion_small.caf" waitForCompletion:YES];
                SKAction *moveBoulderActionWithDone = [SKAction sequence:@[hitBoulderSound]];
                [boulder2 runAction:moveBoulderActionWithDone withKey:@"hitBoulder"];
                NSLog(@"a hit!");
                _lives--;
                _invulnerability = 30;
            }
        }
    }
    
    if (_invulnerability > 0) {
        _invulnerability--;
    }
    //Lose the game if player loses all lives
    if (_lives <= 0) {
        NSLog(@"you lose");
        [self endTheScene:YES];
    }
}



-(void)evilDuckCollisionDetection {
    //Check collisions for lasers
    for (SKSpriteNode *playerLaser in _playerLasers) {
        if (playerLaser.hidden) {
            continue;
        }
        if ([playerLaser intersectsNode:_evilDuck]) {
            playerLaser.hidden = YES;
            --_evilDuckLives;
            NSLog(@"%d", _evilDuckLives);
            if (_evilDuckLives >= 1) {
                SKAction *hitLazerSound = [SKAction playSoundFileNamed:@"explosion_small.caf" waitForCompletion:YES];
                SKAction *moveLazerActionWithDone = [SKAction sequence:@[hitLazerSound]];
                [playerLaser runAction:moveLazerActionWithDone withKey:@"hitBoulder"];
                [self addExplosion:_evilDuck.position];
            } else {
                SKAction *hitLazerSound = [SKAction playSoundFileNamed:@"explosion_large.caf" waitForCompletion:YES];
                SKAction *moveLazerActionWithDone = [SKAction sequence:@[hitLazerSound]];
                [playerLaser runAction:moveLazerActionWithDone withKey:@"hitBoulder"];
                [self addExplosion:_evilDuck.position];
                
                if (_finishBoss == NO) {
                    _invulnerability = 250;
                    canShoot = NO;  //Forbid the player to shoot the evilduck after its live becomes 0 to prevent memory leak
                    _finishBoss = YES;
                }
            }
        }
    }
    
    if (_invulnerability < 0) {
        _evilDuck.hidden = YES;
        [self endTheScene:NO];
    }
}


@end
