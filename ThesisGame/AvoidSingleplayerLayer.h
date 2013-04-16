//
//  AvoidSingleplayerLayer.h
//  ThesisGame
//
//  Created by Alex Savu on 4/13/13.
//
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "GameManager.h"

@class BackgroundLayer;
@class Player;
@class Obstacle;

@interface AvoidSingleplayerLayer : CCLayer{
    CGPoint thing_pos;
	CGPoint thing_vel;
	CGPoint thing_acc;
}

@property (nonatomic, strong) Player *player;
@property (nonatomic, strong) Obstacle *obstacle;
@property (nonatomic, strong) CCSprite *background;
@property (nonatomic, strong) CCSprite *background2;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end

