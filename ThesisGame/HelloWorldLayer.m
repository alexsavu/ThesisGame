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

#define kHeroMovementAction 1
#define kPlayerSpeed 300
#define kFilteringFactor 0.1

@interface HelloWorldLayer (){
}

@property (nonatomic) BOOL stop;
- (void)step:(ccTime)dt;

@end

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer
//@synthesize redCircle = _redCircle;
@synthesize backgroundLayer = _backgroundLayer;
@synthesize background = _background;
@synthesize background2 = _background2;
@synthesize player = _player;

@synthesize stop = _stop;

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
//		
//		
//		
//		//
//		// Leaderboards and Achievements
//		//
//		
//		// Default font size will be 28 points.
//		[CCMenuItemFont setFontSize:28];
//		
//		// Achievement Menu Item using blocks
//		CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:^(id sender) {
//			
//			
//			GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
//			achivementViewController.achievementDelegate = self;
//			
//			AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
//			
//			[[app navController] presentModalViewController:achivementViewController animated:YES];
//		}
//									   ];
//
//		// Leaderboard Menu Item using blocks
//		CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {
//			
//			
//			GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
//			leaderboardViewController.leaderboardDelegate = self;
//			
//			AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
//			
//			[[app navController] presentModalViewController:leaderboardViewController animated:YES];
//		}
//									   ];
//		
//		CCMenu *menu = [CCMenu menuWithItems:itemAchievement, itemLeaderboard, nil];
//		
//		[menu alignItemsHorizontallyWithPadding:20];
//		[menu setPosition:ccp( size.width/2, size.height/2 - 50)];
//		
//		// Add the menu to the layer
//		[self addChild:menu];
        
//        self.backgroundLayer = [BackgroundLayer node];
//        [self addChild:self.backgroundLayer z:0];
        
        
        
//        self.background = [CCSprite spriteWithFile:@"background.png"];
//        self.background.position = ccp(size.width/2, size.height/2);
//        [self addChild:self.background];
        
        
        self.stop = NO;
        
        self.background = [CCSprite spriteWithFile:@"background.png"];
        self.background.anchorPoint = ccp(0, 0);
        self.background.position = ccp(0, 0);
        [self addChild:self.background];
        
        self.background2 = [CCSprite spriteWithFile:@"redBackground.png"];
        self.background2.anchorPoint = ccp(0, 1);
        self.background2.position = ccp(0 , -self.background.boundingBox.size.height);
        NSLog(@"Come On :%f", self.background2.boundingBox.size.height);
        [self addChild:self.background2];
        
        AppController * delegate = (AppController *) [UIApplication sharedApplication].delegate;
        [[GCHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:delegate.director delegate:self];
        
        self.isAccelerometerEnabled = YES;
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:1/60];
        
        self.player = [[Player alloc] initWithFile:@"dpadDown.png"];
        [self.player setPosition:ccp(size.height/2, size.width/2)];
        [self addChild:self.player];
        
        //This is the function that will be scheduled to load continuously
        //as long as our game is running
        [self schedule:@selector(step:)];
        
        ourRandom = arc4random();
        [self setGameState:kGameStateWaitingForMatch];

	}
	return self;
}

- (void)restartTapped:(id)sender {
    
    // Reload the current scene
    [[CCDirector sharedDirector] replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:[HelloWorldLayer scene]]];
    
}

//Invite
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

//the function schedule and call everything as needed
- (void)step:(ccTime)dt {    
	thing_pos.x += thing_vel.x * dt;
//    background_pos.x += background_vel.x *dt;
	
	//set the maximun and minimum positions where our character could be on screen
	//in the X axis... this prevents the character to go out of screen on the sides
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
        max_x = 1024 - thing_size.width/2;
        min_x = 0 + thing_size.width/2;
        
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
    
    if(thing_pos.y>max_y) thing_pos.y = max_y;
	if(thing_pos.y<min_y) thing_pos.y = min_y;
    
    if(background_pos.y>background_max_y) background_pos.y = background_max_y;
	if(background_pos.y<background_min_y) background_pos.y = background_min_y;
    
	if(background2_pos.y<background2_min_y) background2_pos.y = background2_min_y;
    
    
//    if(background2_pos.x>background_max_x) background2_pos.x = background_max_x;
//	if(background_pos.x<background_min_x) background_pos.x = background_min_x;
//    
//    if(background2_pos.y>background_max_y) background2_pos.y = background_max_y;
//	if(background2_pos.y<background_min_y) background2_pos.y = background_min_y;
	
	thing_vel.y += thing_acc.y * dt;
//	thing_pos.y += thing_vel.y * dt;
    
    thing_vel.x += thing_acc.x * dt;
	thing_pos.x += thing_vel.x * dt;
    
    
    if (background_vel.y > 0 && background2_vel.y > 0) {
        background_vel.y += background_acc.y * dt;
        background_pos.y += background_vel.y * dt;
        
        background_vel.x += background_acc.x * dt;
        //	background_pos.x += background_vel.x * dt;
        
        
        background2_vel.y += background2_acc.y * dt;
        background2_pos.y += background2_vel.y * dt;
        
        background2_vel.x += background2_acc.x * dt;
        //	background_pos.x += background_vel.x * dt;
    }
	
    self.player.position = ccp(thing_pos.x, thing_pos.y);
    self.background.position = ccp(0 ,background_pos.y);
    
    self.background2.position = ccp(0 ,background2_pos.y);
    
//    self.scale = 0.4;
    
#pragma mark continious background
    
    //up scroll
    [self scrollUpwards];
}

//very dirty method to scroll the background.
//TODO: will have to change it

-(void)scrollUpwards{
    if (self.background.position.y > self.background.boundingBox.size.height) {
        self.background.position = ccp(0, self.background2.position.y - (self.background2.boundingBox.size.height * 2));
    }
    
    if (self.background2.position.y > 1536.0) {
        self.background2.position = ccp(0, self.background2.position.y - (self.background2.boundingBox.size.height * 2));
    }
    
    if (self.background.position.y > self.background.boundingBox.size.height) {
        self.background.position = ccp(0, self.background2.position.y - (self.background2.boundingBox.size.height * 2));
    }
    
    if (self.background2.position.y > 1536.0) {
        self.background2.position = ccp(0, self.background2.position.y - (self.background2.boundingBox.size.height * 2));
    }
    
    if (self.background.position.y > self.background.boundingBox.size.height) {
        self.background.position = ccp(0, self.background2.position.y - (self.background2.boundingBox.size.height * 2));
    }
    
    if (self.background2.position.y > 1536.0) {
        self.background2.position = ccp(0, self.background2.position.y - (self.background2.boundingBox.size.height * 2));
        self.stop = YES;
    }
    
    if(self.stop && self.background2.position.y > 768.0){
        self.background2.position = ccp(0, 768.0);
    }
}

- (void)tryStartGame {
    
    if (isPlayer1 && gameState == kGameStateWaitingForStart) {
        [self setGameState:kGameStateActive];
        [self sendGameBegin];
    }
    
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
	float accel_filter = 0.1f;
	//handle our character on-screen via accelerometer
	thing_vel.x = thing_vel.x * accel_filter - acceleration.y * (1.0f - accel_filter) * 500.0f;
    thing_vel.y = thing_vel.y * accel_filter + acceleration.x * (1.0f - accel_filter) * 500.0f;
    
//    background_vel.x = background_vel.x * accel_filter - acceleration.y * (1.0f - accel_filter) * 500.0f;
    background_vel.y = background_vel.y * accel_filter + acceleration.x * (1.0f - accel_filter) * 500.0f;
    
//    background2_vel.x = background2_vel.x * accel_filter - acceleration.y * (1.0f - accel_filter) * 500.0f;
    background2_vel.y = background2_vel.y * accel_filter + acceleration.x * (1.0f - accel_filter) * 500.0f;
    
    NSLog(@"Accelerometer: %f", background2_vel.y);
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
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
