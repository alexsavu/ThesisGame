//
//  CollectSinglelayerLayer.m
//  ThesisGame
//
//  Created by Alex Savu on 3/2/13.
//
//

#import "CollectSinglelayerLayer.h"
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

@interface CollectSinglelayerLayer (){
    NSInteger avatarInt;
    ScoreCounter *scoreCounter;
    CCSpriteBatchNode *starSheet;
}
@property (nonatomic, strong) CCMenu *backToMainMenuFromScene2;
@property (nonatomic, strong) Obstacle *collectable;
@property (nonatomic, weak) NSString *avatar;

-(void)step:(ccTime)dt;
-(void)sparkleAt:(CGPoint)p;
-(NSString*)chosenAvatar:(NSInteger)value;
@end

@implementation CollectSinglelayerLayer
@synthesize background = _background;
@synthesize background2 = _background2;
@synthesize player = _player;
@synthesize avatar = _avatar;
@synthesize backToMainMenuFromScene2 = _backToMainMenuFromScene2;

@synthesize collectable = _collectable;

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	CollectSinglelayerLayer *layer = [CollectSinglelayerLayer node];
	
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

        scoreCounter = [[ScoreCounter alloc] init];
        
        //chosen avatar is retrieved from userDefaults
        NSUserDefaults *savedAvatar = [NSUserDefaults standardUserDefaults];
        avatarInt = [savedAvatar integerForKey:@"chosenAvatar"];
        self.avatar = [self chosenAvatar:avatarInt];
        
        //Preload sounds
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"collectStar.mp3"];
        
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
//        [self schedule:@selector(collectableStarsStep:) interval:2.0];
        [self performSelector:@selector(collectableStars) withObject:self afterDelay:2.f];
        [self schedule:@selector(scroll:) interval:0.0000000001];
        
//        self.scale = 0.4;
        
        [self addBackButton];
	}
	return self;
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

#pragma mark Star collectables

-(void)collectableStars{
    
    self.collectable = [[Obstacle alloc] initWithFile:@"starObject_1.png" alphaThreshold:0];
    // Determine where to spawn the target along the Y axis
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int minX = MIN_COURSE_X + self.collectable.contentSize.width/2;
    int maxX = MAX_COURSE_X - self.collectable.contentSize.width/2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    //Position on Y for upper part of the screen
    int minYUpper = winSize.height - winSize.height/4;
    int maxYUpper = winSize.height - self.collectable.contentSize.height/2;
    int actualYUpper = minYUpper + arc4random() % (maxYUpper - minYUpper);
    
    //Position on Y for lower part of the screen
    int minYLower = 0 + self.collectable.contentSize.height/2;
    int maxYLower = 0 + winSize.height/4;
    int actualYLower = minYLower + arc4random() % (maxYLower - minYLower);
    
//    //Animation
//    starSheet = [CCSpriteBatchNode batchNodeWithFile:@"starAnimation2_default.png"];
//    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"starAnimation2_default.plist"];
//    [self addChild:starSheet];
//    
//    NSMutableArray *starAnimFrames = [NSMutableArray array];
//    for(int i = 1; i <= 7; i++){
//        [starAnimFrames addObject: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"starObject_%d.png", i]]];
//    }
//    CCAnimation *starAnim = [CCAnimation animationWithSpriteFrames:starAnimFrames delay:
//                             0.1f];
//    CCAction *action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:starAnim]];
//    
//    [starSheet addChild:self.collectable];
//    [self.collectable runAction:action];
    
    // Create the target slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    NSLog(@"STARS: %i", scoreCounter.numberOfStars);
    if (scoreCounter.numberOfStars % 2 == 0) {
        self.collectable.position = ccp(actualX ,actualYUpper);
    }else{
        self.collectable.position = ccp(actualX ,actualYLower);
    }
    [self addChild:self.collectable z:0 tag:5];
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


#pragma mark Step methods

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
}

#pragma mark Collision Detection

-(void)checkForCollision{
    if ([(KKPixelMaskSprite *)[self getChildByTag:5] pixelMaskIntersectsNode:(KKPixelMaskSprite *)[self getChildByTag:1]]) {
        NSLog(@"@@@@@@@@@@@@: %f", [self getChildByTag:5].position.y);
        [self sparkleAt:[self getChildByTag:5].position];
        [scoreCounter colectStars];
        [self performSelector:@selector(collectableStars) withObject:self afterDelay:2.f];
        [self removeChild:[self getChildByTag:5] cleanup:YES];
    }
}

#pragma mark Stars effect

- (void)sparkleAt:(CGPoint)p {
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
    
//    NSLog(@"Accelerometer: %f", inclination);
}


@end
