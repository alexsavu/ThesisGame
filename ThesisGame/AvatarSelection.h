//
//  AvatarSelection.h
//  ThesisGame
//
//  Created by Alex Savu on 5/15/13.
//
//

#import "CCLayer.h"
#import "Constants.h"
#import "cocos2d.h"
#import "GameManager.h"

@interface AvatarSelection : CCLayer

@property (nonatomic, strong) CCMenu *avatarMenu;

+(CCScene *)scene;

@end
