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
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        CCSprite *backgroundForSingleMultiplayer = [CCSprite spriteWithFile:@"mainMenuBackground~ipad.png"];
        [backgroundForSingleMultiplayer setPosition:ccp(screenSize.width/2,screenSize.height/2)];
        [self addChild:backgroundForSingleMultiplayer];
        [self menuForMultiplayer];
    }
    return self;
}

-(void)menuForMultiplayer{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    // Collect stars Multiplayer Button
    CCMenuItemImage *collectStarsMultiplayer = [CCMenuItemImage
                                          itemWithNormalImage:@"collectButton~ipad.png"
                                          selectedImage:@"collectButtonSelected~ipad.png"
                                          disabledImage:nil
                                          target:self
                                          selector:@selector(playSceneForMultiplayer:)];
    [collectStarsMultiplayer setTag:3];
    
    // Avoid rocks Multiplayer Button
    CCMenuItemImage *avoidRocksMultiplayer = [CCMenuItemImage
                                          itemWithNormalImage:@"avoidButton~ipad.png"
                                          selectedImage:@"avoidButtonSelected~ipad.png"
                                          disabledImage:nil
                                          target:self
                                          selector:@selector(playSceneForMultiplayer:)];
    [avoidRocksMultiplayer setTag:4];
    
    // Collect & Dodge Multiplayer Button
    CCMenuItemImage *collectDodgeMultiplayer = [CCMenuItemImage
                                          itemWithNormalImage:@"rockstarButton~ipad.png"
                                          selectedImage:@"rockstarButtonSelected~ipad.png"
                                          disabledImage:nil
                                          target:self
                                          selector:@selector(playSceneForMultiplayer:)];
    [collectDodgeMultiplayer setTag:5];
    
    // Back Button
    CCMenuItemImage *backButton = [CCMenuItemImage
                                   itemWithNormalImage:@"backButtonMenu~ipad.png"
                                   selectedImage:@"backButtonMenuSelected~ipad.png"
                                   disabledImage:nil
                                   target:self
                                   selector:@selector(backToSingleMultiplayerSceneFromMultiplayer)];
    
    self.sceneSelectionMultiplayer = [CCMenu menuWithItems:collectStarsMultiplayer, avoidRocksMultiplayer, collectDodgeMultiplayer,backButton,nil];
    [self.sceneSelectionMultiplayer alignItemsVerticallyWithPadding:screenSize.height * 0.019f];
    [self.sceneSelectionMultiplayer setPosition:ccp(screenSize.width * 2, screenSize.height / 3.f)];
    
    id moveAction = [CCMoveTo actionWithDuration:0.5f position:ccp(screenSize.width * 0.75f, screenSize.height/3.f)];
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
    }else if ([itemPassedIn tag] == 5){
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel5];
    }else {
        CCLOG(@"Tag was: %d", [itemPassedIn tag]);
        CCLOG(@"Placeholder for next chapters");
    }
}

@end
