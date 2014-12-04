//
//  BHJXLevel1Scene.m
//  Layers
//
//  Created by Jun Hong Park on 10/12/14.
//  Copyright (c) 2014 BHJX. All rights reserved.
//



#import "BHJXLevel1Scene.h"
#import "BHJXGameOverScene.h"
#import "BHJXIntroLevel2.h"
@import AVFoundation;



//Number of boulders in array
#define kNumBoulders 10
#define kNumImages 2



static NSString* playerCategoryName = @"player";
static int initialDistance = 750;



@implementation BHJXLevel1Scene
{
    SKSpriteNode *_player;
    SKSpriteNode *_background1;
    SKSpriteNode *_background2;
    SKLabelNode *_livesLabel;
    SKLabelNode *_distanceLabel;
  
    NSArray *_playerFlickerFrames;
    NSArray *_backgroundFlickerFrames;
    NSMutableArray *_boulders;
    int _nextBoulder;
    double _nextBoulderSpawn;
    
    int _lives;
    int _distance;
    int _invulnerability;
    
    bool _gameOver;
    
    SKScene *_gameOverScene;
    AVAudioPlayer *_backgroundAudioPlayer;
}



- (id)initWithSize:(CGSize)size {
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
    _player.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*0.1);
    [self flickering];
}



- (void)update:(NSTimeInterval)currentTime {
    
    [self scrollBackground];
    [self boulderSpawn];
    [self updateLabels];
    
    //Only do collision detection if the level is not over
    if (!_gameOver) {
        [self collisionDetection];
    }
}



-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    //Called when a touch begins
    self.isFingerOnDuck = YES;
}



-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    //Response to touch
    if (self.isFingerOnDuck) {
        UITouch* touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInNode:self];
        CGPoint previousLocation = [touch previousLocationInNode:self];
        SKSpriteNode* duck = (SKSpriteNode*)[self childNodeWithName: playerCategoryName];
        int playerX = duck.position.x + (touchLocation.x - previousLocation.x);
        playerX = MAX(playerX, duck.size.width/2);
        playerX = MIN(playerX, self.size.width - duck.size.width/2);
        duck.position = CGPointMake(playerX, duck.position.y);
    }
}



-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    self.isFingerOnDuck = NO;
}



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
    
    if (didLose) {
        _gameOverScene = [[BHJXGameOverScene alloc] initWithSize:self.size level:1];
        [self.view presentScene:_gameOverScene];
    } else {
        BHJXIntroLevel2 * scene = [BHJXIntroLevel2 sceneWithSize:self.view.bounds.size];
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



// Make the images flicker
-(void)flickering
{
    //This is our general runAction method to make our player flicker.
    [_player runAction:[SKAction repeatActionForever:
                      [SKAction animateWithTextures:_playerFlickerFrames
                                       timePerFrame:0.1f
                                             resize:NO
                                            restore:YES]] withKey:@"flickeringInPlacePlayer"];
    [_background1 runAction:[SKAction repeatActionForever:
                        [SKAction animateWithTextures:_backgroundFlickerFrames
                                         timePerFrame:0.1f
                                               resize:NO
                                              restore:YES]] withKey:@"flickeringInPlaceBackground"];
    [_background2 runAction:[SKAction repeatActionForever:
                             [SKAction animateWithTextures:_backgroundFlickerFrames
                                              timePerFrame:0.1f
                                                    resize:NO
                                                   restore:YES]] withKey:@"flickeringInPlaceBackground"];
    
    return;
}



//Setup the flickering of player and background
- (void)initFlickering {
    //Setup flickering
    NSMutableArray *bgFlickerFrames = [NSMutableArray array];
    SKTextureAtlas *bgAnimatedAtlas = [SKTextureAtlas atlasNamed:@"Volcano"];
    
    NSMutableArray *playerFlickerFrames = [NSMutableArray array];
    SKTextureAtlas *playerAnimatedAtlas = [SKTextureAtlas atlasNamed:@"Player"];
    
    for (int i=1; i <= kNumImages; i++){
        NSString *textureName = [NSString stringWithFormat:@"VolcanoBackground%d", i];
        SKTexture *temp = [bgAnimatedAtlas textureNamed:textureName];
        [bgFlickerFrames addObject:temp];
        textureName = [NSString stringWithFormat:@"Player%d", i];
        temp = [playerAnimatedAtlas textureNamed:textureName];
        [playerFlickerFrames addObject:temp];
    }
    _playerFlickerFrames = playerFlickerFrames;
    _backgroundFlickerFrames = bgFlickerFrames;
}



//Initialize the background
- (void)initBackground {
    SKTexture *temp = _backgroundFlickerFrames[0];
    
    
    //Initialize scrolling background
    _background1 = [SKSpriteNode spriteNodeWithTexture:temp];
    _background1.anchorPoint = CGPointZero;
    _background1.position = CGPointMake(0, 0);
    [self addChild:_background1];
    
    _background2 = [SKSpriteNode spriteNodeWithTexture:temp];
    _background2.anchorPoint = CGPointZero;
    _background2.position = CGPointMake(0, _background2.size.height-1);
    [self addChild:_background2];
}



//Initialize the player
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



// Initialize the boulders
- (void)initBoulders {
    _boulders = [[NSMutableArray alloc] initWithCapacity:kNumBoulders];
    for (int i = 0; i < kNumBoulders; ++i) {
        SKSpriteNode *boulder = [SKSpriteNode spriteNodeWithImageNamed:@"Boulder1.png"];
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



// Initialize the labels
- (void)initLabels {
    //Setup the lives label
    _livesLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    _livesLabel.name = @"livesLabel";
    _livesLabel.text = [NSString stringWithFormat:@"%d", _lives];
    _livesLabel.scale = 0.9;
    _livesLabel.position = CGPointMake(self.frame.size.width/9, self.frame.size.height * 0.9);
    _livesLabel.fontColor = [SKColor redColor];
    [self addChild:_livesLabel];
    
    
    //Setup the score label
    _distanceLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
    _distanceLabel.name = @"scoreLabel";
    _distanceLabel.text = [NSString stringWithFormat:@"%d", _distance];
    _distanceLabel.scale = 0.9;
    _distanceLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.9);
    _distanceLabel.fontColor = [SKColor redColor];
    [self addChild:_distanceLabel];
}



//Scroll the background
- (void)scrollBackground {
    _background1.position = CGPointMake(_background1.position.x, _background1.position.y-4);
    _background2.position = CGPointMake(_background2.position.x, _background2.position.y-4);
    if (_background1.position.y < -_background1.size.height){
        _background1.position = CGPointMake(_background1.position.x, _background2.position.y + _background2.size.height);
    }
    if (_background2.position.y < -_background2.size.height) {
        _background2.position = CGPointMake(_background2.position.x, _background1.position.y + _background1.size.height);
    }
    
}



//Spawn the boulders
- (void)boulderSpawn {
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
}



//Update the labels
- (void)updateLabels {
    //Update lives and distance labels
    _livesLabel.text = [NSString stringWithFormat:@"Lives: %d", _lives];
    _distanceLabel.text = [NSString stringWithFormat:@"Distance to Top: %d", _distance];
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
                NSLog(@"a hit!");
                _lives--;
                _invulnerability = 150;
            }
        }
        //Ensure that for a short while after being hit, the player cannot be hit
        if (_invulnerability > 0) {
            _invulnerability--;
        }
        if (_lives <= 0) {
            NSLog(@"you lose");
            [self endTheScene:YES];
        } else {
            if (_distance <= 0) {
                if (_player.position.y < self.frame.size.height + 100) {
                    _invulnerability = 1500;
                    _player.position = CGPointMake(_player.position.x, _player.position.y + 5);
                } else {
                    [self endTheScene:NO];
                }
            }
        }
    }
}
@end
