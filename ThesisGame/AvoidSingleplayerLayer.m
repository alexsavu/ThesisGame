//
//  AvoidSingleplayerLayer.m
//  ThesisGame
//
//  Created by Alex Savu on 4/13/13.
//
//

#import "AvoidSingleplayerLayer.h"
#import "AppDelegate.h"
#import "Player.h"
#import "CCShake.h"
#import "Obstacle.h"
#import "ScoreCounter.h"
#import "SimpleAudioEngine.h"

#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad
#define kHeroMovementAction 1
#define kPlayerSpeed 300
#define kFilteringFactor 0.1
#define MIN_COURSE_X 173.0
#define MAX_COURSE_X 858.0

@interface AvoidSingleplayerLayer (){
    NSInteger avatarInt;
    ScoreCounter *scoreCounter;
    NSInteger timeStartGame;
    CCLabelBMFont *countdown;
}
@property (nonatomic, strong) CCMenu *backToMainMenuFromScene2;
@property (nonatomic, strong) Obstacle *collectable;
@property (nonatomic, weak) NSString *avatar;
@property (nonatomic, strong) CCSpriteBatchNode *spriteSheet;

-(void)addObstaclesAvoidSingleplayer;
-(NSString*)chosenAvatar:(NSInteger)value selected:(BOOL)isSelected;
-(void)updateWinningCondition;
-(void)endScene:(EndReasonAvoidSingleplayer)endReason;
-(void)displayLabelFont:(int)displayNumber withScaleing:(BOOL)scale;
//Scheduled methods
-(void)step:(ccTime)dt;
-(void)secondsPassedInGame:(ccTime)dt;
-(void)obstaclesStepAvoidSingleplayer:(ccTime)dt;
@end

@implementation AvoidSingleplayerLayer
@synthesize background = _background;
@synthesize background2 = _background2;
@synthesize player = _player;
@synthesize obstacle = _obstacle;
@synthesize backToMainMenuFromScene2 = _backToMainMenuFromScene2;
@synthesize avatar = _avatar;


@synthesize collectable = _collectable;

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	AvoidSingleplayerLayer *layer = [AvoidSingleplayerLayer node];
	
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
        scoreCounter = [[ScoreCounter alloc] init];
        
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        
        //chosen avatar is retrieved from userDefaults
        NSUserDefaults *savedAvatar = [NSUserDefaults standardUserDefaults];
        avatarInt = [savedAvatar integerForKey:@"chosenAvatar"];
        self.avatar = [self chosenAvatar:avatarInt selected:NO];
        
        timeStartGame = 3;
        
        //Preload sound effects
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"dropRock.mp3"];
        
        //Adding the backgrounds as a sprite
        self.background = [CCSprite spriteWithFile:@"spaceBackground~ipad.png"];
        self.background.anchorPoint = ccp(0, 0);
        self.background.position = ccp(0, 0);
        [self addChild:self.background];
        
        self.background2 = [CCSprite spriteWithFile:@"spaceBackground~ipad.png"];
        self.background2.anchorPoint = ccp(0, 0);
        self.background2.position = ccp(0, self.background.boundingBox.size.height);
        [self addChild:self.background2];
        
        //enable accelerometer
        self.isAccelerometerEnabled = YES;
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:1/60];
        
        //This are the functions that will be scheduled to load continuously
        //as long as our game is running
        [self schedule:@selector(countdownStartGame:) interval:1.5];
        
        [self addBackButton];
        [self addLives];
	}
	return self;
}

-(void)addLives{
    static int padding = 1;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    for(int i = 0; i < 5; i++) {
        // Create star and add it to the layer
        CCSprite *star = [CCSprite spriteWithFile:@"avoidHeart.png"];
        int xOffset = padding+(int)(star.contentSize.width/2+((star.contentSize.width+padding)*(i/2))); // or /cols to fill cols first
        int yOffset = padding+(int)(winSize.height/2-((star.contentSize.width+padding)*(i%2))); // or %cols to fill cols first
        star.position = ccp(50 + xOffset, yOffset);
        star.tag = i + 3; // use i here if you like
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
    
    self.backToMainMenuFromScene2 = [CCMenu menuWithItems:backButton,nil];
    [self.backToMainMenuFromScene2 setPosition:ccp(70.f,screenSize.height - 55.f)];
    //TODO: change tag value because is the same as the main menu
    [self addChild:self.backToMainMenuFromScene2 z:0 tag:kMainMenuTagValue];
}

//Selector method for going back to main menu
-(void)goBackToMenu:(CCMenuItemFont*)itemPassedIn {
    CCLOG(@"Tag 1 found, Scene 2");
    [[GameManager sharedGameManager] runSceneWithID:kSingleplayerSceneSelection];
}

#pragma mark Obstacles

-(void)addObstaclesAvoidSingleplayer{
    
    self.obstacle = [[Obstacle alloc] initWithFile:@"prototypeObstacle.png"];
    // Determine where to spawn the target along the Y axis
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int minX = MIN_COURSE_X + self.obstacle.contentSize.width/2;
    int maxX = MAX_COURSE_X - self.obstacle.contentSize.width/2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    // Create the target slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    self.obstacle.position = ccp(actualX ,winSize.height + (self.obstacle.contentSize.height/2));
    [self addChild:self.obstacle z:0 tag:2];
    
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
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"dropRock.mp3"];
}

//Remove onstacle after going out of screen
-(void)spriteMoveFinished:(id)sender {
    Obstacle *obstacle = (Obstacle *)sender;
    [self removeChild:obstacle cleanup:YES];
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

-(void)displayLabelFont:(int)displayNumber withScaleing:(BOOL)scale{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    if (scale) {
        countdown = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i", displayNumber] fntFile:@"magneto.fnt"];
        countdown.scale = 0.1;
        countdown.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:countdown];
        [countdown runAction:[CCScaleTo actionWithDuration:0.5 scale:3.0]];
    }else{
        countdown = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i", displayNumber] fntFile:@"magneto.fnt"];
        countdown.scale = 3.0;
        countdown.position = ccp(55.f, winSize.height - 150.f);
        [self addChild:countdown z:0 tag:1000];
    }
}

#pragma mark Scheduled methods

-(void)countdownStartGame:(ccTime)dt{
    // ask director for the window size
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    if (countdown != nil) {
        [countdown removeFromParentAndCleanup:YES];
    }
    if (timeStartGame > 0) {
        [self displayLabelFont:timeStartGame withScaleing:YES];
    }
    
    timeStartGame -= 1;
    
    if (timeStartGame == -1) {
        //This are the functions that will be scheduled to load continuously
        //as long as our game is running
        [self schedule:@selector(step:)];
        [self schedule:@selector(obstaclesStepAvoidSingleplayer:) interval:2.0];
        [self schedule:@selector(scroll:) interval:0.0000000001];
        [self schedule:@selector(secondsPassedInGame:) interval:1];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"game.mp3" loop:YES];
        
        //STart animation
        //Animations
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"totallyFinalAnimations-hd.plist"];
        self.spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"totallyFinalAnimations-hd.png"];
        [self addChild:self.spriteSheet];
        
        //Animations player1
        CCAnimation *walkAnimPlayer1 = [CCAnimation animationWithSpriteFrames:[self animFramesArrayForCharacter:avatarInt selected:NO] delay:0.1f];
        self.player = [CCSprite spriteWithSpriteFrameName:[self chosenAvatar:avatarInt selected:YES]];
        [self.player setPosition:ccp(size.height/2, size.width/2)];
        self.walkAction = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:walkAnimPlayer1]];
        [self.player runAction:self.walkAction];
        [self.spriteSheet addChild:self.player];
    }
}

//calculate seconds passed
-(void)secondsPassedInGame:(ccTime)dt{
    if (countdown != nil) {
        [countdown removeFromParentAndCleanup:YES];
    }
    scoreCounter.timeCounter -= 1;
    [self displayLabelFont:scoreCounter.timeCounter withScaleing:NO];
}

//step method fro the obstacles
-(void)obstaclesStepAvoidSingleplayer:(ccTime)dt{
    [self addObstaclesAvoidSingleplayer];
} 

//the function schedule and call everything as needed
- (void)step:(ccTime)dt {
	thing_pos.x += thing_vel.x * dt;
    
    //set the maximun and minimum positions where our character could be on screen
	CGSize thing_size = self.player.contentSize;
    
    //set the maximun and minimum positions where our character could be on screen
    float max_x = 0;
	float min_x = 0;
    float max_y = 0;
	float min_y = 0;
    
    if(IDIOM == IPAD) {
        //Device is ipad
        max_x = 858.0 - thing_size.width/2;
        min_x = 173.0 + thing_size.width/2;
        
        max_y = 700.0;
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
    
    self.player.position = ccp(thing_pos.x, thing_pos.y);
    
    //collision method
    [self checkForCollision];
    
    //Wining condition when timer stops
     if((scoreCounter.timeCounter <= 0) && (scoreCounter.livesLeftPlayer1 > 0)){
        [self endScene:kEndReasonWinAvoidSingleplayer];
     }
}

#pragma mark Collision Detection

-(void)checkForCollision{
    if (CGRectIntersectsRect([self getChildByTag:2].boundingBox, self.player.boundingBox)) {
        [scoreCounter substractLivesPlayer1];
        [[self getChildByTag:2] setTag:110];
        [[self getChildByTag:110] runAction:[CCShake actionWithDuration:.5f amplitude:ccp(7, 0)]];
        [self removeChildByTag:scoreCounter.livesLeftPlayer1 + 3 cleanup:YES];
        [self updateWinningCondition];
    }
}

- (void)updateWinningCondition{
    if (scoreCounter.livesLeftPlayer1 == 0) {
        [self endScene:kEndReasonLoseAvoidSingleplayer];
    }
}

#pragma mark End Scene

-(void)endScene:(EndReasonAvoidSingleplayer)endReason{
    //Stop the game
    [self unscheduleAllSelectors];
    [self stopAction:self.walkAction];
    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
    
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
    [self addChild:restartMenu z:0];
    
    CCMenuItemImage *backButtonEndSceneImage = [CCMenuItemImage
                                                itemWithNormalImage:@"inGameBackButton~ipad.png"
                                                selectedImage:@"inGameBackButtonSelected~ipad.png"
                                                disabledImage:nil
                                                target:self
                                                selector:@selector(goBackToMenu:)];
    
    CCMenu *backButtonEndScene = [CCMenu menuWithItems:backButtonEndSceneImage,nil];
    [backButtonEndScene setPosition:ccp(858.f - backButtonEndSceneImage.boundingBox.size.width/2.f, 180.f)];
    [self addChild:backButtonEndScene z:0];
    
    if (endReason == kEndReasonWinAvoidSingleplayer) {
        [self addChild:messageWon];
        [messageWon runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    } else if (endReason == kEndReasonLoseAvoidSingleplayer) {
        [self addChild:messageLost];
        [messageLost runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    }
    
    [endsceneImage runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
}

//restart scene
- (void)restartTapped:(id)sender {
    // Reload the current scene
    [[CCDirector sharedDirector] replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:[AvoidSingleplayerLayer scene]]];
}

#pragma mark Accelerometer

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
	float accel_filter = 0.1f;
	//handle our character on-screen via accelerometer
	thing_vel.x = thing_vel.x * accel_filter - acceleration.y * (1.0f - accel_filter) * 500.0f;
    thing_vel.y = thing_vel.y * accel_filter + acceleration.x * (1.0f - accel_filter) * 500.0f;
    
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
}


@end
