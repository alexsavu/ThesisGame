//
//  AvoidMultiplayerLayer.m
//  ThesisGame
//
//  Created by Alex Savu on 4/13/13.
//
//

#import "AvoidMultiplayerLayer.h"
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

@interface AvoidMultiplayerLayer (){
    BOOL stop;
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
@property (nonatomic, retain) CCSprite *finish;
@property (nonatomic, weak) NSString *avatar;
@property (nonatomic, weak) NSString *otherAvatar;
@property (nonatomic, weak) CCSprite *scorePlayerOne;
@property (nonatomic, weak) CCSprite *scorePlayerTwo;

- (void)step:(ccTime)dt;

@end

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation AvoidMultiplayerLayer
@synthesize background = _background;
@synthesize background2 = _background2;
@synthesize player1 = _player1;
@synthesize player2 = _player2;
@synthesize obstacle = _obstacle;
@synthesize backToMainMenu = _backToMainMenu;
@synthesize finish = _finish;
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
	AvoidMultiplayerLayer *layer = [AvoidMultiplayerLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		
		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        stop = NO;
        scoreCounter = [[ScoreCounter alloc] init];
        
        counterForObstacles = 1;
        
        //Preload sound effects
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"dropRock.mp3"];
        
        //chosen avatar is retrieved from userDefaults
        NSUserDefaults *savedAvatar = [NSUserDefaults standardUserDefaults];
        avatarInt = [savedAvatar integerForKey:@"chosenAvatar"];
        CCLOG(@"chosenAvatar %i", avatarInt);
        self.avatar = [self chosenAvatar:avatarInt];
        
        CCLOG(@"avatar chosen is: %@", self.avatar);
        
        //Add finish flag and make it invisible until we need to display it
        self.finish = [CCSprite spriteWithFile:@"finish.png"];
        self.finish.position = ccp(size.width/2, size.height/2);
        self.finish.visible = NO;
        [self addChild:self.finish z:100];
        
        //Adding the backgrounds as a sprite
        self.background = [CCSprite spriteWithFile:@"Prototype1Background.png"];
        self.background.anchorPoint = ccp(0, 0);
        self.background.position = ccp(0, 0);
        [self addChild:self.background];
        
        self.background2 = [CCSprite spriteWithFile:@"Prototype1Background.png"];
        self.background2.anchorPoint = ccp(0, 0);
        self.background2.position = ccp(0, self.background.boundingBox.size.height);
        [self addChild:self.background2];
        
        //Initialize score images
        self.scorePlayerOne = [CCSprite spriteWithFile:@"collectBlue.png"];
        self.scorePlayerOne.visible = NO;
        self.scorePlayerOne.position = ccp(74.f, size.height/2);
        [self addChild:self.scorePlayerOne];
        
        self.scorePlayerTwo = [CCSprite spriteWithFile:@"collectGreen.png"];
        self.scorePlayerTwo.visible = NO;
        self.scorePlayerTwo.position = ccp(size.width - 74.f, size.height/2);
        [self addChild:self.scorePlayerTwo];
        
        //Initialize labels for scores
        labelScorePlayerOne = [CCLabelBMFont labelWithString:@"0" fntFile:@"magneto.fnt"];
        labelScorePlayerOne.position = ccp(80.f, size.height/2 - 10.f);
        labelScorePlayerOne.visible = NO;
        [labelScorePlayerOne setScale:2.5];
        [self addChild:labelScorePlayerOne];
        
        labelScorePlayerTwo = [CCLabelBMFont labelWithString:@"0" fntFile:@"magneto.fnt"];
        labelScorePlayerTwo.position = ccp(size.width - 70.f, size.height/2 - 10.f);
        labelScorePlayerTwo.visible = NO;
        [labelScorePlayerTwo setScale:2.5];
        [self addChild:labelScorePlayerTwo];
        
        
        //Alternative player sprite allocation with unique avatar
        
        //Add the player character. It has it's own class derived from GameCharacter
        //self.avatar is set by player's choice.
        self.player1 = [[Player alloc] initWithFile:@"Char2~ipad.png" alphaThreshold:0];
        //self.player1 = [Player alloc];
        [self.player1 setPosition:ccp(size.height/2, size.width/2)];
        [self addChild:self.player1 z:0 tag:0];
        //self.player1.id = 1
        
        //TODO: The avatar information here should come with a message from the other player in a multipl. setting.
        //TODO: Make sure to update avatars for both players once match is started.
        self.player2 = [[Player alloc] initWithFile:@"Char1~ipad.png" alphaThreshold:0];
        //self.player2 = [Player alloc];
        [self.player2 setPosition:ccp(size.height/2, size.width/2)];
        [self addChild:self.player2 z:0 tag:1];
        
        
        //The method that gets called to find a match between 2 players
        AppController * delegate = (AppController *) [UIApplication sharedApplication].delegate;
        [[GCHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:delegate.director delegate:self];
        
        //enable accelerometer
        self.isAccelerometerEnabled = YES;
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:1/60];
        
//        //This are the functions that will be scheduled to load continuously
//        //as long as our game is running
//        [self schedule:@selector(step:)];
//        [self schedule:@selector(obstaclesStep:) interval:2.0];
//        [self schedule:@selector(scroll:) interval:0.0000000001];
        
        ourRandom = arc4random();
        [self setGameState:kGameStateWaitingForMatch2];
        
//        self.scale = 0.4;
        
        [self addBackButton];
        [self addLivesPlayer1];
        [self addLivesPlayer2];
	}
	return self;
}

-(void)addLivesPlayer1{
    static int padding = 1;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    for(int i = 0; i < 5; i++) {
        // Create star and add it to the layer
        CCSprite *star = [CCSprite spriteWithFile:@"avoidHeart.png"];
        int xOffset = padding+(int)(star.contentSize.width/2+((star.contentSize.width+padding)*(i/2))); // or /cols to fill cols first
        int yOffset = padding+(int)(winSize.height/2-((star.contentSize.width+padding)*(i%2))); // or %cols to fill cols first
        star.position = ccp(50 + xOffset, yOffset);
        NSLog(@"X Offset: %i", xOffset);
        NSLog(@"Y Offset: %i", yOffset);
        star.tag = i + 3; // use i here if you like
        [self addChild:star];
    }
}

-(void)addLivesPlayer2{
    static int padding = 1;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    for(int i = 0; i < 5; i++) {
        // Create star and add it to the layer
        CCSprite *star = [CCSprite spriteWithFile:@"avoidHeart.png"];
        int xOffset = padding+(int)(star.contentSize.width/2+((star.contentSize.width+padding)*(i/2))); // or /cols to fill cols first
        int yOffset = padding+(int)(winSize.height/2-((star.contentSize.width+padding)*(i%2))); // or %cols to fill cols first
        star.position = ccp(900 + xOffset, yOffset);
        NSLog(@"X Offset: %i", xOffset);
        NSLog(@"Y Offset: %i", yOffset);
        star.tag = i + 8; // use i here if you like
        [self addChild:star];
    }
}

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
- (NSString*) chosenAvatar: (NSInteger) value {
    NSString *avatarString = [[NSString alloc] init];
    switch(value)
    {
        case 1:
            //self.avatar = @"Char1~ipad.png";
            avatarString = @"Char1~ipad.png";
            break;
        case 2:
            //self.avatar = @"Char2~ipad.png";
            avatarString = @"Char2~ipad.png";
            break;
        case 3:
            //self.avatar = @"Char3~ipad.png";
            avatarString = @"Char3~ipad.png";
            break;
        case 4:
            //self.avatar = @"Char4~ipad.png";
            avatarString = @"Char4~ipad.png";
            break;
        case 5:
            //self.avatar = @"Char5~ipad.png";
            avatarString = @"Char5~ipad.png";
            break;
    }
    
    return avatarString;
}

#pragma Back to Main Menu

//Back to main menu button
- (void)addBackButton{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    CCMenuItemImage *backArrow = [CCMenuItemImage
                                  itemWithNormalImage:@"backButton.png"
                                  selectedImage:nil
                                  disabledImage:nil
                                  target:self
                                  selector:@selector(goBackToMenu:)];
    
    self.backToMainMenu = [CCMenu
                           menuWithItems:backArrow,nil];
    [self.backToMainMenu setPosition:ccp(55.f,screenSize.height - 55.f)];
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
    [[CCDirector sharedDirector] replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:[AvoidMultiplayerLayer scene]]];
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
    
    MessageRandomNumber2 message;
    message.message.messageType = kMessageTypeRandomNumber2;
    message.randomNumber = ourRandom;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageRandomNumber2)];
    [self sendData:data];
}

//Send avatar number
- (void)sendAvatarNumber {
    MessageAvatarNumber2 message;
    message.message.messageType = kMessageTypeAvatarNumber2;
    message.avatarNumber = avatarInt;
    
    NSData *avatarData = [NSData dataWithBytes:&message length:sizeof(MessageAvatarNumber2)];
    [self sendData:avatarData];
}

- (void)sendGameBegin {
    MessageGameBegin2 message;
    message.message.messageType = kMessageTypeGameBegin2;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameBegin2)];
    [self sendData:data];
    
}

//Method to sent obstacle's position over the network
- (void)sendMoveWithObstaclePosition:(int)obstaclePositionOnXToSend andDuration:(int)duration{
    MessageMove2 message;
#warning Change message
    message.message.messageType = kMessageTypeObstaclePosition2;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageMove2)];
    NSData *dataWithObstaclePosition = [NSData dataWithBytes:&obstaclePositionOnXToSend length:sizeof(obstaclePositionOnXToSend)];
    NSData *dataWithObstacleDuration = [NSData dataWithBytes:&duration length:sizeof(duration)];
    [self sendData:data withObstaclePosition:dataWithObstaclePosition andDuration:dataWithObstacleDuration];
}

//Method to sent player's position over the network
- (void)sendMoveWithPositionOfPlayer1:(CGPoint)player1Position andPlayer2:(CGPoint)player2Position{
    MessageMove2 message;
    message.message.messageType = kMessageTypeMove2;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageMove2)];
    NSData *dataWithPlayer1Position = [NSData dataWithBytes:&player1Position length:sizeof(player1Position)];
    NSData *dataWithPlayer2Position = [NSData dataWithBytes:&player2Position length:sizeof(player2Position)];
    [self sendData:data withPlayer1Position:dataWithPlayer1Position andPlayer2Position:dataWithPlayer2Position];
}

// Adds methods to send move and game over messages
- (void)sendGameOver:(BOOL)player1Won {
    
    MessageGameOver2 message;
    message.message.messageType = kMessageTypeGameOver2;
    message.player1Won = player1Won;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameOver2)];
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
        //        NSLog(@"Position player 1: %f", thing_pos.x);
    }else{
        self.player2.position = ccp(thing2_pos.x, thing2_pos.y);
        //        NSLog(@"Position player 2: %f", thing2_pos.x);
    }
    
    if (gameState != kGameStateActive2) return;
    [self sendMoveWithPositionOfPlayer1:self.player1.position andPlayer2:self.player2.position];
    
    //collision method
    [self checkForCollision];
}

#pragma mark Collision Detection

-(void)checkForCollision{
    if ([(KKPixelMaskSprite *)[self getChildByTag:2] pixelMaskIntersectsNode:(KKPixelMaskSprite *)[self getChildByTag:0]]) {
        [scoreCounter substractLivesPlayer1];
        NSLog(@"@@@@@@@@@@@@: %i", scoreCounter.livesLeftPlayer1);
        [[self getChildByTag:2] setTag:110];
        [[self getChildByTag:110] runAction:[CCShake actionWithDuration:.5f amplitude:ccp(7, 0)]];
        [self removeChildByTag:scoreCounter.livesLeftPlayer1 + 3 cleanup:YES];
        [self updateWinning];
    }
    
    if ([(KKPixelMaskSprite *)[self getChildByTag:2] pixelMaskIntersectsNode:(KKPixelMaskSprite *)[self getChildByTag:1]]) {
        [scoreCounter substractLivesPlayer2];
        NSLog(@"!!!!!!!!!!!!!!!: %i", scoreCounter.livesLeftPlayer2);
        [[self getChildByTag:2] setTag:111];
        [[self getChildByTag:111] runAction:[CCShake actionWithDuration:.5f amplitude:ccp(7, 0)]];
        [self removeChildByTag:scoreCounter.livesLeftPlayer2 + 8 cleanup:YES];
        [self updateWinning];
    }
}

#pragma mark Score handling

-(void)updateWinning{
    if (scoreCounter.livesLeftPlayer1 == 0) {
        if (isPlayer1) {
            [self endScene:kEndReasonLose2];
        } else {
            [self endScene:kEndReasonWin2];
        }
    }else if (scoreCounter.livesLeftPlayer2 == 0){
        if (isPlayer1) {
            [self endScene:kEndReasonWin2];
        } else {
            [self endScene:kEndReasonLose2];
        }
    }
}

#pragma mark Obstacles

-(void)addObstacles{
//    if (isPlayer1) {
        self.obstacle = [[Obstacle alloc] initWithFile:@"prototypeObstacle.png" alphaThreshold:0];
        // Determine where to spawn the target along the Y axis
        CGSize winSize = [[CCDirector sharedDirector] winSize];
//        int minX = MIN_COURSE_X + self.obstacle.contentSize.width/2;
//        int maxX = MAX_COURSE_X - self.obstacle.contentSize.width/2;
//        int rangeX = maxX - minX;
//        int actualX = (arc4random() % rangeX) + minX;
    
//---------------------------

    int stupidX = 0;
    int stupidDuration = 0;
    if (counterForObstacles == 1) {
        stupidX = 300.0;
        stupidDuration = 2;
    }else if (counterForObstacles == 2){
        stupidX = 400.0;
        stupidDuration = 4;
    }else if (counterForObstacles == 3){
        stupidX = 500.0;
        stupidDuration = 2;
    }else if (counterForObstacles == 4){
        stupidX = 600.0;
        stupidDuration = 3;
    }else if (counterForObstacles == 5){
        stupidX = 700.0;
        stupidDuration = 4;
    }
    if (counterForObstacles < 5) {
        counterForObstacles += 1;
    }else{
        counterForObstacles = 1;
    }

        // Create the target slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        self.obstacle.position = ccp(stupidX ,winSize.height + (self.obstacle.contentSize.height/2));
        [self addChild:self.obstacle z:0 tag:5];
        
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
    id actionMove = [CCMoveTo actionWithDuration:stupidDuration
                                        position:ccp(stupidX ,-self.obstacle.contentSize.height)];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self
                                             selector:@selector(spriteMoveFinished:)];

//----------------------------------------------------------------------------------------
        
        [self.obstacle runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
//        [self sendMoveWithObstaclePosition:actualX andDuration:actualDuration];
//    }else{
//        self.obstacle = [[Obstacle alloc] initWithFile:@"prototypeObstacle.png" alphaThreshold:0];
//        // Determine where to spawn the target along the Y axis
//        CGSize winSize = [[CCDirector sharedDirector] winSize];
//        int minX = MIN_COURSE_X + self.obstacle.contentSize.width/2;
//        int maxX = MAX_COURSE_X - self.obstacle.contentSize.width/2;
//        int rangeX = maxX - minX;
//        int actualX = (arc4random() % rangeX) + minX;
//        
////---------------------------
//
////    int stupidX = 0;
////    int stupidDuration = 0;
////    if (counterForObstacles == 1) {
////        stupidX = 300.0;
////        stupidDuration = 2;
////    }else if (counterForObstacles == 2){
////        stupidX = 400.0;
////        stupidDuration = 4;
////    }else if (counterForObstacles == 3){
////        stupidX = 500.0;
////        stupidDuration = 2;
////    }else if (counterForObstacles == 4){
////        stupidX = 600.0;
////        stupidDuration = 3;
////    }else if (counterForObstacles == 5){
////        stupidX = 700.0;
////        stupidDuration = 4;
////    }
////    if (counterForObstacles < 5) {
////        counterForObstacles += 1;
////    }else{
////        counterForObstacles = 1;
////    }
//        
//        // Create the target slightly off-screen along the right edge,
//        // and along a random position along the Y axis as calculated above
//        self.obstacle.position = ccp(obstaclePositionOnXReceived ,winSize.height + (self.obstacle.contentSize.height/2));
//        [self addChild:self.obstacle z:0 tag:5];
//        
//        //-----------------------------------------
//        
//        // Determine speed of the target
//        int minDuration = 2.0;
//        int maxDuration = 4.0;
//        int rangeDuration = maxDuration - minDuration;
//        int actualDuration = (arc4random() % rangeDuration) + minDuration;
//        
//        // Create the actions
//        id actionMove = [CCMoveTo actionWithDuration:obstacleDurationReceived
//                                            position:ccp(obstaclePositionOnXReceived ,-self.obstacle.contentSize.height)];
//        id actionMoveDone = [CCCallFuncN actionWithTarget:self
//                                                 selector:@selector(spriteMoveFinished:)];
//        
////----------------------------------------------------------------------------------------
//
////    // Create the actions
////    id actionMove = [CCMoveTo actionWithDuration:stupidDuration
////                                        position:ccp(stupidX ,-self.obstacle.contentSize.height)];
////    id actionMoveDone = [CCCallFuncN actionWithTarget:self
////                                             selector:@selector(spriteMoveFinished:)];
//
////----------------------------------------------------------------------------------------
//        
//        [self.obstacle runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
//    }
    
}

//Remove onstacle after going out of screen
-(void)spriteMoveFinished:(id)sender {
    Obstacle *obstacle = (Obstacle *)sender;
    [self removeChild:obstacle cleanup:YES];
    
//	if (sprite.tag == 1) { // target
//		[_targets removeObject:sprite];
//
//		GameOverScene *gameOverScene = [GameOverScene node];
//		[gameOverScene.layer.label setString:@"You Lose :["];
//		[[CCDirector sharedDirector] replaceScene:gameOverScene];
//
//	} else if (sprite.tag == 2) { // projectile
//		[_projectiles removeObject:sprite];
//	}
}

//Add finish sprite
-(void)finishFlagSprite{
    self.finish.visible = YES;
}

- (void)tryStartGame {
    
    if (isPlayer1 && gameState == kGameStateWaitingForStart2) {
        [self setGameState:kGameStateActive2];
        
        //This are the functions that will be scheduled to load continuously
        //as long as our game is running
        [self schedule:@selector(step:)];
        [self schedule:@selector(obstaclesStep:) interval:2.0];
        [self schedule:@selector(scroll:) interval:0.0000000001];
        
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
- (void)endScene:(EndReason2)endReason {
    
    if (gameState == kGameStateDone2) return;
    [self setGameState:kGameStateDone2];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    NSString *message;
    if (endReason == kEndReasonWin2) {
        message = @"You win!";
    } else if (endReason == kEndReasonLose2) {
        message = @"You lose!";
    }
    
    CCLabelBMFont *label = [CCLabelBMFont labelWithString:message fntFile:@"magneto.fnt"];
    label.scale = 0.1;
    label.position = ccp(winSize.width/2, 180);
    [self addChild:label];
    
    CCLabelBMFont *restartLabel = [CCLabelBMFont labelWithString:@"Restart" fntFile:@"magneto.fnt"];
    
    CCMenuItemLabel *restartItem = [CCMenuItemLabel itemWithLabel:restartLabel target:self selector:@selector(restartTapped:)];
    restartItem.scale = 0.1;
    restartItem.position = ccp(winSize.width/2, 140);
    
    CCMenu *menu = [CCMenu menuWithItems:restartItem, nil];
    menu.position = CGPointZero;
    [self addChild:menu];
    
    [restartItem runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    [label runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    
    if (isPlayer1) {
        if (endReason == kEndReasonWin2) {
            [self sendGameOver:true];
        } else if (endReason == kEndReasonLose2) {
            [self sendGameOver:false];
        }
    }
    
}

- (void)setGameState:(GameState2)state {
    
    gameState = state;
    if (gameState == kGameStateWaitingForMatch2) {
        //        [debugLabel setString:@"Waiting for match"];
        CCLOG(@"Waiting for match");
    } else if (gameState == kGameStateWaitingForRandomNumber2) {
        //        [debugLabel setString:@"Waiting for rand #"];
        CCLOG(@"Waiting for rand #");
    } else if (gameState == kGameStateWaitingForAvatarNumber2) {
        CCLOG(@"Waiting for avatar #");
    } else if (gameState == kGameStateWaitingForStart2) {
        //        [debugLabel setString:@"Waiting for start"];
        CCLOG(@"Waiting for start");
    } else if (gameState == kGameStateActive2) {
        //        [debugLabel setString:@"Active"];
        CCLOG(@"Active");
    } else if (gameState == kGameStateDone2) {
        //        [debugLabel setString:@"Done"];
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
            [self setGameState:kGameStateWaitingForStart2];
        }
        else {
            [self setGameState:kGameStateWaitingForAvatarNumber2];
        }
    } else {
        [self setGameState:kGameStateWaitingForRandomNumber2];
    }
    [self sendRandomNumber];
    [self sendAvatarNumber];
    [self tryStartGame];
    
//    if (receivedRandom) {
//        [self setGameState:kGameStateWaitingForStart];
//    } else {
//        [self setGameState:kGameStateWaitingForRandomNumber];
//    }
//    [self sendRandomNumber];
//    [self tryStartGame];
}

- (void)matchEnded {
    CCLOG(@"Match ended");
    
    [[GCHelper sharedInstance].match disconnect];
    [GCHelper sharedInstance].match = nil;
    [self endScene:kEndReasonDisconnect2];
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    // Store away other player ID for later
    if (otherPlayerID == nil) {
        otherPlayerID = playerID;
    }
    
    Message2 *message = (Message2 *) [data bytes];
    if (message->messageType == kMessageTypeRandomNumber2) {
        
        MessageRandomNumber2 * messageInit = (MessageRandomNumber2 *) [data bytes];
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
            if (gameState == kGameStateWaitingForRandomNumber2) {
                [self setGameState:kGameStateWaitingForStart2];
            }
//            [self tryStartGame];
        }
        
        //checks the avatars chosen and assigns the right png. If both players have chosen the same avatar
        //the 'other' player is given a random one that is different from the local player's.
    } else if (message->messageType == kMessageTypeAvatarNumber2){
        MessageAvatarNumber2 * messageInit = (MessageAvatarNumber2 *) [data bytes];
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
                self.otherAvatar = [self chosenAvatar:messageInit->avatarNumber];
                CCLOG(@"self.otherAvatar is now, %@", self.otherAvatar);
                self.player1.texture = [[CCTextureCache sharedTextureCache] addImage:self.avatar];
                self.player2.texture = [[CCTextureCache sharedTextureCache] addImage:self.otherAvatar];
                
                receivedAvatar = YES;
                if (gameState == kGameStateWaitingForAvatarNumber2) {
                    [self setGameState:kGameStateWaitingForStart2];
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
                //Þessi inniheldur ekki fallið initWithFile. Ég get kannski bara skítamixað
                //fall í þessum klasa sem gerir það sama eða svipað og initWithFile?
                self.otherAvatar = [self chosenAvatar:messageInit->avatarNumber];
                CCLOG(@"self.otherAvatar is now, %@", self.otherAvatar);
                self.player1.texture = [[CCTextureCache sharedTextureCache] addImage:self.otherAvatar];
                self.player2.texture = [[CCTextureCache sharedTextureCache] addImage:self.avatar];
                
                receivedAvatar = YES;
                if (gameState == kGameStateWaitingForAvatarNumber2) {
                    [self setGameState:kGameStateWaitingForStart2];
                }
                [self tryStartGame];
                
            }
        }
        
        
    } else if (message->messageType == kMessageTypeGameBegin2) {
        
        [self setGameState:kGameStateActive2];
        
        //This are the functions that will be scheduled to load continuously
        //as long as our game is running
        [self schedule:@selector(step:)];
        [self schedule:@selector(obstaclesStep:) interval:2.0];
        [self schedule:@selector(scroll:) interval:0.0000000001];
        
    } else if (message->messageType == kMessageTypeMove2) {
        
        CGPoint *player1Position;
        CGPoint *player2Position;
        
//        NSLog(@"Player 1 pooooooooo: %@", data);
        
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
//            NSLog(@"Offsettttttttttt: %i", offset);
        } while (offset < length);
        
        if (isPlayer1) {
            self.player2.position = ccp(player2Position->x, player2Position->y);
//            NSLog(@"Position received player 2: %f", player2Position->y);
        } else {
            self.player1.position = ccp(player1Position->x, player1Position->y);
//            NSLog(@"Position received player 1: %f", player1Position->y);
            //            NSLog(@"Position received player 1: %f", thing_pos.x);
        }
    } else if (message->messageType == kMessageTypeGameOver2) {
        
        MessageGameOver2 * messageGameOver = (MessageGameOver2 *) [data bytes];
        CCLOG(@"Received game over with player 1 won: %d", messageGameOver->player1Won);
        
        if (messageGameOver->player1Won) {
            [self endScene:kEndReasonLose2];
        } else {
            [self endScene:kEndReasonWin2];
        }
        
    }else if (message->messageType == kMessageTypeObstaclePosition2){
        NSLog(@"Obstavle position :)))) : %@", data);
        
        NSUInteger length = [data length];
        NSUInteger chunkSize = sizeof(obstaclePositionOnXReceived);
        NSUInteger offset = 0;
        do {
            NSUInteger thisChunkSize = length - offset > chunkSize ? chunkSize : length - offset;
            NSData* chunk = [NSData dataWithBytesNoCopy:(char *)[data bytes] + offset
                                                 length:thisChunkSize
                                           freeWhenDone:NO];
            offset += thisChunkSize;
            // do something with chunk
            if (offset == 8) {
                obstaclePositionOnXReceived = (int)[chunk bytes];
            }
            if (offset == 12) {
                obstacleDurationReceived = (int) [chunk bytes];
            }

            NSLog(@"Offsettttttttttt: %i", offset);
        } while (offset < length);
    }
}

#pragma mark UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [[GameManager sharedGameManager] runSceneWithID:kMainMenuScene];
    }
}
@end
