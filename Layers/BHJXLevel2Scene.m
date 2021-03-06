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
@import CoreMotion;



//Number of boulders in array
#define kNumBoulders 10
#define kNumImages 2



static NSString* playerCategoryName = @"player";
static int initialDistance = 1000;



@implementation BHJXLevel2Scene
{
    SKSpriteNode *_player;
    SKSpriteNode *_background1;
    SKSpriteNode *_background2;
    SKLabelNode *_livesLabel;
    SKLabelNode *_distanceLabel;
    
    NSArray *_playerFlickerFrames;
    NSMutableArray *_boulders;
    int _nextBoulder;
    double _nextBoulderSpawn;
    
    int _lives;
    int _distance;
    int _invulnerability;
    
    bool _gameOver;
    
    SKScene *_gameOverScene;
    AVAudioPlayer *_backgroundAudioPlayer;
    CMMotionManager *_motionManager;
}



-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {

        [self initFlickering];
        [self initBackground];
        [self initPlayer];
        [self initBoulders];
        [self initLabels];
        [self startBackgroundMusic];
        
        [self startTheGame];
    }
    return self;
}



- (void)startTheGame
{
    //Initialize all values
    _lives = 5;
    _distance = initialDistance;
    _invulnerability = 0;
    _player.hidden = NO;
    _player.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*1.84);
    [self flickering];
    [self startMonitoringAcceleration];
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
}



- (void)update:(NSTimeInterval)currentTime {
    [self scrollBackground];
    [self boulderSpawn];
    [self updateLabels];
    [self updatePlayerPositionFromMotionManager];
    
    //Only do collision detection if the level is not over
    if (!_gameOver) {
        [self collisionDetection];
    }
    
}



- (float)randomValueBetween:(float)low andValue:(float)high {
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
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
        _gameOverScene = [[BHJXGameOverScene alloc] initWithSize:self.size level:2];
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



- (void)startMonitoringAcceleration
{
    if (_motionManager.accelerometerAvailable) {
        [_motionManager startAccelerometerUpdates];
    }
}

- (void)stopMonitoringAcceleration
{
    if (_motionManager.accelerometerAvailable && _motionManager.accelerometerActive) {
        [_motionManager stopAccelerometerUpdates];
    }
}

- (void)updatePlayerPositionFromMotionManager
{
    CMAccelerometerData* data = _motionManager.accelerometerData;
    if (fabs(data.acceleration.x) > 0.2) {
        [_player.physicsBody applyForce:CGVectorMake(40.0 * data.acceleration.x, 0)];
    }
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
    //Initialize scrolling background
    _background1 = [SKSpriteNode spriteNodeWithImageNamed:@"mantleBackground.png"];
    _background1.anchorPoint = CGPointZero;
    _background1.position = CGPointMake(0, 0);
    [self addChild:_background1];
    
    _background2 = [SKSpriteNode spriteNodeWithImageNamed:@"mantleBackground.png"];
    _background2.anchorPoint = CGPointZero;
    _background2.position = CGPointMake(0, _background2.size.height-1);
    [self addChild:_background2];
}



- (void)initPlayer {
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
    _player.physicsBody.dynamic = YES;
    _player.physicsBody.affectedByGravity = NO;
    _player.physicsBody.mass = 0.01;
    
    _motionManager = [[CMMotionManager alloc] init];
}



- (void)initBoulders {
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
}



- (void)initLabels {
    //Setup the lives label
    _livesLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    _livesLabel.name = @"livesLabel";
    _livesLabel.text = [NSString stringWithFormat:@"%d", _lives];
    _livesLabel.scale = 0.9;
    _livesLabel.position = CGPointMake(self.frame.size.width/9, self.frame.size.height * 0.05);
    _livesLabel.fontColor = [SKColor blueColor];
    [self addChild:_livesLabel];
    
    
    //Setup the distance label
    _distanceLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    _distanceLabel.name = @"scoreLabel";
    _distanceLabel.text = [NSString stringWithFormat:@"Distance to Baron von Quack: %d", _distance];
    _distanceLabel.scale = 0.9;
    _distanceLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.05);
    _distanceLabel.fontColor = [SKColor blueColor];
    [self addChild:_distanceLabel];
}



- (void)scrollBackground {
    //Set the background to be scrolling
    _background1.position = CGPointMake(_background1.position.x, _background1.position.y+4);
    _background2.position = CGPointMake(_background2.position.x, _background2.position.y+4);
    if (_background1.position.y > _background1.size.height){
        _background1.position = CGPointMake(_background1.position.x, _background2.position.y - _background2.size.height);
    }
    if (_background2.position.y > _background2.size.height) {
        _background2.position = CGPointMake(_background2.position.x, _background1.position.y - _background1.size.height);
    }
}



- (void)boulderSpawn {
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
            boulder.hidden = YES;
        }];
        
        SKAction *moveBoulderActionWithDone = [SKAction sequence:@[moveAction, doneAction ]];
        [boulder runAction:moveBoulderActionWithDone withKey:@"boulderMoving"];
    }
}



- (void)updateLabels {
    //Update lives and score labels
    _livesLabel.text = [NSString stringWithFormat:@"Lives: %d", _lives];
    _distanceLabel.text = [NSString stringWithFormat:@"Distance to Core: %d", _distance];
    if (_distance <= initialDistance*0.2) {
        _distanceLabel.fontColor = [SKColor yellowColor];
        _distanceLabel.scale = 1.9;
    }
    if (_distance <= 0) {
        [_distanceLabel setHidden:YES];
    }
    
    //Decrement distance
    _distance--;
}



//Deal with collision detection
- (void)collisionDetection {
    for (SKSpriteNode *boulder in _boulders) {
        if (boulder.hidden) {
            continue;
        }
        if (_invulnerability == 0) {
            if ([_player intersectsNode:boulder]) {
                boulder.hidden = YES;
                SKAction *blink = [SKAction sequence:@[[SKAction fadeOutWithDuration:0.1],
                                                       [SKAction fadeInWithDuration:0.1]]];
                SKAction *blinkForTime = [SKAction repeatAction:blink count:4];
                [_player runAction:blinkForTime];
                SKAction *hitBoulderSound = [SKAction playSoundFileNamed:@"explosion_small.caf" waitForCompletion:YES];
                SKAction *moveBoulderActionWithDone = [SKAction sequence:@[hitBoulderSound]];
                [boulder runAction:moveBoulderActionWithDone withKey:@"hitBoulder"];
                _lives--;
                _invulnerability = 150;
            }
        }
        if (_invulnerability > 0) {
            _invulnerability--;
        }
        if (_lives <= 0) {
            [self endTheScene:YES];
        } else {
            if (_distance <= 0) {
                _player.physicsBody.dynamic = NO;
                if (_player.position.y > -100) {
                    _invulnerability = 2000;
                    _player.position = CGPointMake(_player.position.x, _player.position.y - 5);
                } else {
                    [self endTheScene:NO];
                }
            }
        }
    }
}

@end
