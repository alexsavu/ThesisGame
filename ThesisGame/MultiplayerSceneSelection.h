//
//  MultiplayerSceneSelection.h
//  ThesisGame
//
//  Created by Alex Savu on 4/23/13.
//
//

#import "CCLayer.h"
#import "Constants.h"
#import "cocos2d.h"
#import "GameManager.h"

@interface MultiplayerSceneSelection : CCLayer

@property (nonatomic, strong) CCMenu *sceneSelectionMultiplayer;
+(CCScene *)scene;

@end
