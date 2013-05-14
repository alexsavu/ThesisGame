//
//  SingleplayerSceneSelection.m
//  ThesisGame
//
//  Created by Alex Savu on 4/23/13.
//
//

#import "SingleplayerSceneSelection.h"

@implementation SingleplayerSceneSelection

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *)scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	SingleplayerSceneSelection *layer = [SingleplayerSceneSelection node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id)init {
    self = [super init];
    if (self != nil) {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        CCSprite *backgroundForSingleMultiplayer = [CCSprite spriteWithFile:@"mainMenuBackground~ipad.png"];
        [backgroundForSingleMultiplayer setPosition:ccp(screenSize.width/2,screenSize.height/2)];
        [self addChild:backgroundForSingleMultiplayer];
        [self menuForSingleplayer];
    }
    return self;
}

//Displays the different levels
-(void)menuForSingleplayer {
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    // Collect stars Singleplayer Button
    CCMenuItemImage *collectStarsSingleplayer = [CCMenuItemImage
                                           itemWithNormalImage:@"collectButton~ipad.png"
                                           selectedImage:@"collectButtonSelected~ipad.png"
                                           disabledImage:nil
                                           target:self
                                           selector:@selector(playSceneForSingleplayer:)];
    [collectStarsSingleplayer setTag:1];
    
    // Avoid rocks Singleplayer Button
    CCMenuItemImage *avoidRocksSingleplayer = [CCMenuItemImage
                                           itemWithNormalImage:@"avoidButton~ipad.png"
                                           selectedImage:@"avoidButtonSelected~ipad.png"
                                           disabledImage:nil
                                           target:self
                                            selector:@selector(playSceneForSingleplayer:)];
    [avoidRocksSingleplayer setTag:2];
    
    // Back Button
    CCMenuItemImage *backButton = [CCMenuItemImage
                                   itemWithNormalImage:@"backButtonMenu~ipad.png"
                                   selectedImage:@"backButtonMenuSelected~ipad.png"
                                   disabledImage:nil
                                   target:self
                                   selector:@selector(backToSingleMultiplayerSceneFromSingleplayer)];
    
//    CCLabelBMFont *playScene1Label =
//    [CCLabelBMFont labelWithString:@"Collect the stars"
//                           fntFile:@"magneto.fnt"];
//    CCMenuItemLabel *playScene1 =
//    [CCMenuItemLabel itemWithLabel:playScene1Label target:self
//                          selector:@selector(playSceneForSingleplayer:)];
//    [playScene1 setTag:1];
//    
//    CCLabelBMFont *playScene2Label =
//    [CCLabelBMFont labelWithString:@"Dodge the obstacles"
//                           fntFile:@"magneto.fnt"];
//    CCMenuItemLabel *playScene2 =
//    [CCMenuItemLabel itemWithLabel:playScene2Label target:self
//                          selector:@selector(playSceneForSingleplayer:)];
//    [playScene2 setTag:2];
//    
//    CCLabelBMFont *backButtonLabel =
//    [CCLabelBMFont labelWithString:@"Back"
//                           fntFile:@"magneto.fnt"];
//    CCMenuItemLabel *backButton =
//    [CCMenuItemLabel itemWithLabel:backButtonLabel target:self
//                          selector:@selector(backToSingleMultiplayerSceneFromSingleplayer)];
    
    self.sceneSelectionSingleplayer = [CCMenu menuWithItems:collectStarsSingleplayer, avoidRocksSingleplayer,backButton,nil];
    [self.sceneSelectionSingleplayer alignItemsVerticallyWithPadding:screenSize.height * 0.059f];
    [self.sceneSelectionSingleplayer setPosition:ccp(screenSize.width * 2, screenSize.height / 3.f)];
    
    id moveAction = [CCMoveTo actionWithDuration:0.5f position:ccp(screenSize.width * 0.75f, screenSize.height/3.f)];
    id moveEffect = [CCEaseIn actionWithAction:moveAction rate:1.0f];
    [self.sceneSelectionSingleplayer runAction:moveEffect];
    [self addChild:self.sceneSelectionSingleplayer z:1 tag:kSceneMenuTagValue];
}

-(void)backToSingleMultiplayerSceneFromSingleplayer{
    [[GameManager sharedGameManager] runSceneWithID:kSingleMultiplayerScene];
}

-(void)playSceneForSingleplayer:(CCMenuItemFont*)itemPassedIn {
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

@end
