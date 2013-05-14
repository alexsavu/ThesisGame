//
//  CollectSinglelayerLayer.h
//  ThesisGame
//
//  Created by Alex Savu on 3/2/13.
//
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "GameManager.h"

@class BackgroundLayer;
@class Player;
@class Obstacle;

typedef enum {
    kEndReasonWinCollectSingleplayer,
    kEndReasonLoseCollectSingleplayer
} EndReasonCollectSingleplayer;

@interface CollectSinglelayerLayer : CCLayer{
    CGPoint thing_pos;
	CGPoint thing_vel;
	CGPoint thing_acc;
}

@property (nonatomic, strong) Player *player;
@property (nonatomic, strong) CCAction *walkAction;
@property (nonatomic, strong) CCSprite *background;
@property (nonatomic, strong) CCSprite *background2;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
