//
//  AvatarSelection.m
//  ThesisGame
//
//  Created by Alex Savu on 5/15/13.
//
//

#import "AvatarSelection.h"
#import "AppDelegate.h"

@interface AvatarSelection()

@property (nonatomic, strong) CCMenu *backButtonMenu;

@end

@implementation AvatarSelection

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *)scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	AvatarSelection *layer = [AvatarSelection node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id)init {
    self = [super init];
    if (self != nil) {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        CCSprite *backgroundAvatarSelection = [CCSprite spriteWithFile:@"avatarSelectionBackground.png"];
        [backgroundAvatarSelection setPosition:ccp(screenSize.width/2,screenSize.height/2)];
        [self addChild:backgroundAvatarSelection];
        [self displayAvatarMenu];
    }
    return self;
}

#pragma mark Choose Avatar by Tag

-(void)chooseAvatar:(CCMenuItemImage*)itemPassedIn {
    int avatar = 0;
    
    if([itemPassedIn tag] == 1){
        CCLOG(@"Tag 1 found, avatar 1");
        avatar = 1;
    }
    else if([itemPassedIn tag] == 2){
        CCLOG(@"Tag 2 found, avatar 2");
        avatar = 2;
    }
    else if ([itemPassedIn tag] == 3){
        CCLOG(@"Tag 3 found, avatar 3");
        avatar = 3;
    }
    else if ([itemPassedIn tag] == 4){
        CCLOG(@"Tag 4 found, avatar 4");
        avatar = 4;
    }
    else {
        CCLOG(@"Tag 5 found, avatar 5");
        avatar = 5;
    }
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"playerAv" object:[NSNumber numberWithInt:avatar]];
    //chosen avatar is stored so that other classes can access it
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:avatar forKey:@"chosenAvatar"];
    
    //    [self displaySingleMultiplayerMenu];
    [[GameManager sharedGameManager] runSceneWithID:kSingleMultiplayerScene];
}

//Shows the avatar menu, allows the player to choose his avatar
-(void)displayAvatarMenu{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    CCMenuItemImage *avatar1Button = [CCMenuItemImage
                                      itemWithNormalImage:@"afroUnselected~ipad.png"
                                      selectedImage:@"afroSelected~ipad.png"
                                      disabledImage:nil
                                      target:self
                                      selector:@selector(chooseAvatar:)];
    [avatar1Button setTag:1];
    
    CCMenuItemImage *avatar2Button = [CCMenuItemImage
                                      itemWithNormalImage:@"gingerUnselected~ipad.png"
                                      selectedImage:@"gingerSelected~ipad.png"
                                      disabledImage:nil
                                      target:self
                                      selector:@selector(chooseAvatar:)];
    [avatar2Button setTag:2];
    
    CCMenuItemImage *avatar3Button = [CCMenuItemImage
                                      itemWithNormalImage:@"indianUnselected~ipad.png"
                                      selectedImage:@"indianSelected~ipad.png"
                                      disabledImage:nil
                                      target:self
                                      selector:@selector(chooseAvatar:)];
    [avatar3Button setTag:3];
    
    CCMenuItemImage *avatar4Button = [CCMenuItemImage
                                      itemWithNormalImage:@"japaneseUnselected~ipad.png"
                                      selectedImage:@"japaneseSelected~ipad.png"
                                      disabledImage:nil
                                      target:self
                                      selector:@selector(chooseAvatar:)];
    [avatar4Button setTag:4];
    
    CCMenuItemImage *backButtonImage = [CCMenuItemImage
                                        itemWithNormalImage:@"backButtonMenu~ipad.png"
                                        selectedImage:@"backButtonMenuSelected~ipad.png"
                                        disabledImage:nil
                                        target:self
                                        selector:@selector(displayMainMenuScene)];
    
    self.backButtonMenu = [CCMenu menuWithItems:backButtonImage,nil];
    [self.backButtonMenu setPosition:ccp(screenSize.width * 2.0f, screenSize.height / 4.5f)];
    
    id moveActionForBackButton = [CCMoveTo actionWithDuration:1.2f position:ccp(screenSize.width * 0.85f, screenSize.height/4.5f)];
    id moveEffectForBackButton = [CCEaseIn actionWithAction:moveActionForBackButton rate:1.0f];
    [self.backButtonMenu runAction:moveEffectForBackButton];
    [self addChild:self.backButtonMenu];
    
    
    self.avatarMenu = [CCMenu menuWithItems:avatar1Button, avatar2Button, avatar3Button, avatar4Button, nil];
    [self.avatarMenu alignItemsHorizontallyWithPadding:screenSize.width * 0.05f];
    [self.avatarMenu setScale:0.85];
    [self.avatarMenu setPosition:ccp(screenSize.width * 0.059f,screenSize.height / 3.f)];
    id moveActionForAvatarMenu = [CCMoveTo actionWithDuration:1.2f position:ccp(screenSize.width * 0.43f, screenSize.height/3.f)];
    id moveEffectForAvatarMenu = [CCEaseIn actionWithAction:moveActionForAvatarMenu rate:1.0f];
    [self.avatarMenu runAction:moveEffectForAvatarMenu];
    [self addChild:self.avatarMenu z:0 tag:kAvatarMenuTagValue];
}

-(void)displayMainMenuScene{
    [[GameManager sharedGameManager] runSceneWithID:kMainMenuScene];
}

@end
