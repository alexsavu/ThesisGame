//
//  HelloWorldLayer.m
//  ThesisGame
//
//  Created by Alexandru Savu on 1/24/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "RootViewController.h"
#import "UIDevice+Hardware.h"
#import "BackgroundLayer.h"
#import "Player.h"
#import "Obstacle.h"
#import "CCShake.h"

#define kHeroMovementAction 1
#define kPlayerSpeed 300
#define kFilteringFactor 0.1
#define MIN_COURSE_X 173.0
#define MAX_COURSE_X 858.0

@interface HelloWorldLayer (){
    BOOL stop;
}
@property (nonatomic, strong) CCMenu *backToMainMenu;
@property (nonatomic, retain) CCLayer *currentLayer;
@property (nonatomic, retain) CCSprite *finish;

- (void)step:(ccTime)dt;

@end

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer
@synthesize background = _background;
@synthesize background2 = _background2;
@synthesize player = _player;
@synthesize obstacle = _obstacle;
@synthesize backToMainMenu = _backToMainMenu;
@synthesize finish = _finish;

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
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
		
//		// create and initialize a Label
//		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello World" fontName:@"Marker Felt" fontSize:64];
//
		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
//
//		// position the label on the center of the screen
//		label.position =  ccp( size.width /2 , size.height/2 );
//		
//		// add the label as a child to this Layer
//		[self addChild: label];

        
//        self.backgroundLayer = [BackgroundLayer node];
//        [self addChild:self.backgroundLayer z:0];
  
//        self.background = [CCSprite spriteWithFile:@"background.png"];
//        self.background.position = ccp(size.width/2, size.height/2);
//        [self addChild:self.background];
        
        
        stop = NO;
        
        //Add finish flag and make it invisible until we need to display it
        self.finish = [CCSprite spriteWithFile:@"finish.png"];
        self.finish.position = ccp(size.width/2, size.height/2);
        self.finish.visible = NO;
        [self addChild:self.finish z:100];
        
        //Adding the backgrounds as a sprite
        self.background = [CCSprite spriteWithFile:@"Prototype1Background.png"];
        self.background.anchorPoint = ccp(0, 0);
        self.background.position = ccp(0, 0);
        [self addChild:self.background z:0 tag:1];
        
        self.background2 = [CCSprite spriteWithFile:@"Prototype1Background.png"];
        self.background2.anchorPoint = ccp(0, 0);
        self.background2.position = ccp(0, self.background.boundingBox.size.height);
        [self addChild:self.background2 z:0 tag:2 ];
        
        //Add the player character. It has it's own class derived from GameCharacter
        self.player = [[Player alloc] initWithFile:@"PrototypeCharacter_nonClip.png" alphaThreshold:0];
        [self.player setPosition:ccp(size.height/2, size.width/2)];
        [self addChild:self.player z:0 tag:3];
        
        //The method that gets called to find a match between 2 players
//        AppController * delegate = (AppController *) [UIApplication sharedApplication].delegate;
//        [[GCHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:delegate.director delegate:self];
        
        //enable accelerometer
        self.isAccelerometerEnabled = YES;
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:1/60];
        
        //This are the functions that will be scheduled to load continuously
        //as long as our game is running
        [self schedule:@selector(step:)];
        [self schedule:@selector(obstaclesStep:) interval:2.0];
        
        ourRandom = arc4random();
        [self setGameState:kGameStateWaitingForMatch];
        
        [self addBackButton];
	}
	return self;
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
    [self addChild:self.backToMainMenu z:0 tag:kMainMenuTagValue];
}

//Selector method for going back to main menu
-(void)goBackToMenu:(CCMenuItemFont*)itemPassedIn {
    CCLOG(@"Tag 1 found, Scene 1");
    [[GameManager sharedGameManager] runSceneWithID:kMainMenuScene];
}


//when the authentication has changed restart this scene
- (void)restartTapped:(id)sender {
    // Reload the current scene
    [[CCDirector sharedDirector] replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:[HelloWorldLayer scene]]];
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

- (void)sendRandomNumber {
    
    MessageRandomNumber message;
    message.message.messageType = kMessageTypeRandomNumber;
    message.randomNumber = ourRandom;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageRandomNumber)];
    [self sendData:data];
}

- (void)sendGameBegin {
    
    MessageGameBegin message;
    message.message.messageType = kMessageTypeGameBegin;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameBegin)];
    [self sendData:data];
    
}

- (void)sendGameOver:(BOOL)player1Won {
    
    MessageGameOver message;
    message.message.messageType = kMessageTypeGameOver;
    message.player1Won = player1Won;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameOver)];
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
	
	//set the maximun and minimum positions where our character could be on screen
	CGSize thing_size = self.player.contentSize;
    CGSize background_size = self.background.contentSize;
    float max_x = 0;
	float min_x = 0;
    float max_y = 0;
	float min_y = 0;
    
    float background_max_x = 0;
	float background_min_x = 0;
    
    float background_max_y = 0;
	float background_min_y = 0;
    
    float background2_min_y = 0;
    
    if([[[UIDevice currentDevice] platform] isEqualToString:@"iPad 4 (WiFi)"]) {
        //Device is ipad
        max_x = 858.0 - thing_size.width/2;
        min_x = 173.0 + thing_size.width/2;
        
        background_max_x = 2048 - background_size.width/2;
        background_min_x = 0 + background_size.width/2;
        
        max_y = 768 - thing_size.width/2;
        min_y = 0 + thing_size.width/2;
        
        background_max_y = 1536 - background_size.height/2;
        background_min_y = 0; //+ background_size.height/2;
        background2_min_y = 0;
    }else{
        //Device is iphone
        max_x = 480 - thing_size.width/2;
        min_x = 0 + thing_size.width/2;
        
        max_y = 320 - thing_size.width/2;
        min_y = 0 + thing_size.width/2;
    }
	
	if(thing_pos.x>max_x) thing_pos.x = max_x;
	if(thing_pos.x<min_x) thing_pos.x = min_x;
    
//    if(thing_pos.y>max_y) thing_pos.y = max_y;
//	if(thing_pos.y<min_y) thing_pos.y = min_y;
    
//    if(background_pos.y>background_max_y) background_pos.y = background_max_y;
//	if(background_pos.y<background_min_y) background_pos.y = background_min_y;
    
//	if(background2_pos.y<background2_min_y) background2_pos.y = background2_min_y;
    
    
//    if(background2_pos.x>background_max_x) background2_pos.x = background_max_x;
//	if(background_pos.x<background_min_x) background_pos.x = background_min_x;
//    
//    if(background2_pos.y>background_max_y) background2_pos.y = background_max_y;
//	if(background2_pos.y<background_min_y) background2_pos.y = background_min_y;
    
    thing_vel.x += thing_acc.x * dt;
	thing_pos.x += thing_vel.x * dt;
    
    if (background_vel.y > 0 && background2_vel.y > 0) {
        background_vel.y += background_acc.y * dt;
        background_pos.y += background_vel.y * dt;
        
        background2_vel.y += background2_acc.y * dt;
        background2_pos.y += background2_vel.y * dt;
    }
//	NSLog(@"Thing position y: %f", thing_pos.x);
    
    self.player.position = ccp(thing_pos.x, thing_pos.y);
    self.background.position = ccp(0, -background_pos.y);
    self.background2.position = ccp(0, self.background.position.y + 768.0);
    
    //up scroll
    [self scrollUpwards];
    
    //collision method
    [self checkForCollision];
}

#pragma mark Collision Detection

-(void)checkForCollision{
    if ([(KKPixelMaskSprite *)[self getChildByTag:4] pixelMaskIntersectsNode:(KKPixelMaskSprite *)[self getChildByTag:3]]) {
        NSLog(@"@@@@@@@@@@@@: %@", [self getChildByTag:3]);
        [[self getChildByTag:4] runAction:[CCShake actionWithDuration:1.f amplitude:ccp(0, 5) ]];
    }
}

#pragma mark Obstacles

-(void)addObstacles{
    
    self.obstacle = [[Obstacle alloc] initWithFile:@"prototypeObstacle.png" alphaThreshold:0];
    // Determine where to spawn the target along the Y axis
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int minX = MIN_COURSE_X + self.obstacle.contentSize.width/2;
    int maxX = MAX_COURSE_X - self.obstacle.contentSize.width/2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    // Create the target slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    self.obstacle.position = ccp(actualX ,winSize.height + (self.obstacle.contentSize.height/2));
    [self addChild:self.obstacle z:0 tag:4];
    
    // Determine speed of the target
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    id actionMove = [CCMoveTo actionWithDuration:actualDuration
                                        position:ccp(actualX ,-self.obstacle.contentSize.height)];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self
                                             selector:@selector(spriteMoveFinished:)];
    [self.obstacle runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    NSLog(@"Thing position y: %f", self.obstacle.position.y);
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

#pragma mark Scroll Background Method

//very dirty method to scroll the background.
//TODO: will have to change it

-(void)scrollUpwards{
    
    //the other way
    if (self.background.position.y < -self.background.boundingBox.size.height) {
        self.background.position = ccp(0, self.background2.position.y + self.background2.boundingBox.size.height);
    }
    
    if (self.background2.position.y + self.background2.boundingBox.size.height < 0) {
        self.background2.position = ccp(0, self.background.position.y + self.background.boundingBox.size.height);
    }
    
    if (self.background2.position.y < 0) {
        self.background.position = ccp(0, self.background2.position.y + self.background2.boundingBox.size.height);
    }

    if (self.background2.position.y + self.background2.boundingBox.size.height < 0) {
        self.background2.position = ccp(0, self.background.position.y + self.background.boundingBox.size.height);
    }
    
    if (self.background2.position.y < 0) {
        self.background.position = ccp(0, self.background2.position.y + self.background2.boundingBox.size.height);
    }
    
    if (self.background2.position.y + self.background2.boundingBox.size.height < 0) {
        self.background2.position = ccp(0, self.background.position.y + self.background.boundingBox.size.height);
    }
    
    if (self.background2.position.y < 0) {
        self.background.position = ccp(0, self.background2.position.y + self.background2.boundingBox.size.height);
    }
    
    if (self.background2.position.y + self.background2.boundingBox.size.height < 0) {
        self.background2.position = ccp(0, self.background.position.y + self.background.boundingBox.size.height);
    }
    
    if (self.background2.position.y < 0) {
        self.background.position = ccp(0, self.background2.position.y + self.background2.boundingBox.size.height);
    }
    
    if (self.background2.position.y + self.background2.boundingBox.size.height < 0) {
        self.background2.position = ccp(0, self.background.position.y + self.background.boundingBox.size.height);
    }
    
    if (self.background2.position.y < 0) {
        self.background.position = ccp(0, self.background2.position.y + self.background2.boundingBox.size.height);
    }
    
    if (self.background2.position.y + self.background2.boundingBox.size.height < 0) {
        self.background2.position = ccp(0, self.background.position.y + self.background.boundingBox.size.height);
    }
    
    if (self.background2.position.y < 0) {
        self.background.position = ccp(0, self.background2.position.y + self.background2.boundingBox.size.height);
    }
    
    if (self.background2.position.y + self.background2.boundingBox.size.height < 0) {
        self.background2.position = ccp(0, self.background.position.y + self.background.boundingBox.size.height);
    }
    
    if (self.background2.position.y < 0) {
        self.background.position = ccp(0, self.background2.position.y + self.background2.boundingBox.size.height);
        stop = YES;
    }
    
    if(stop && self.background2.position.y < -768.0){
        self.background.position = ccp(0, 0);
        [self finishFlagSprite];
    }
}

//Add finish sprite
-(void)finishFlagSprite{
    self.finish.visible = YES;
}

- (void)tryStartGame {
    
    if (isPlayer1 && gameState == kGameStateWaitingForStart) {
        [self setGameState:kGameStateActive];
        [self sendGameBegin];
    }
    
}

#pragma mark Accelerometer

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
	float accel_filter = 0.1f;
	//handle our character on-screen via accelerometer
	thing_vel.x = thing_vel.x * accel_filter - acceleration.y * (1.0f - accel_filter) * 500.0f;
    thing_vel.y = thing_vel.y * accel_filter + acceleration.x * (1.0f - accel_filter) * 500.0f;
    
    background_vel.y = background_vel.y * accel_filter + acceleration.x * (1.0f - accel_filter) * 1500.0f;
    background2_vel.y = background2_vel.y * accel_filter + acceleration.x * (1.0f - accel_filter) * 1500.0f;
    
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

- (void)setGameState:(GameState)state {
    
    gameState = state;
    if (gameState == kGameStateWaitingForMatch) {
//        [debugLabel setString:@"Waiting for match"];
        CCLOG(@"Waiting for match");
    } else if (gameState == kGameStateWaitingForRandomNumber) {
//        [debugLabel setString:@"Waiting for rand #"];
        CCLOG(@"Waiting for rand #");
    } else if (gameState == kGameStateWaitingForStart) {
//        [debugLabel setString:@"Waiting for start"];
        CCLOG(@"Waiting for start");
    } else if (gameState == kGameStateActive) {
//        [debugLabel setString:@"Active"];
        CCLOG(@"Active");
    } else if (gameState == kGameStateDone) {
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
        [self setGameState:kGameStateWaitingForStart];
    } else {
        [self setGameState:kGameStateWaitingForRandomNumber];
    }
    [self sendRandomNumber];
    [self tryStartGame];
}

- (void)matchEnded {
    CCLOG(@"Match ended");
    
    [[GCHelper sharedInstance].match disconnect];
    [GCHelper sharedInstance].match = nil;
//    [self endScene:kEndReasonDisconnect];
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    CCLOG(@"Received data");
    
    // Store away other player ID for later
    if (otherPlayerID == nil) {
        otherPlayerID = playerID;
    }
    
    Message *message = (Message *) [data bytes];
    if (message->messageType == kMessageTypeRandomNumber) {
        
        MessageRandomNumber * messageInit = (MessageRandomNumber *) [data bytes];
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
            if (gameState == kGameStateWaitingForRandomNumber) {
                [self setGameState:kGameStateWaitingForStart];
            }
            [self tryStartGame];
        }
        
    } else if (message->messageType == kMessageTypeGameBegin) {
        
        [self setGameState:kGameStateActive];
        
    } else if (message->messageType == kMessageTypeMove) {
        
        CCLOG(@"Received move");
        
        if (isPlayer1) {
//            [player2 moveForward];
        } else {
//            [player1 moveForward];
        }
    } else if (message->messageType == kMessageTypeGameOver) {
        
        MessageGameOver * messageGameOver = (MessageGameOver *) [data bytes];
        CCLOG(@"Received game over with player 1 won: %d", messageGameOver->player1Won);
        
        if (messageGameOver->player1Won) {
//            [self endScene:kEndReasonLose];
        } else {
//            [self endScene:kEndReasonWin];    
        }
        
    }
}
@end
