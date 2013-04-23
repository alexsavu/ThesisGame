//
//  MultiplayerSceneSelection.m
//  ThesisGame
//
//  Created by Alex Savu on 4/23/13.
//
//

#import "MultiplayerSceneSelection.h"

@implementation MultiplayerSceneSelection

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *)scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MultiplayerSceneSelection *layer = [MultiplayerSceneSelection node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id)init {
    self = [super init];
    if (self != nil) {
    }
    [self menuForMultiplayer];
    return self;
}

-(void)menuForMultiplayer{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    CCLabelBMFont *playScene1Label =
    [CCLabelBMFont labelWithString:@"Collect the stars"
                           fntFile:@"magneto.fnt"];
    CCMenuItemLabel *playScene1 =
    [CCMenuItemLabel itemWithLabel:playScene1Label target:self
                          selector:@selector(playSceneForMultiplayer:)];
    [playScene1 setTag:3];
    
    CCLabelBMFont *playScene2Label =
    [CCLabelBMFont labelWithString:@"Dodge the obstacles"
                           fntFile:@"magneto.fnt"];
    CCMenuItemLabel *playScene2 =
    [CCMenuItemLabel itemWithLabel:playScene2Label target:self
                          selector:@selector(playSceneForMultiplayer:)];
    [playScene2 setTag:4];
    
    CCLabelBMFont *backButtonLabel =
    [CCLabelBMFont labelWithString:@"Back"
                           fntFile:@"magneto.fnt"];
    CCMenuItemLabel *backButton =
    [CCMenuItemLabel itemWithLabel:backButtonLabel target:self
                          selector:@selector(backToSingleMultiplayerSceneFromMultiplayer)];
    
    self.sceneSelectionMultiplayer = [CCMenu menuWithItems:playScene1,
                                      playScene2,backButton,nil];
    [self.sceneSelectionMultiplayer alignItemsVerticallyWithPadding:screenSize.height * 0.059f];
    [self.sceneSelectionMultiplayer setPosition:ccp(screenSize.width * 2,
                                                    screenSize.height / 2)];
    
    id moveAction = [CCMoveTo actionWithDuration:0.5f
                                        position:ccp(screenSize.width * 0.75f,
                                                     screenSize.height/2)];
    id moveEffect = [CCEaseIn actionWithAction:moveAction rate:1.0f];
    [self.sceneSelectionMultiplayer runAction:moveEffect];
    [self addChild:self.sceneSelectionMultiplayer z:1 tag:kSceneMenuTagValue];
}

-(void)backToSingleMultiplayerSceneFromMultiplayer{
    [[GameManager sharedGameManager] runSceneWithID:kSingleMultiplayerScene];
}

-(void)playSceneForMultiplayer:(CCMenuItemFont*)itemPassedIn {
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
