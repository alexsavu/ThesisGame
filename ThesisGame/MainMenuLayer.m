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
    } else {
        CCLOG(@"Tag was: %d", [itemPassedIn tag]);
        CCLOG(@"Placeholder for next chapters");
    }
}


-(void)displayMainMenu {
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    if (self.sceneSelectMenu != nil) {
        [self.sceneSelectMenu removeFromParentAndCleanup:YES];
    }
    // Main Menu
    CCMenuItemImage *playGameButton = [CCMenuItemImage
                                       itemWithNormalImage:@"PlayGameButtonNormal.png"
                                       selectedImage:@"PlayGameButtonSelected.png"
                                       disabledImage:nil
                                       target:self
                                       selector:@selector(displaySceneSelection)];
    
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
                                         
    self.mainMenu = [CCMenu
                menuWithItems:playGameButton,optionsButton,nil];
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

-(void)displaySceneSelection {
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    if (self.mainMenu != nil) {
        [self.mainMenu removeFromParentAndCleanup:YES];
    }
    
    CCLabelBMFont *playScene1Label =
    [CCLabelBMFont labelWithString:@"Oli Awakes!"
                           fntFile:@"VikingSpeechFont64.fnt"];
    CCMenuItemLabel *playScene1 =
    [CCMenuItemLabel itemWithLabel:playScene1Label target:self
                          selector:@selector(playScene:)];
    [playScene1 setTag:1];
    
    CCLabelBMFont *playScene2Label =
    [CCLabelBMFont labelWithString:@"Dogs of Loki!"
                           fntFile:@"VikingSpeechFont64.fnt"];
    CCMenuItemLabel *playScene2 =
    [CCMenuItemLabel itemWithLabel:playScene2Label target:self
                          selector:@selector(playScene:)];
    [playScene2 setTag:2];
    
    CCLabelBMFont *playScene3Label =
    [CCLabelBMFont labelWithString:@"Mad Dreams of the Dead!"
                           fntFile:@"VikingSpeechFont64.fnt"];
    CCMenuItemLabel *playScene3 = [CCMenuItemLabel itemWithLabel:playScene3Label target:self
                                                        selector:@selector(playScene:)];
    [playScene3 setTag:3];
    
    CCLabelBMFont *playScene4Label =
    [CCLabelBMFont labelWithString:@"Descent Into Hades!"
                           fntFile:@"VikingSpeechFont64.fnt"];
	CCMenuItemLabel *playScene4 = [CCMenuItemLabel itemWithLabel:playScene4Label target:self
														selector:@selector(playScene:)];
	[playScene4 setTag:4];
    
    CCLabelBMFont *playScene5Label =
    [CCLabelBMFont labelWithString:@"Escape!"
                           fntFile:@"VikingSpeechFont64.fnt"];
	CCMenuItemLabel *playScene5 = [CCMenuItemLabel itemWithLabel:playScene5Label target:self
														selector:@selector(playScene:)];
	[playScene5 setTag:5];
    
    CCLabelBMFont *backButtonLabel =
    [CCLabelBMFont labelWithString:@"Back"
                           fntFile:@"VikingSpeechFont64.fnt"];
    CCMenuItemLabel *backButton =
    [CCMenuItemLabel itemWithLabel:backButtonLabel target:self
                          selector:@selector(displayMainMenu)];
    
    self.sceneSelectMenu = [CCMenu menuWithItems:playScene1,
                       playScene2,playScene3,playScene4,playScene5,backButton,nil];
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
