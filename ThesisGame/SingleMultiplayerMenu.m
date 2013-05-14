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
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        CCSprite *backgroundForSingleMultiplayer = [CCSprite spriteWithFile:@"mainMenuBackground~ipad.png"];
        [backgroundForSingleMultiplayer setPosition:ccp(screenSize.width/2,screenSize.height/2)];
        [self addChild:backgroundForSingleMultiplayer];
        [self displaySingleMultiplayerMenu];
    }
    return self;
}

//Displays menu where the player can choose between singleplayer and multiplayer
-(void)displaySingleMultiplayerMenu{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    if (self.singleMultiplayerMenu != nil) {
        [self.singleMultiplayerMenu removeFromParentAndCleanup:YES];
    }
    // Singleplayer Button
    CCMenuItemImage *singleplayerButton = [CCMenuItemImage
                                       itemWithNormalImage:@"singlePlayerButton~ipad.png"
                                       selectedImage:@"singlePlayerButtonSelected~ipad.png"
                                       disabledImage:nil
                                       target:self
                                       selector:@selector(displaySceneSelectionSingleplayer)];
    [singleplayerButton setTag:1];
    
    // Multiplayer Button
    CCMenuItemImage *multiplayerButton = [CCMenuItemImage
                                       itemWithNormalImage:@"multiplayerButton~ipad.png"
                                       selectedImage:@"multiplayerButtonSelected~ipad.png"
                                       disabledImage:nil
                                       target:self
                                       selector:@selector(displaySceneSelectionMultiplayer)];
    [multiplayerButton setTag:2];
    
    // Back Button
    CCMenuItemImage *backButton = [CCMenuItemImage
                                          itemWithNormalImage:@"backButtonMenu~ipad.png"
                                          selectedImage:@"backButtonMenuSelected~ipad.png"
                                          disabledImage:nil
                                          target:self
                                          selector:@selector(backToMainScene)];
    
    self.singleMultiplayerMenu = [CCMenu menuWithItems:singleplayerButton,
                                  multiplayerButton,backButton,nil];
    [self.singleMultiplayerMenu alignItemsVerticallyWithPadding:screenSize.height * 0.059f];
    [self.singleMultiplayerMenu setPosition:ccp(screenSize.width * 2, screenSize.height / 3.f)];
    
    id moveAction = [CCMoveTo actionWithDuration:0.5f position:ccp(screenSize.width * 0.75f, screenSize.height/3.f)];
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
