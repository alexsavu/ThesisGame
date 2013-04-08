//
//  MainMenuLayer.m
//  ThesisGame
//
//  Created by Alex Savu on 3/2/13.
//
//

#import "MainMenuLayer.h"

@interface MainMenuLayer()

-(void)displayMainMenu;
-(void)displaySceneSelection;

@end

@implementation MainMenuLayer
@synthesize sceneSelectMenu = _sceneSelectMenu;
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
//        CGSize screenSize = [CCDirector sharedDirector].winSize;
//        
//        CCSprite *background =
//        [CCSprite spriteWithFile:@"MainMenuBackground.png"];
//        [background setPosition:ccp(screenSize.width/2,
//                                    screenSize.height/2)];
//        [self addChild:background];
        
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
    }else {
        CCLOG(@"Tag was: %d", [itemPassedIn tag]);
        CCLOG(@"Placeholder for next chapters");
    }
}

//assigns the player's chosen avatar in the game session.
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
    
    [self displaySceneSelection];
    
}

-(void)displayMainMenu {
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    if (self.sceneSelectMenu != nil) {
        [self.sceneSelectMenu removeFromParentAndCleanup:YES];
    }
    else if(self.avatarMenu != nil) {
        [self.avatarMenu removeFromParentAndCleanup:YES];
    }
    // Main Menu
    CCMenuItemImage *playGameButton = [CCMenuItemImage
                                       itemWithNormalImage:@"PlayGameButtonNormal.png"
                                       selectedImage:@"PlayGameButtonSelected.png"
                                       disabledImage:nil
                                       target:self
                                       //selector:@selector(displaySceneSelection)];
                                       selector:@selector(displayAvatarMenu)];
    
//    CCMenuItemImage *buyBookButton = [CCMenuItemImage
//                                      itemWithNormalImage:@"BuyBookButtonNormal.png"
//                                      selectedImage:@"BuyBookButtonSelected.png"
//                                      disabledImage:nil
//                                      target:self
//                                      selector:@selector(buyBook)];
    
    CCMenuItemImage *optionsButton = [CCMenuItemImage
                                      itemWithNormalImage:@"OptionsButtonNormal.png"
                                      selectedImage:@"OptionsButtonSelected.png"
                                      target:self
                                      selector:@selector(showOptions)];
    
    /*
    //for testing purposes.
    CCMenuItemImage *avatarSelect = [CCMenuItemImage
                                       itemWithNormalImage:@"dpadDown~ipad.png"
                                     selectedImage:nil
                                       disabledImage:nil
                                       target:self
                                       selector:@selector(displayAvatarMenu)];
     */
    
    self.mainMenu = [CCMenu
                menuWithItems:playGameButton,optionsButton/*,avatarSelect*/,nil];
    [self.mainMenu alignItemsVerticallyWithPadding:screenSize.height * 0.059f];
    [self.mainMenu setPosition:
     ccp(screenSize.width * 2.0f,
         screenSize.height / 2.0f)];
    id moveAction =
    [CCMoveTo actionWithDuration:1.2f
                        position:ccp(screenSize.width * 0.85f,
                                     screenSize.height/2.0f)];
    id moveEffect = [CCEaseIn actionWithAction:moveAction rate:1.0f];
    [self.mainMenu runAction:moveEffect];
    [self addChild:self.mainMenu z:0 tag:kMainMenuTagValue];
}

//Shows the avatar menu, allows the player to choose his avatar
-(void)displayAvatarMenu/*:(CCMenuItemFont*)itemPassedIn */{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    if (self.mainMenu != nil) {
        [self.mainMenu removeFromParentAndCleanup:YES];
    }
    else if(self.sceneSelectMenu != nil) {
        [self.sceneSelectMenu removeFromParentAndCleanup:YES];
    }

    CCMenuItemImage *avatar1Button = [CCMenuItemImage
                                      itemWithNormalImage:@"Char1~ipad.png"
                                      selectedImage:@"Char1_selected~ipad.png"
                                      disabledImage:nil
                                      target:self
                                      selector:@selector(chooseAvatar:)];
    [avatar1Button setTag:1];
    
    CCMenuItemImage *avatar2Button = [CCMenuItemImage
                                      itemWithNormalImage:@"Char2~ipad.png"
                                      selectedImage:@"Char2_selected~ipad.png"
                                      disabledImage:nil
                                      target:self
                                      selector:@selector(chooseAvatar:)];
    [avatar2Button setTag:2];
    
    CCMenuItemImage *avatar3Button = [CCMenuItemImage
                                      itemWithNormalImage:@"Char3~ipad.png"
                                      selectedImage:@"Char3_selected~ipad.png"
                                      disabledImage:nil
                                      target:self
                                      selector:@selector(chooseAvatar:)];
    [avatar3Button setTag:3];
    
    CCMenuItemImage *avatar4Button = [CCMenuItemImage
                                      itemWithNormalImage:@"Char4~ipad.png"
                                      selectedImage:@"Char4_selected~ipad.png"
                                      disabledImage:nil
                                      target:self
                                      selector:@selector(chooseAvatar:)];
    [avatar4Button setTag:4];
    
    CCMenuItemImage *avatar5Button = [CCMenuItemImage
                                      itemWithNormalImage:@"Char5~ipad.png"
                                      selectedImage:@"Char5_selected~ipad.png"
                                      disabledImage:nil
                                      target:self
                                      selector:@selector(chooseAvatar:)];
    [avatar5Button setTag:5];
    
    CCLabelBMFont *backButtonLabel =
    [CCLabelBMFont labelWithString:@"Back"
                           fntFile:@"magneto.fnt"];
    CCMenuItemLabel *backButton =
    [CCMenuItemLabel itemWithLabel:backButtonLabel target:self
                          selector:@selector(displayMainMenu)];
    
    self.avatarMenu = [CCMenu menuWithItems:avatar1Button, avatar2Button, avatar3Button, avatar4Button, avatar5Button, backButton, nil];
    [self.avatarMenu alignItemsHorizontallyWithPadding:screenSize.width * 0.05f];
    [self.avatarMenu setPosition:
     ccp(screenSize.width * 0.059f,
         screenSize.height / 2.0f)];
    id moveAction =
    [CCMoveTo actionWithDuration:1.2f
                        position:ccp(screenSize.width * 0.50f,
                                     screenSize.height/2.0f)];
    id moveEffect = [CCEaseIn actionWithAction:moveAction rate:1.0f];
    [self.avatarMenu runAction:moveEffect];
    [self addChild:self.avatarMenu z:0 tag:kAvatarMenuTagValue];
}

-(void)displaySceneSelection {
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    if (self.mainMenu != nil) {
        [self.mainMenu removeFromParentAndCleanup:YES];
    }
    if (self.avatarMenu != nil) {
        [self.avatarMenu removeFromParentAndCleanup:YES];
    }
    
    CCLabelBMFont *playScene1Label =
    [CCLabelBMFont labelWithString:@"Level without obstacles"
                           fntFile:@"magneto.fnt"];
    CCMenuItemLabel *playScene1 =
    [CCMenuItemLabel itemWithLabel:playScene1Label target:self
                          selector:@selector(playScene:)];
    [playScene1 setTag:1];
    
    CCLabelBMFont *playScene2Label =
    [CCLabelBMFont labelWithString:@"Obstacleeeees!!"
                           fntFile:@"magneto.fnt"];
    CCMenuItemLabel *playScene2 =
    [CCMenuItemLabel itemWithLabel:playScene2Label target:self
                          selector:@selector(playScene:)];
    [playScene2 setTag:2];
    
    CCLabelBMFont *playScene3Label =
    [CCLabelBMFont labelWithString:@"Mad Dreams of the Dead!"
                           fntFile:@"magneto.fnt"];
    CCMenuItemLabel *playScene3 = [CCMenuItemLabel itemWithLabel:playScene3Label target:self
                                                        selector:@selector(playScene:)];
    [playScene3 setTag:3];
    
    CCLabelBMFont *playScene4Label =
    [CCLabelBMFont labelWithString:@"Descent Into Hades!"
                           fntFile:@"magneto.fnt"];
	CCMenuItemLabel *playScene4 = [CCMenuItemLabel itemWithLabel:playScene4Label target:self
														selector:@selector(playScene:)];
	[playScene4 setTag:4];
    
    CCLabelBMFont *playScene5Label =
    [CCLabelBMFont labelWithString:@"Escape!"
                           fntFile:@"magneto.fnt"];
	CCMenuItemLabel *playScene5 = [CCMenuItemLabel itemWithLabel:playScene5Label target:self
														selector:@selector(playScene:)];
	[playScene5 setTag:5];
    
    CCLabelBMFont *backButtonLabel =
    [CCLabelBMFont labelWithString:@"Back"
                           fntFile:@"magneto.fnt"];
    CCMenuItemLabel *backButton =
    [CCMenuItemLabel itemWithLabel:backButtonLabel target:self
                          selector:@selector(displayMainMenu)];
    
    self.sceneSelectMenu = [CCMenu menuWithItems:playScene1,
                       playScene2,backButton,nil];
    [self.sceneSelectMenu alignItemsVerticallyWithPadding:screenSize.height * 0.059f];
    [self.sceneSelectMenu setPosition:ccp(screenSize.width * 2,
                                     screenSize.height / 2)];
    
    id moveAction = [CCMoveTo actionWithDuration:0.5f
                                        position:ccp(screenSize.width * 0.75f,
                                                     screenSize.height/2)];
    id moveEffect = [CCEaseIn actionWithAction:moveAction rate:1.0f];
    [self.sceneSelectMenu runAction:moveEffect];
    [self addChild:self.sceneSelectMenu z:1 tag:kSceneMenuTagValue];
}

@end
