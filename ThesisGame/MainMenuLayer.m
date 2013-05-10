//
//  MainMenuLayer.m
//  ThesisGame
//
//  Created by Alex Savu on 3/2/13.
//
//

#import "MainMenuLayer.h"
#import "AppDelegate.h"
#import <GameKit/GameKit.h>

@interface MainMenuLayer()

@property (nonatomic, strong) CCSprite *backgroundForMainMenu;
@property (nonatomic, strong) CCSprite *backgroundForAvatarSelection;
@property (nonatomic, strong) CCMenu *backButtonMenu;
-(void)displayMainMenu;

@end

@implementation MainMenuLayer
@synthesize mainMenu = _mainMenu;
@synthesize avatarMenu = _avatarMenu;


// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenuLayer *layer = [MainMenuLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id)init {
    self = [super init];
    if (self != nil) {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        self.backgroundForMainMenu = [CCSprite spriteWithFile:@"mainMenu_background.png"];
        [self.backgroundForMainMenu setPosition:ccp(screenSize.width/2,screenSize.height/2)];
        self.backgroundForAvatarSelection = [CCSprite spriteWithFile:@"avatarSelectionBackground.png"];
        [self.backgroundForAvatarSelection setPosition:ccp(screenSize.width/2,screenSize.height/2)];
        
        [self displayMainMenu];
        
//        CCSprite *viking =
//        [CCSprite spriteWithFile:@"VikingFloating.png"];
//        [viking setPosition:ccp(screenSize.width * 0.35f,
//                                screenSize.height * 0.45f)];
//        [self addChild:viking];
//        
//        id rotateAction = [CCEaseElasticInOut actionWithAction:
//                           [CCRotateBy actionWithDuration:5.5f
//                                                    angle:360]];
//        
//        id scaleUp = [CCScaleTo actionWithDuration:2.0f scale:1.5f];
//        id scaleDown = [CCScaleTo actionWithDuration:2.0f scale:0.5f];
//        
//        [viking runAction:[CCRepeatForever actionWithAction:
//                           [CCSequence
//                            actions:scaleUp,scaleDown,nil]]];
//        
//        [viking runAction:
//         [CCRepeatForever actionWithAction:rotateAction]];
        
    }
    return self;
}

-(void)showOptions {
    CCLOG(@"Show the Options screen");
    [[GameManager sharedGameManager] runSceneWithID:kOptionsScene];
}

-(void)playScene:(CCMenuItemFont*)itemPassedIn {
    if ([itemPassedIn tag] == 1) {
        CCLOG(@"Tag 1 found, Scene 1");
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel1];
    } else if ([itemPassedIn tag] == 2){
        CCLOG(@"Tag 2 found, Scene 2");
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel2];
    }else if ([itemPassedIn tag] == 3){
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel3];
    }else if ([itemPassedIn tag] == 4){
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel4];
    }else {
        CCLOG(@"Tag was: %d", [itemPassedIn tag]);
        CCLOG(@"Placeholder for next chapters");
    }
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

-(void)displayMainMenu {
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    if(self.avatarMenu != nil) {
        [self.avatarMenu removeFromParentAndCleanup:YES];
        [self removeChildByTag:31 cleanup:YES];
    }
    
    [self addChild:self.backgroundForMainMenu z:0 tag:30];
    
    // Main Menu
    CCMenuItemImage *playGameButton = [CCMenuItemImage
                                       itemWithNormalImage:@"startButton~ipad.png"
                                       selectedImage:@"startButtonSelected~ipad.png"
                                       disabledImage:nil
                                       target:self
                                       selector:@selector(displayAvatarMenu)];
                                         
    self.mainMenu = [CCMenu
                menuWithItems:playGameButton,nil];
    [self.mainMenu alignItemsVerticallyWithPadding:screenSize.height * 0.059f];
    [self.mainMenu setPosition:ccp(screenSize.width * 2.0f, screenSize.height / 4.f)];
    id moveAction = [CCMoveTo actionWithDuration:1.2f position:ccp(screenSize.width * 0.75f, screenSize.height/4.f)];
    id moveEffect = [CCEaseIn actionWithAction:moveAction rate:1.0f];
    [self.mainMenu runAction:moveEffect];
    [self addChild:self.mainMenu z:0 tag:kMainMenuTagValue];
}

//Shows the avatar menu, allows the player to choose his avatar
-(void)displayAvatarMenu/*:(CCMenuItemFont*)itemPassedIn */{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    if (self.mainMenu != nil) {
        [self.mainMenu removeFromParentAndCleanup:YES];
        [self removeChildByTag:30 cleanup:YES];
    }
    
    [self addChild:self.backgroundForAvatarSelection z:0 tag:31];
    
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
                                  selector:@selector(displayMainMenu)];
    
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

@end
