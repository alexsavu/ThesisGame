//
//  HelloWorldLayer.h
//  ThesisGame
//
//  Created by Alexandru Savu on 1/24/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import <GameKit/GameKit.h>
#import "GCHelper.h"
#import "cocos2d.h"
#import "GameManager.h"

@class BackgroundLayer;
@class Player;
@class Obstacle;

typedef enum {
    kGameStateWaitingForMatch = 0,
    kGameStateWaitingForRandomNumber,
    kGameStateWaitingForStart,
    kGameStateActive,
    kGameStateDone
} GameState;

typedef enum {
    kEndReasonWin,
    kEndReasonLose,
    kEndReasonDisconnect
} EndReason;

typedef enum {
    kMessageTypeRandomNumber = 0,
    kMessageTypeGameBegin,
    kMessageTypeMove,
    kMessageTypeGameOver
} MessageType;

typedef struct {
    MessageType messageType;
} Message;

typedef struct {
    Message message;
    uint32_t randomNumber;
} MessageRandomNumber;

typedef struct {
    Message message;
} MessageGameBegin;

typedef struct {
    Message message;
} MessageMove;

typedef struct {
    Message message;
    BOOL player1Won;
} MessageGameOver;

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate, GCHelperDelegate>
{
    CGPoint thing_pos;
	CGPoint thing_vel;
	CGPoint thing_acc;
    CGPoint background_pos;
    CGPoint background_vel;
    CGPoint background_acc;
    
    CGPoint background2_pos;
    CGPoint background2_vel;
    CGPoint background2_acc;
    //Multiplayer
    uint32_t ourRandom;
    BOOL receivedRandom;
    NSString *otherPlayerID;
    BOOL isPlayer1;
    GameState gameState;
}

@property (nonatomic, strong) Player *player;
@property (nonatomic, strong) Obstacle *obstacle;
@property (nonatomic, strong) BackgroundLayer *backgroundLayer;
@property (nonatomic, strong) CCSprite *background;
@property (nonatomic, strong) CCSprite *background2;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
