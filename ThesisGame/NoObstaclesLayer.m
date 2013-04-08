//
//  NoObstaclesLayer.m
//  ThesisGame
//
//  Created by Alex Savu on 3/2/13.
//
//

#import "NoObstaclesLayer.h"
#import "AppDelegate.h"
#import "Player.h"

#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad
#define kHeroMovementAction 1
#define kPlayerSpeed 300
#define kFilteringFactor 0.1
#define MIN_COURSE_X 173.0
#define MAX_COURSE_X 858.0

@interface NoObstaclesLayer (){
    BOOL stop;
    NSInteger avatarInt;
}
@property (nonatomic, strong) CCMenu *backToMainMenuFromScene2;
@property (nonatomic, retain) CCSprite *finish;
@property (nonatomic, weak) NSString *avatar;
- (void)step:(ccTime)dt;
@end

@implementation NoObstaclesLayer
@synthesize backgroundLayer = _backgroundLayer;
@synthesize background = _background;
@synthesize background2 = _background2;
@synthesize player = _player;
@synthesize backToMainMenuFromScene2 = _backToMainMenuFromScene2;
@synthesize finish = _finish;

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	NoObstaclesLayer *layer = [NoObstaclesLayer node];
	
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
        
        //chosen avatar is retrieved from userDefaults
        NSUserDefaults *savedAvatar = [NSUserDefaults standardUserDefaults];
        avatarInt = [savedAvatar integerForKey:@"chosenAvatar"];
        CCLOG(@"chosenAvatar %i", avatarInt);
        
        [self chosenAvatar:avatarInt];
        
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
        [self addChild:self.background2 ];
        
        //Add the player character. It has it's own class derived from GameCharacter
        self.player = [[Player alloc] initWithFile:self.avatar alphaThreshold:0];
        [self.player setPosition:ccp(size.height/2, size.width/2)];
        [self addChild:self.player z:0 tag:1];
        
        //enable accelerometer
        self.isAccelerometerEnabled = YES;
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:1/60];
        
        //This are the functions that will be scheduled to load continuously
        //as long as our game is running
        [self schedule:@selector(step:)];
        
        [self addBackButton];
	}
	return self;
}

//Finds the correct .png for the chosen avatar
- (void) chosenAvatar: (NSInteger) value {
    //int response = [[notification object] integerValue];
    
    switch(value)
    {
        case 1:
            self.avatar = @"Char1~ipad.png";
            break;
        case 2:
            self.avatar = @"Char2~ipad.png";
            break;
        case 3:
            self.avatar = @"Char3~ipad.png";
            break;
        case 4:
            self.avatar = @"Char4~ipad.png";
            break;
        case 5:
            self.avatar = @"Char5~ipad.png";
            break;
    }
    
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
    
    self.backToMainMenuFromScene2 = [CCMenu
                           menuWithItems:backArrow,nil];
    [self.backToMainMenuFromScene2 setPosition:ccp(55.f,screenSize.height - 55.f)];
    //TODO: change tag value because is the same as the main menu
    [self addChild:self.backToMainMenuFromScene2 z:0 tag:kMainMenuTagValue];
}

//Selector method for going back to main menu
-(void)goBackToMenu:(CCMenuItemFont*)itemPassedIn {
    CCLOG(@"Tag 1 found, Scene 2");
    [[GameManager sharedGameManager] runSceneWithID:kMainMenuScene];
}

#pragma mark Step methods

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
    
    if(IDIOM == IPAD) {
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
    
    if(thing_pos.y>max_y) thing_pos.y = max_y;
	if(thing_pos.y<min_y) thing_pos.y = min_y;
    
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
	
    self.player.position = ccp(thing_pos.x, thing_pos.y);
    self.background.position = ccp(0, -background_pos.y);
    self.background2.position = ccp(0, self.background.position.y + 768.0);
    
    //up scroll
    [self scrollUpwards];
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
    
    NSLog(@"Accelerometer: %f", inclination);
}


@end
