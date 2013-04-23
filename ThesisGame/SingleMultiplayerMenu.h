//
//  SingleMultiplayerMenu.h
//  ThesisGame
//
//  Created by Alex Savu on 4/23/13.
//
//

#import "CCLayer.h"
#import "Constants.h"
#import "cocos2d.h"
#import "GameManager.h"


@interface SingleMultiplayerMenu : CCLayer

@property (nonatomic, strong) CCMenu *singleMultiplayerMenu;

+(CCScene *)scene;

@end
