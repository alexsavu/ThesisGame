//
//  MainMenuLayer.h
//  ThesisGame
//
//  Created by Alex Savu on 3/2/13.
//
//

#import "CCLayer.h"
#import "Constants.h"
#import "cocos2d.h"
#import "GameManager.h"

@interface MainMenuLayer : CCLayer

@property (nonatomic, strong) CCMenu *mainMenu;
@property (nonatomic, strong) CCMenu *avatarMenu;
@property (nonatomic, strong) CCMenu *singleMultiplayerMenu;
@property (nonatomic, strong) CCMenu *sceneSelectionSingleplayer;
@property (nonatomic, strong) CCMenu *sceneSelectionMultiplayer;

@end
