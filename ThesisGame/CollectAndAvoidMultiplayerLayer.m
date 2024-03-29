//
//  CollectAndAvoidMultiplayerLayer.m
//  ThesisGame
//
//  Created by Alex Savu on 5/7/13.
//
//

#import "CollectAndAvoidMultiplayerLayer.h"
#import "AppDelegate.h"
#import "Player.h"
#import "Obstacle.h"
#import "CCShake.h"
#import "ScoreCounter.h"
#import "SimpleAudioEngine.h"

#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad
#define kHeroMovementAction 1
#define kPlayerSpeed 300
#define kFilteringFactor 0.1
#define MIN_COURSE_X 173.0
#define MAX_COURSE_X 858.0

@interface CollectAndAvoidMultiplayerLayer (){
    NSInteger avatarInt;
    int scoreCounterPlayerOne;
    int scoreCounterPlayerTwo;
    int obstaclePositionOnXReceived;
    int obstacleDurationReceived;
    
    NSInteger counterForObstacles;
    CCLabelBMFont *labelScorePlayerOne;
    CCLabelBMFont *labelScorePlayerTwo;
    
    ScoreCounter *scoreCounter;
}
@property (nonatomic, strong) CCMenu *backToMainMenu;
@property (nonatomic, retain) CCLayer *currentLayer;
@property (nonatomic, weak) NSString *avatar;
@property (nonatomic, weak) NSString *otherAvatar;
@property (nonatomic, weak) CCSprite *scorePlayerOne;
@property (nonatomic, weak) CCSprite *scorePlayerTwo;
@property (nonatomic, strong) CCSpriteBatchNode *spriteSheet;

-(void)step:(ccTime)dt;
-(NSString*)chosenAvatar:(NSInteger)value selected:(BOOL)isSelected;
-(NSArray*)animFramesArrayForCharacter:(NSInteger)value selected:(BOOL)isSelected;

@end

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation CollectAndAvoidMultiplayerLayer
@synthesize background = _background;
@synthesize background2 = _background2;
@synthesize player1 = _player1;
@synthesize player2 = _player2;
@synthesize obstacle = _obstacle;
@synthesize backToMainMenu = _backToMainMenu;
@synthesize avatar = _avatar;
@synthesize otherAvatar = _otherAvatar;
@synthesize scorePlayerOne = _scorePlayerOne;
@synthesize scorePlayerTwo = _scorePlayerTwo;


// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	CollectAndAvoidMultiplayerLayer *layer = [CollectAndAvoidMultiplayerLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        scoreCounter = [[ScoreCounter alloc] init];
        
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        
        counterForObstacles = 1;
        
        //Preload sound effects
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"dropRock.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"collectStar.mp3"];
        
        //chosen avatar is retrieved from userDefaults
        NSUserDefaults *savedAvatar = [NSUserDefaults standardUserDefaults];
        avatarInt = [savedAvatar integerForKey:@"chosenAvatar"];
        
        //Adding the backgrounds as a sprite
        self.background = [CCSprite spriteWithFile:@"spaceBackground~ipad.png"];
        self.background.anchorPoint = ccp(0, 0);
        self.background.position = ccp(0, 0);
        [self addChild:self.background];
        
        self.background2 = [CCSprite spriteWithFile:@"spaceBackground~ipad.png"];
        self.background2.anchorPoint = ccp(0, 0);
        self.background2.position = ccp(0, self.background.boundingBox.size.height);
        [self addChild:self.background2];
        
        //The method that gets called to find a match between 2 players
        AppController * delegate = (AppController *) [UIApplication sharedApplication].delegate;
        [[GCHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:delegate.director delegate:self];
        
        //enable accelerometer
        self.isAccelerometerEnabled = YES;
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:1/60];
        
        ourRandom = arc4random();
        [self setGameState:kGameStateWaitingForMatch3];
        
        [self addBackButton];
	}
	return self;
}

#pragma mark Score Assets

-(void)addScoreAssetsForPlayer1:(BOOL)player1 selected:(BOOL)isSelected{
    // ask director for the window size
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    if (player1) {
        //Initialize score images
        if (isSelected) {
            self.scorePlayerOne = [CCSprite spriteWithFile:@"collectSelected~ipad.png"];
        }else{
            self.scorePlayerOne = [CCSprite spriteWithFile:@"collectUnselected~ipad.png"];
        }
        self.scorePlayerOne.position = ccp(74.f, self.scorePlayerOne.boundingBox.size.height + 10);
        [self addChild:self.scorePlayerOne];
        
        //Initialize labels for scores
        labelScorePlayerOne = [CCLabelBMFont labelWithString:@"0" fntFile:@"magneto.fnt"];
        labelScorePlayerOne.position = ccp(80.f, self.scorePlayerOne.boundingBox.size.height );
        [labelScorePlayerOne setScale:2.5];
        [self addChild:labelScorePlayerOne];
    }else{
        //Initialize score images
        if (isSelected) {
            self.scorePlayerTwo = [CCSprite spriteWithFile:@"collectSelected~ipad.png"];
        }else{
            self.scorePlayerTwo = [CCSprite spriteWithFile:@"collectUnselected~ipad.png"];
        }
        self.scorePlayerTwo.position = ccp(size.width - 74.f, self.scorePlayerTwo.boundingBox.size.height + 10);
        [self addChild:self.scorePlayerTwo];
        
        //Initialize labels for scores
        labelScorePlayerTwo = [CCLabelBMFont labelWithString:@"0" fntFile:@"magneto.fnt"];
        labelScorePlayerTwo.position =  ccp(size.width - 70.f, self.scorePlayerTwo.boundingBox.size.height );
        [labelScorePlayerTwo setScale:2.5];
        [self addChild:labelScorePlayerTwo];
    }
}

#pragma mark Add lives

-(void)addLivesPlayer1:(BOOL)player1 selected:(BOOL)isSelected{
    static int padding = 1;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite *star = nil;
    if (player1) {
        for(int i = 0; i < 5; i++) {
            // Create star and add it to the layer
            if (isSelected) {
                star = [CCSprite spriteWithFile:@"avoidHeartSelected~ipad.png"];
            }else{
                star = [CCSprite spriteWithFile:@"avoidHeart.png"];
            }
            int xOffset = padding+(int)(star.contentSize.width/2+((star.contentSize.width+padding)*(i/2))); // or /cols to fill cols first
            int yOffset = padding+(int)(winSize.height/2-((star.contentSize.width+padding)*(i%2))); // or %cols to fill cols first
            star.position = ccp(50 + xOffset, yOffset);
            star.tag = i + 3; // use i here if you like
            [self addChild:star];
        }
    }else{
        for(int i = 0; i < 5; i++) {
            // Create star and add it to the layer
            if (isSelected) {
                star = [CCSprite spriteWithFile:@"avoidHeartSelected~ipad.png"];
            }else{
                star = [CCSprite spriteWithFile:@"avoidHeart.png"];
            }
            int xOffset = padding+(int)(star.contentSize.width/2+((star.contentSize.width+padding)*(i/2))); // or /cols to fill cols first
            int yOffset = padding+(int)(winSize.height/2-((star.contentSize.width+padding)*(i%2))); // or %cols to fill cols first
            star.position = ccp(900 + xOffset, yOffset);
            star.tag = i + 8; // use i here if you like
            [self addChild:star];
        }
    }
}

//-(void)addLivesPlayer1{
//    static int padding = 1;
//    CGSize winSize = [[CCDirector sharedDirector] winSize];
//    for(int i = 0; i < 5; i++) {
//        // Create star and add it to the layer
//        CCSprite *star = [CCSprite spriteWithFile:@"avoidHeart.png"];
//        int xOffset = padding+(int)(star.contentSize.width/2+((star.contentSize.width+padding)*(i/2))); // or /cols to fill cols first
//        int yOffset = padding+(int)(winSize.height/2-((star.contentSize.width+padding)*(i%2))); // or %cols to fill cols first
//        star.position = ccp(50 + xOffset, yOffset);
//        star.tag = i + 3; // use i here if you like
//        [self addChild:star];
//    }
//}
//
//-(void)addLivesPlayer2{
//    static int padding = 1;
//    CGSize winSize = [[CCDirector sharedDirector] winSize];
//    for(int i = 0; i < 5; i++) {
//        // Create star and add it to the layer
//        CCSprite *star = [CCSprite spriteWithFile:@"avoidHeart.png"];
//        int xOffset = padding+(int)(star.contentSize.width/2+((star.contentSize.width+padding)*(i/2))); // or /cols to fill cols first
//        int yOffset = padding+(int)(winSize.height/2-((star.contentSize.width+padding)*(i%2))); // or %cols to fill cols first
//        star.position = ccp(900 + xOffset, yOffset);
//        star.tag = i + 8; // use i here if you like
//        [self addChild:star];
//    }
//}

-(void)scroll:(ccTime)dt{
    self.background.position = ccp(0, self.background.position.y-2);
    self.background2.position = ccp(0, self.background2.position.y-2);
    if (self.background.position.y < - 768.0) {
        self.background.position = ccp(0, self.background2.position.y + 768.0);
    }
    if (self.background2.position.y < - 768.0) {
        self.background2.position = ccp(0, self.background.position.y + 768.0);
    }
}

#pragma mark Choose Avatar based on number

//Finds the correct .png for the chosen avatar, returns .png location in NSString form.
-(NSString*)chosenAvatar:(NSInteger)value selected:(BOOL)isSelected{
    NSString *avatarString = [[NSString alloc] init];
    if (isSelected) {
        switch(value)
        {
            case 1:
                avatarString = @"afroSelected_1~ipad.png";
                break;
            case 2:
                avatarString = @"gingerSelected_1~ipad.png";
                break;
            case 3:
                avatarString = @"indianSelected_1~ipad.png";
                break;
            case 4:
                avatarString = @"japaneseSelected_1~ipad.png";
                break;
        }
    }else{
        switch(value)
        {
            case 1:
                avatarString = @"afroUnselected_1~ipad.png";
                break;
            case 2:
                avatarString = @"gingerUnselected_1~ipad.png";
                break;
            case 3:
                avatarString = @"indianUnselected_1~ipad.png";
                break;
            case 4:
                avatarString = @"japaneseUnselected_1~ipad.png";
                break;
        }
    }
    
    return avatarString;
}

#pragma mark Choose Animation Frames based on number

-(NSArray*)animFramesArrayForCharacter:(NSInteger)value selected:(BOOL)isSelected{
    NSMutableArray *walkAnimFrames = [NSMutableArray array];
    if (isSelected) {
        switch (value) {
            case 1:
                for (int i=1; i<=8; i++) {
                    [walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"afroSelected_%d~ipad.png",i]]];
                }
                break;
            case 2:
                for (int i=1; i<=8; i++) {
                    [walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"gingerSelected_%d~ipad.png",i]]];
                }
                break;
            case 3:
                for (int i=1; i<=8; i++) {
                    [walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"indianSelected_%d~ipad.png",i]]];
                }
                break;
            case 4:
                for (int i=1; i<=8; i++) {
                    [walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"japaneseSelected_%d~ipad.png",i]]];
                }
                break;
                
            default:
                break;
        }
    }else{
        switch (value) {
            case 1:
                for (int i=1; i<=8; i++) {
                    [walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"afroUnselected_%d~ipad.png",i]]];
                }
                break;
            case 2:
                for (int i=1; i<=8; i++) {
                    [walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"gingerUnselected_%d~ipad.png",i]]];
                }
                break;
            case 3:
                for (int i=1; i<=8; i++) {
                    [walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"indianUnselected_%d~ipad.png",i]]];
                }
                break;
            case 4:
                for (int i=1; i<=8; i++) {
                    [walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"japaneseUnselected_%d~ipad.png",i]]];
                }
                break;
                
            default:
                break;
        }
    }
    
    return walkAnimFrames;
}

#pragma Back to Main Menu

//Back to main menu button
- (void)addBackButton{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    CCMenuItemImage *backButton = [CCMenuItemImage
                                  itemWithNormalImage:@"inGameBackButton~ipad.png"
                                  selectedImage:@"inGameBackButtonSelected~ipad.png"
                                  disabledImage:nil
                                  target:self
                                  selector:@selector(goBackToMenu:)];
    
    self.backToMainMenu = [CCMenu menuWithItems:backButton,nil];
    [self.backToMainMenu setPosition:ccp(70.f,screenSize.height - 55.f)];
    //TODO: change tag value because is the same as the main menu
    [self addChild:self.backToMainMenu z:0];
}

//Selector method for going back to main menu
-(void)goBackToMenu:(CCMenuItemFont*)itemPassedIn {
    CCLOG(@"Tag 1 found, Scene 1");
    [[GameManager sharedGameManager] runSceneWithID:kMultiplayerSceneSelection];
}


//when the authentication has changed restart this scene
- (void)restartTapped:(id)sender {
    // Reload the current scene
    [[CCDirector sharedDirector] replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:[CollectAndAvoidMultiplayerLayer scene]]];
}

//Invitation received (call from the CGHelper)
- (void)inviteReceived {
    [self restartTapped:nil];
}

- (void)sendData:(NSData *)data {
    NSError *error;
    BOOL success = [[GCHelper sharedInstance].match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
    if (!success) {
        CCLOG(@"Error sending init packet");
        [self matchEnded];
    }
}

//Method that actually sends obstacle's position data
- (void)sendData:(NSData *)data withObstaclePosition:(NSData *)obstaclePositionToSend andDuration:(NSData *)duration{
    NSError *error;
    NSMutableData *appendedData = [[NSMutableData alloc] init];
    [appendedData appendData:data];
    [appendedData appendData:obstaclePositionToSend];
    [appendedData appendData:duration];
    BOOL success = [[GCHelper sharedInstance].match sendDataToAllPlayers:appendedData withDataMode:GKMatchSendDataReliable error:&error];
    if (!success) {
        CCLOG(@"Error sending init packet");
        [self matchEnded];
    }
}

//Method that actually sends players position data
- (void)sendData:(NSData *)data withPlayer1Position:(NSData *)player1Position andPlayer2Position:(NSData *)player2Position {
    NSError *error;
    NSMutableData *appendedData = [[NSMutableData alloc] init];
    [appendedData appendData:data];
    [appendedData appendData:player1Position];
    [appendedData appendData:player2Position];
    BOOL success = [[GCHelper sharedInstance].match sendDataToAllPlayers:appendedData withDataMode:GKMatchSendDataReliable error:&error];
    if (!success) {
        CCLOG(@"Error sending init packet");
        [self matchEnded];
    }
}

- (void)sendRandomNumber {
    MessageRandomNumber3 message;
    message.message.messageType = kMessageTypeRandomNumber3;
    message.randomNumber = ourRandom;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageRandomNumber3)];
    [self sendData:data];
}

//Send score after star collision

- (void)sendScoreForStar:(int)starScore {
    MessageCollidionStar3 message;
    message.message.messageType = kMessageTypeCollisionStar3;
    message.collisionStar = starScore;
    
    NSData *starScoreData = [NSData dataWithBytes:&message length:sizeof(MessageCollidionStar3)];
    [self sendData:starScoreData];
}

//Send score after rock collision

- (void)sendScoreForRock:(int)rockScore {
    MessageCollisionRock3 message;
    message.message.messageType = kMessageTypeCollisionRock3;
    message.collisionRock = rockScore;
    
    NSData *starScoreData = [NSData dataWithBytes:&message length:sizeof(MessageCollisionRock3)];
    [self sendData:starScoreData];
}

//Send avatar number
- (void)sendAvatarNumber {
    MessageAvatarNumber3 message;
    message.message.messageType = kMessageTypeAvatarNumber3;
    message.avatarNumber = avatarInt;
    
    NSData *avatarData = [NSData dataWithBytes:&message length:sizeof(MessageAvatarNumber3)];
    [self sendData:avatarData];
}

- (void)sendGameBegin {
    MessageGameBegin3 message;
    message.message.messageType = kMessageTypeGameBegin3;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameBegin3)];
    [self sendData:data];
    
}

//Method to sent player's position over the network
- (void)sendMoveWithPositionOfPlayer1:(CGPoint)player1Position andPlayer2:(CGPoint)player2Position{
    MessageMove3 message;
    message.message.messageType = kMessageTypeMove3;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageMove3)];
    NSData *dataWithPlayer1Position = [NSData dataWithBytes:&player1Position length:sizeof(player1Position)];
    NSData *dataWithPlayer2Position = [NSData dataWithBytes:&player2Position length:sizeof(player2Position)];
    [self sendData:data withPlayer1Position:dataWithPlayer1Position andPlayer2Position:dataWithPlayer2Position];
}

// Adds methods to send move and game over messages
- (void)sendGameOver:(BOOL)player1Won {
    
    MessageGameOver3 message;
    message.message.messageType = kMessageTypeGameOver3;
    message.player1Won = player1Won;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameOver3)];
    [self sendData:data];
    
}

#pragma mark Step methods

//step method fro the obstacles
-(void)obstaclesStep:(ccTime)dt{
    [self addObstacles];
}

//the function schedule and call everything as needed
- (void)step:(ccTime)dt {
	thing_pos.x += thing_vel.x * dt;
	
    // ask director for the window size
    CGSize size = [[CCDirector sharedDirector] winSize];
    
	CGSize thing_size = self.player1.contentSize;
    //set the maximun and minimum positions where our character could be on screen
    float max_x = 0;
	float min_x = 0;
    float max_y = 0;
	float min_y = 0;
    
    if(IDIOM == IPAD) {
        //Device is ipad
        max_x = 858.0 - thing_size.width/2;
        min_x = 173.0 + thing_size.width/2;
        
        max_y = size.height - thing_size.height;
        min_y = 0 + thing_size.height/2;
        
    }else{
        //Device is iphone
        max_x = 480 - thing_size.width/2;
        min_x = 0 + thing_size.width/2;
        
        max_y = 320 - thing_size.height/2;
        min_y = 0 + thing_size.height/2;
    }
	
	if (thing_pos.x > max_x) thing_pos.x = max_x;
	if (thing_pos.x < min_x) thing_pos.x = min_x;
    if (thing_pos.y < min_y) thing_pos.y = min_y;
    if (thing_pos.y > max_y) thing_pos.y = max_y;
    
    thing_vel.x += thing_acc.x * dt;
    thing_vel.y += thing_acc.y * dt;
    
	thing_pos.x += thing_vel.x * dt;
    thing_pos.y += thing_vel.y * dt;
    
    //Player 2-------
    
    thing2_pos.x += thing2_vel.x * dt;
	
	CGSize thing2_size = self.player2.contentSize;
    float max2_x = 0;
	float min2_x = 0;
    float max2_y = 0;
	float min2_y = 0;
    
    if(IDIOM == IPAD) {
        //Device is ipad
        max2_x = MAX_COURSE_X - thing2_size.width/2;
        min2_x = MIN_COURSE_X + thing2_size.width/2;
        
        max2_y = size.height - thing_size.height;
        min2_y = 0 + thing_size.height/2;
        
    }else{
        //Device is iphone
        max2_x = 480 - thing2_size.width/2;
        min2_x = 0 + thing2_size.width/2;
        
        max2_y = 320 - thing2_size.height/2;
        min2_y = 0 + thing2_size.height/2;
    }
    
    if (thing2_pos.x > max2_x) thing2_pos.x = max2_x;
	if (thing2_pos.x < min2_x) thing2_pos.x = min2_x;
    if (thing2_pos.y < min2_y) thing2_pos.y = min2_y;
    if (thing2_pos.y > max2_y) thing2_pos.y = max2_y;
    
    
    thing2_vel.x += thing2_acc.x * dt;
    thing2_vel.y += thing2_acc.y * dt;
    
	thing2_pos.x += thing2_vel.x * dt;
    thing2_pos.y += thing2_vel.y * dt;
    
    //-------
    
    if (isPlayer1) {
        self.player1.position = ccp(thing_pos.x, thing_pos.y);
    }else{
        self.player2.position = ccp(thing2_pos.x, thing2_pos.y);
    }
    
    if (gameState != kGameStateActive3) return;
    [self sendMoveWithPositionOfPlayer1:self.player1.position andPlayer2:self.player2.position];
    
    //collision method
    [self checkForCollision];
}

#pragma mark Stars effect

-(void)sparkleAt:(CGPoint)p {
    //	NSLog(@"sparkle");
	CCParticleSystem *ps = [CCParticleExplosion node];
	[self addChild:ps z:12];
	ps.texture = [[CCTextureCache sharedTextureCache] addImage:@"stars.png"];
    //	ps.blendAdditive = YES;
	ps.position = p;
	ps.life = 1.0f;
	ps.lifeVar = 1.0f;
	ps.totalParticles = 60.0f;
	ps.autoRemoveOnFinish = YES;
    [[SimpleAudioEngine sharedEngine] playEffect:@"collectStar.mp3"];
}

#pragma mark Collision Detection

-(void)checkForCollision{
    if (isPlayer1) {
        //Detection for avoiding player 1
        if (CGRectIntersectsRect([self getChildByTag:31].boundingBox, self.player1.boundingBox)) {
            [scoreCounter substractLivesPlayer1];
            [[self getChildByTag:31] setTag:110];
            [[self getChildByTag:110] runAction:[CCShake actionWithDuration:.5f amplitude:ccp(7, 0)]];
            [self removeChildByTag:scoreCounter.livesLeftPlayer1 + 3 cleanup:YES];
            [self updateWinning];
            
            [self sendScoreForRock:scoreCounter.livesLeftPlayer1];
        }
        
        //Detection for collecting player 1
        if (CGRectIntersectsRect([self getChildByTag:32].boundingBox, self.player1.boundingBox)){
            //Sound effect
            [self sparkleAt:[self getChildByTag:32].position];
            //Update score
            [scoreCounter countScoreForPlayerOne];
            //Remove star
            [self removeChild:[self getChildByTag:32] cleanup:YES];
            //Display score
            [labelScorePlayerOne setString:[NSString stringWithFormat:@"%i",scoreCounter.scoreForPlayerOne]];
            labelScorePlayerOne.visible = YES;
            self.scorePlayerOne.visible = YES;
            [self updateWinning];
            
            [self sendScoreForStar:scoreCounter.scoreForPlayerOne];
        }
        
        //Detection for avoiding player 2
        if (CGRectIntersectsRect([self getChildByTag:31].boundingBox, self.player2.boundingBox)) {
            [[self getChildByTag:31] setTag:111];
            [[self getChildByTag:111] runAction:[CCShake actionWithDuration:.5f amplitude:ccp(7, 0)]];
        }
        
        //Detection for collecting player 2
        if (CGRectIntersectsRect([self getChildByTag:32].boundingBox, self.player2.boundingBox)){
            [self removeChild:[self getChildByTag:32] cleanup:YES];
        }
        
    }else{
        //Detection for avoiding player 1
        if (CGRectIntersectsRect([self getChildByTag:31].boundingBox, self.player1.boundingBox)) {
            [[self getChildByTag:31] setTag:110];
            [[self getChildByTag:110] runAction:[CCShake actionWithDuration:.5f amplitude:ccp(7, 0)]];
        }
        
        //Detection for collecting player 1
        if (CGRectIntersectsRect([self getChildByTag:32].boundingBox, self.player1.boundingBox)){
            [self removeChild:[self getChildByTag:32] cleanup:YES];
        }
        
        //Detection for avoiding player 2
        if (CGRectIntersectsRect([self getChildByTag:31].boundingBox, self.player2.boundingBox)) {
            //Score for avoiding
            [scoreCounter substractLivesPlayer2];
            [[self getChildByTag:31] setTag:111];
            [[self getChildByTag:111] runAction:[CCShake actionWithDuration:.5f amplitude:ccp(7, 0)]];
            [self removeChildByTag:scoreCounter.livesLeftPlayer2 + 8 cleanup:YES];
            [self updateWinning];
            
            [self sendScoreForRock:scoreCounter.livesLeftPlayer2];
        }
        
        //Detection for collecting player 2
        if (CGRectIntersectsRect([self getChildByTag:32].boundingBox, self.player2.boundingBox)){
            //Sound effect
            [self sparkleAt:[self getChildByTag:32].position];
            //Score for collecting
            //Update score
            [scoreCounter countScoreForPlayerTwo];
            //Remove star
            [self removeChild:[self getChildByTag:32] cleanup:YES];
            //Display score
            [labelScorePlayerTwo setString:[NSString stringWithFormat:@"%i",scoreCounter.scoreForPlayerTwo]];
            labelScorePlayerTwo.visible = YES;
            self.scorePlayerTwo.visible = YES;
            [self updateWinning];
            
            [self sendScoreForStar:scoreCounter.scoreForPlayerTwo];
        }
    }
}

#pragma mark Score handling

-(void)updateWinning{
    if (scoreCounter.livesLeftPlayer1 == 0) {
        if (isPlayer1) {
            [self endScene:kEndReasonLose3];
        } else {
            [self endScene:kEndReasonWin3];
        }
    }else if (scoreCounter.livesLeftPlayer2 == 0){
        if (isPlayer1) {
            [self endScene:kEndReasonWin3];
        } else {
            [self endScene:kEndReasonLose3];
        }
    }
    if (scoreCounter.scoreForPlayerOne == 10) {
        if (isPlayer1) {
            [self endScene:kEndReasonWin3];
        } else {
            [self endScene:kEndReasonLose3];
        }
    }else if (scoreCounter.scoreForPlayerTwo == 10){
        if (isPlayer1) {
            [self endScene:kEndReasonLose3];
        } else {
            [self endScene:kEndReasonWin3];
        }
    }
}

#pragma mark Obstacles

-(void)addObstacles{
    self.obstacle = [[Obstacle alloc] initWithFile:@"prototypeObstacle.png"];
    self.starObstacle = [[Obstacle alloc] initWithFile:@"starObject_1.png"];
    // Determine where to spawn the target along the Y axis
    CGSize winSize = [[CCDirector sharedDirector] winSize];
//        int minX = MIN_COURSE_X + self.obstacle.contentSize.width/2;
//        int maxX = MAX_COURSE_X - self.obstacle.contentSize.width/2;
//        int rangeX = maxX - minX;
//        int actualX = (arc4random() % rangeX) + minX;

//---------------------------
    
    int stupidXForRocks = 0;
    int stupidDurationForRocks = 0;
    int stupidXForStars = 0;
    int stupidDurationForStars = 0;
//    int rndValue = 0 + arc4random() % (20 - 0);
    
    if (counterForObstacles % 2 == 0) {
        if (counterForObstacles == 1) {
            stupidXForRocks = 300.0;
            stupidDurationForRocks = 2;
        }else if (counterForObstacles == 2){
            stupidXForRocks = 400.0;
            stupidDurationForRocks = 4;
        }else if (counterForObstacles == 3){
            stupidXForRocks = 500.0;
            stupidDurationForRocks = 2;
        }else if (counterForObstacles == 4){
            stupidXForRocks = 600.0;
            stupidDurationForRocks = 3;
        }else if (counterForObstacles == 5){
            stupidXForRocks = 700.0;
            stupidDurationForRocks = 4;
        }
    }else{
        if (counterForObstacles == 1) {
            stupidXForStars = 350.0;
            stupidDurationForStars = 2;
        }else if (counterForObstacles == 2){
            stupidXForStars = 450.0;
            stupidDurationForStars = 4;
        }else if (counterForObstacles == 3){
            stupidXForStars = 550.0;
            stupidDurationForStars = 2;
        }else if (counterForObstacles == 4){
            stupidXForStars = 650.0;
            stupidDurationForStars = 3;
        }else if (counterForObstacles == 5){
            stupidXForStars = 750.0;
            stupidDurationForStars = 4;
        }
    }
    
    // Create the target slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    if (counterForObstacles % 2 == 0){
        self.obstacle.position = ccp(stupidXForRocks ,winSize.height + (self.obstacle.contentSize.height/2));
        [self addChild:self.obstacle z:0 tag:31];
        //Play sound effect
        [[SimpleAudioEngine sharedEngine] playEffect:@"dropRock.mp3"];
    }else{
        self.starObstacle.position = ccp(stupidXForStars ,winSize.height + (self.starObstacle.contentSize.height/2));
        [self addChild:self.starObstacle z:0 tag:32];
    }
    
//-----------------------------------------

//        // Determine speed of the target
//        int minDuration = 2.0;
//        int maxDuration = 4.0;
//        int rangeDuration = maxDuration - minDuration;
//        int actualDuration = (arc4random() % rangeDuration) + minDuration;
//
//        // Create the actions
//        id actionMove = [CCMoveTo actionWithDuration:actualDuration
//                                            position:ccp(actualX ,-self.obstacle.contentSize.height)];
//        id actionMoveDone = [CCCallFuncN actionWithTarget:self
//                                                 selector:@selector(spriteMoveFinished:)];

//----------------------------------------------------------------------------------------
    
    // Create the actions
    if (counterForObstacles % 2 == 0){
        id actionMove = [CCMoveTo actionWithDuration:stupidDurationForRocks
                                            position:ccp(stupidXForRocks ,-self.obstacle.contentSize.height)];
        id actionMoveDone = [CCCallFuncN actionWithTarget:self
                                                 selector:@selector(spriteMoveFinished:)];
        
        [self.obstacle runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    }else{
        id actionMove = [CCMoveTo actionWithDuration:stupidDurationForStars
                                            position:ccp(stupidXForStars ,-self.starObstacle.contentSize.height)];
        id actionMoveDone = [CCCallFuncN actionWithTarget:self
                                                 selector:@selector(spriteMoveFinished:)];
        
        [self.starObstacle runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    }
    
    if (counterForObstacles < 5) {
        counterForObstacles += 1;
    }else{
        counterForObstacles = 1;
    }
}

//Remove onstacle after going out of screen
-(void)spriteMoveFinished:(id)sender {
    Obstacle *obstacle = (Obstacle *)sender;
    [self removeChild:obstacle cleanup:YES];
}

- (void)tryStartGame {
    
    if (isPlayer1 && gameState == kGameStateWaitingForStart3) {
        [self setGameState:kGameStateActive3];
        
        //This are the functions that will be scheduled to load continuously
        //as long as our game is running
        [self schedule:@selector(step:)];
        [self schedule:@selector(obstaclesStep:) interval:2.0];
        [self schedule:@selector(scroll:) interval:0.0000000001];
        
        //Background music
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"game.mp3" loop:YES];
        
        [self sendGameBegin];
    }
    
}

#pragma mark Accelerometer

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
	float accel_filter = 0.1f;
	//handle our character on-screen via accelerometer
	thing_vel.x = thing_vel.x * accel_filter - acceleration.y * (1.0f - accel_filter) * 500.0f;
    thing_vel.y = thing_vel.y * accel_filter + acceleration.x * (1.0f - accel_filter) * 500.0f;
    //player 2
    thing2_vel.x = thing2_vel.x * accel_filter - acceleration.y * (1.0f - accel_filter) * 500.0f;
    thing2_vel.y = thing2_vel.y * accel_filter + acceleration.x * (1.0f - accel_filter) * 500.0f;
    
    double rollingZ  = acceleration.z;
    double rollingX = acceleration.x;
    double inclination = 0;
    
    if (rollingZ > 0.0) {
        inclination = atan(rollingX / rollingZ) + M_PI / 2.0; //LINE 1
    }
    else if (rollingZ < 0.0) {
        inclination = atan(rollingX / rollingZ) - M_PI / 2.0; // LINE 2
    }
    else if (rollingX < 0) {
        inclination = M_PI/2.0; //atan returns a radian
    }
    else if (rollingX >= 0) {
        inclination = 3 * M_PI/2.0;
    }
    //    NSLog(@"Accelerometer: %f", inclination);
}

#pragma mark End Scene

// Helper code to show a menu to restart the level
- (void)endScene:(EndReason3)endReason {
    //Stop the game loop
    [self unscheduleAllSelectors];
    [self stopAction:self.walkActionPlayer1];
    [self stopAction:self.walkActionPlayer2];
    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
    
    if (gameState == kGameStateDone3) return;
    [self setGameState:kGameStateDone3];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    CCSprite *messageLost = [CCSprite spriteWithFile:@"lost~ipad.png"];
    [messageLost setPosition:ccp(winSize.width/2, winSize.height/2.f)];
    messageLost.scale = 0.1;
    CCSprite *messageWon = [CCSprite spriteWithFile:@"won~ipad.png"];
    [messageWon setPosition:ccp(winSize.width/2, winSize.height/2.f)];
    messageWon.scale = 0.1;

    
    CCSprite *endsceneImage = [CCSprite spriteWithFile:@"gameOver~ipad.png"];
    endsceneImage.scale = 0.1;
    endsceneImage.position = ccp(winSize.width/2, winSize.height - winSize.height/3.f);
    [self addChild:endsceneImage];
    
    CCMenuItemImage *restartImage = [CCMenuItemImage
                                   itemWithNormalImage:@"RestartButtonUnselected~ipad.png"
                                   selectedImage:@"RestartButtonSelected~ipad.png"
                                   disabledImage:nil
                                   target:self
                                   selector:@selector(restartTapped:)];
    
    CCMenu *restartMenu = [CCMenu menuWithItems:restartImage,nil];
    [restartMenu setPosition:ccp(173.f + restartImage.boundingBox.size.width, 180.f)];
//    restartMenu.scale = 0.1;
    [self addChild:restartMenu z:0];
    
    CCMenuItemImage *backButtonEndSceneImage = [CCMenuItemImage
                                   itemWithNormalImage:@"inGameBackButton~ipad.png"
                                   selectedImage:@"inGameBackButtonSelected~ipad.png"
                                   disabledImage:nil
                                   target:self
                                   selector:@selector(goBackToMenu:)];
    
    CCMenu *backButtonEndScene = [CCMenu menuWithItems:backButtonEndSceneImage,nil];
    [backButtonEndScene setPosition:ccp(858.f - backButtonEndSceneImage.boundingBox.size.width/2.f, 180.f)];
//    backButtonEndScene.scale = 0.1;
    [self addChild:backButtonEndScene z:0];
    
    if (endReason == kEndReasonWin3) {
        [self addChild:messageWon];
        [messageWon runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    } else if (endReason == kEndReasonLose3) {
        [self addChild:messageLost];
        [messageLost runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    }
    
    [endsceneImage runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
//    [restartMenu runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
//    [backButtonEndScene runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    
    if (isPlayer1) {
        if (endReason == kEndReasonWin3) {
            [self sendGameOver:true];
        } else if (endReason == kEndReasonLose3) {
            [self sendGameOver:false];
        }
    }else{
        if (endReason == kEndReasonWin3) {
            [self sendGameOver:true];
        }else if (endReason == kEndReasonLose3){
            [self sendGameOver:false];
        }
    }
    
}

- (void)setGameState:(GameState3)state {
    
    gameState = state;
    if (gameState == kGameStateWaitingForMatch3) {
        CCLOG(@"Waiting for match");
    } else if (gameState == kGameStateWaitingForRandomNumber3) {
        CCLOG(@"Waiting for rand #");
    } else if (gameState == kGameStateWaitingForAvatarNumber3) {
        CCLOG(@"Waiting for avatar #");
    } else if (gameState == kGameStateWaitingForStart3) {
        CCLOG(@"Waiting for start");
    } else if (gameState == kGameStateActive3) {
        CCLOG(@"Active");
    } else if (gameState == kGameStateDone3) {
        CCLOG(@"Done");
    }
    
}


#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissViewControllerAnimated:YES completion:nil];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark GCHelperDelegate

- (void)matchStarted {
    CCLOG(@"Match started");
    if (receivedRandom) {
        if(receivedAvatar){
            [self setGameState:kGameStateWaitingForStart3];
        }
        else {
            [self setGameState:kGameStateWaitingForAvatarNumber3];
        }
    } else {
        [self setGameState:kGameStateWaitingForRandomNumber3];
    }
    [self sendRandomNumber];
    [self sendAvatarNumber];
    [self tryStartGame];
}

- (void)matchEnded {
    CCLOG(@"Match ended");
    
    [[GCHelper sharedInstance].match disconnect];
    [GCHelper sharedInstance].match = nil;
    [self endScene:kEndReasonDisconnect3];
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    // ask director for the window size
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    // Store away other player ID for later
    if (otherPlayerID == nil) {
        otherPlayerID = playerID;
    }
    
    Message3 *message = (Message3 *) [data bytes];
    if (message->messageType == kMessageTypeRandomNumber3) {
        
        MessageRandomNumber3 * messageInit = (MessageRandomNumber3 *) [data bytes];
        CCLOG(@"Received random number: %ud, ours %ud", messageInit->randomNumber, ourRandom);
        bool tie = false;
        
        if (messageInit->randomNumber == ourRandom) {
            CCLOG(@"TIE!");
            tie = true;
            ourRandom = arc4random();
            [self sendRandomNumber];
        } else if (ourRandom > messageInit->randomNumber) {
            CCLOG(@"We are player 1");
            isPlayer1 = YES;
        } else {
            CCLOG(@"We are player 2");
            isPlayer1 = NO;
        }
        if (!tie) {
            receivedRandom = YES;
            if (gameState == kGameStateWaitingForRandomNumber3) {
                [self setGameState:kGameStateWaitingForStart3];
            }
        }
        
        //checks the avatars chosen and assigns the right png. If both players have chosen the same avatar
        //the 'other' player is given a random one that is different from the local player's.
    } else if (message->messageType == kMessageTypeAvatarNumber3){
        MessageAvatarNumber3 * messageInit = (MessageAvatarNumber3 *) [data bytes];
        CCLOG(@"Received Avatar number: %ud, ours %ud", messageInit->avatarNumber, avatarInt);
        bool sameAvatar = false;
        
        if(messageInit->avatarNumber == avatarInt){
            CCLOG(@"Same avatar!");
            sameAvatar = true;
        }
        else{
            CCLOG(@"Different avatars!");
        }
        if(isPlayer1){
            if (sameAvatar) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Same Avatar" message:@"You have chosen the same avatar as the other player./n Please go back and choose another avatar" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [alert show];
            }
            if(!sameAvatar){
                //Score Assets
                [self addScoreAssetsForPlayer1:YES selected:YES];
                [self addScoreAssetsForPlayer1:NO selected:NO];
                //Add lives
                [self addLivesPlayer1:YES selected:YES];
                [self addLivesPlayer1:NO selected:NO];
                
                //Animations
                [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"totallyFinalAnimations-hd.plist"];
                self.spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"totallyFinalAnimations-hd.png"];
                [self addChild:self.spriteSheet];
                
                //Animations player1
                CCAnimation *walkAnimPlayer1 = [CCAnimation animationWithSpriteFrames:[self animFramesArrayForCharacter:avatarInt selected:YES] delay:0.1f];
                self.player1 = [CCSprite spriteWithSpriteFrameName:[self chosenAvatar:avatarInt selected:YES]];
                [self.player1 setPosition:ccp(size.height/2, size.width/2)];
                self.walkActionPlayer1 = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimPlayer1]];
                [self.player1 runAction:self.walkActionPlayer1];
                [self.spriteSheet addChild:self.player1 z:0 tag:3];
                
                //Animations player2
                CCAnimation *walkAnimPlayer2 = [CCAnimation  animationWithSpriteFrames:[self animFramesArrayForCharacter:messageInit->avatarNumber selected:NO] delay:0.1f];
                self.player2 = [CCSprite spriteWithSpriteFrameName:[self chosenAvatar:messageInit->avatarNumber selected:NO]];
                [self.player2 setPosition:ccp(size.height/2, size.width/2)];
                self.walkActionPlayer2 = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimPlayer2]];
                [self.player2 runAction:self.walkActionPlayer2];
                [self.spriteSheet addChild:self.player2 z:0 tag:4];
                
                receivedAvatar = YES;
                if (gameState == kGameStateWaitingForAvatarNumber3) {
                    [self setGameState:kGameStateWaitingForStart3];
                }
                [self tryStartGame];
            }
            
        }
        else{
            if (sameAvatar) {
                CGSize winSize = [CCDirector sharedDirector].winSize;
                NSString *message = @"The other player has selected the same avatar as yours \n Please wait while he chooses a different one";
                CCLabelBMFont *label = [CCLabelBMFont labelWithString:message fntFile:@"magneto.fnt"];
                label.position = ccp(winSize.width/2, 180);
                [self addChild:label];
            }
            if(!sameAvatar){
                //Score assets
                [self addScoreAssetsForPlayer1:NO selected:YES];
                [self addScoreAssetsForPlayer1:YES selected:NO];
                //Add lives
                [self addLivesPlayer1:YES selected:NO];
                [self addLivesPlayer1:NO selected:YES];
                
                //Animations
                [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"totallyFinalAnimations-hd.plist"];
                self.spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"totallyFinalAnimations-hd.png"];
                [self addChild:self.spriteSheet];
                
                //Animations player1
                CCAnimation *walkAnimPlayer1 = [CCAnimation animationWithSpriteFrames:[self animFramesArrayForCharacter:messageInit->avatarNumber selected:NO] delay:0.1f];
                self.player1 = [CCSprite spriteWithSpriteFrameName:[self chosenAvatar:messageInit->avatarNumber selected:NO]];
                [self.player1 setPosition:ccp(size.height/2, size.width/2)];
                self.walkActionPlayer1 = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimPlayer1]];
                [self.player1 runAction:self.walkActionPlayer1];
                [self.spriteSheet addChild:self.player1 z:0 tag:3];
                
                //Animations player2
                CCAnimation *walkAnimPlayer2 = [CCAnimation animationWithSpriteFrames:[self animFramesArrayForCharacter:avatarInt selected:YES] delay:0.1f];
                
                self.player2 = [CCSprite spriteWithSpriteFrameName:[self chosenAvatar:avatarInt selected:YES]];
                [self.player2 setPosition:ccp(size.height/2, size.width/2)];
                self.walkActionPlayer2 = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimPlayer2]];
                [self.player2 runAction:self.walkActionPlayer2];
                [self.spriteSheet addChild:self.player2 z:0 tag:4];
                
                receivedAvatar = YES;
                if (gameState == kGameStateWaitingForAvatarNumber3) {
                    [self setGameState:kGameStateWaitingForStart3];
                }
                [self tryStartGame];
            }
        }
        
    } else if (message->messageType == kMessageTypeGameBegin3) {
        [self setGameState:kGameStateActive3];
        
        //This are the functions that will be scheduled to load continuously
        //as long as our game is running
        [self schedule:@selector(step:)];
        [self schedule:@selector(obstaclesStep:) interval:2.0];
        [self schedule:@selector(scroll:) interval:0.0000000001];
        
        //Background music
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"game.mp3" loop:YES];
        
    } else if (message->messageType == kMessageTypeMove3) {
        CGPoint *player1Position;
        CGPoint *player2Position;
        
        NSUInteger length = [data length];
        NSUInteger chunkSize = sizeof(player1Position);
        NSUInteger offset = 0;
        
        do {
            NSUInteger thisChunkSize = length - offset > chunkSize ? chunkSize : length - offset;
            NSData* chunk = [NSData dataWithBytesNoCopy:(char *)[data bytes] + offset
                                                 length:thisChunkSize
                                           freeWhenDone:NO];
            offset += thisChunkSize;
            // do something with chunk
            if (offset == 8) {
                player1Position = (CGPoint *)[chunk bytes];
            }
            if (offset == 16) {
                player2Position = (CGPoint *)[chunk bytes];
            }
        } while (offset < length);
        
        if (isPlayer1) {
            self.player2.position = ccp(player2Position->x, player2Position->y);
        } else {
            self.player1.position = ccp(player1Position->x, player1Position->y);
        }
    }else if (message->messageType == kMessageTypeCollisionStar3){
        MessageCollidionStar3 * messageInit = (MessageCollidionStar3 *) [data bytes];
        if (isPlayer1) {
            [labelScorePlayerTwo setString:[NSString stringWithFormat:@"%i",messageInit->collisionStar]];
            labelScorePlayerTwo.visible = YES;
            self.scorePlayerTwo.visible = YES;
            NSLog(@"Add score for collecting for player 2: %d",messageInit->collisionStar);
        }else{
            [labelScorePlayerOne setString:[NSString stringWithFormat:@"%i",messageInit->collisionStar]];
            labelScorePlayerOne.visible = YES;
            self.scorePlayerOne.visible = YES;
            NSLog(@"Add score for collecting for player 1: %d", messageInit->collisionStar);
        }
    }else if (message->messageType == kMessageTypeCollisionRock3){
        MessageCollisionRock3 * messageInit = (MessageCollisionRock3 *) [data bytes];
        if (isPlayer1) {
            [self removeChildByTag:messageInit->collisionRock + 8 cleanup:YES];
            NSLog(@"Remove life for player 2");
        }else{
            [self removeChildByTag:messageInit->collisionRock + 3 cleanup:YES];
            NSLog(@"Remove life for player 1");
        }
    
    } else if (message->messageType == kMessageTypeGameOver3) {
        MessageGameOver3 * messageGameOver = (MessageGameOver3 *) [data bytes];
        
        if (messageGameOver->player1Won) {
            [self endScene:kEndReasonLose3];
        } else {
            [self endScene:kEndReasonWin3];
        }
    }
}

#pragma mark UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [[GameManager sharedGameManager] runSceneWithID:kMainMenuScene];
    }
}
@end
