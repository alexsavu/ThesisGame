//
//  SingleMultiplayerMenu.m
//  ThesisGame
//
//  Created by Alex Savu on 4/23/13.
//
//

#import "SingleMultiplayerMenu.h"
#import "AppDelegate.h"

@implementation SingleMultiplayerMenu

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *)scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	SingleMultiplayerMenu *layer = [SingleMultiplayerMenu node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id)init {
    self = [super init];
    if (self != nil) {
    }
    [self displaySingleMultiplayerMenu];
    return self;
}

//Displays menu where the player can choose between singleplayer and multiplayer
-(void)displaySingleMultiplayerMenu{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    if (self.singleMultiplayerMenu != nil) {
        [self.singleMultiplayerMenu removeFromParentAndCleanup:YES];
    }
    
    CCLabelBMFont *playScene1Label =
    [CCLabelBMFont labelWithString:@"Single player"
                           fntFile:@"magneto.fnt"];
    CCMenuItemLabel *playScene1 =
    [CCMenuItemLabel itemWithLabel:playScene1Label target:self
                          selector:@selector(displaySceneSelectionSingleplayer)];
    [playScene1 setTag:1];
    
    CCLabelBMFont *playScene2Label =
    [CCLabelBMFont labelWithString:@"Multiplayer"
                           fntFile:@"magneto.fnt"];
    CCMenuItemLabel *playScene2 =
    [CCMenuItemLabel itemWithLabel:playScene2Label target:self
                          selector:@selector(displaySceneSelectionMultiplayer)];
    [playScene2 setTag:2];
    
    CCLabelBMFont *backButtonLabel =
    [CCLabelBMFont labelWithString:@"Back"
                           fntFile:@"magneto.fnt"];
    CCMenuItemLabel *backButton =
    [CCMenuItemLabel itemWithLabel:backButtonLabel target:self
                          selector:@selector(backToMainScene)];
    
    self.singleMultiplayerMenu = [CCMenu menuWithItems:playScene1,
                                  playScene2,backButton,nil];
    [self.singleMultiplayerMenu alignItemsVerticallyWithPadding:screenSize.height * 0.059f];
    [self.singleMultiplayerMenu setPosition:ccp(screenSize.width * 2,
                                                screenSize.height / 2)];
    
    id moveAction = [CCMoveTo actionWithDuration:0.5f
                                        position:ccp(screenSize.width * 0.75f,
                                                     screenSize.height/2)];
    id moveEffect = [CCEaseIn actionWithAction:moveAction rate:1.0f];
    [self.singleMultiplayerMenu runAction:moveEffect];
    [self addChild:self.singleMultiplayerMenu z:1 tag:kSceneMenuTagValue];
}

-(void)displaySceneSelectionSingleplayer{
    [[GameManager sharedGameManager] runSceneWithID:kSingleplayerSceneSelection];
}

-(void)displaySceneSelectionMultiplayer{
    [[GameManager sharedGameManager] runSceneWithID:kMultiplayerSceneSelection];
}

-(void)backToMainScene{
    [[GameManager sharedGameManager] runSceneWithID:kMainMenuScene];
}

@end
