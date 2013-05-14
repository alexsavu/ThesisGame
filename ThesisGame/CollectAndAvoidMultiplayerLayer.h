//
//  CollectAndAvoidMultiplayerLayer.h
//  ThesisGame
//
//  Created by Alex Savu on 5/7/13.
//
//

#import <GameKit/GameKit.h>
#import "GCHelper.h"
#import "cocos2d.h"
#import "GameManager.h"

@class BackgroundLayer;
@class Player;
@class Obstacle;

typedef enum {
    kGameStateWaitingForMatch3 = 0,
    kGameStateWaitingForRandomNumber3,
    kGameStateWaitingForStart3,
    kGameStateActive3,
    kGameStateDone3,
    kGameStateWaitingForAvatarNumber3
} GameState3;

typedef enum {
    kEndReasonWin3,
    kEndReasonLose3,
    kEndReasonDisconnect3
} EndReason3;

typedef enum {
    kMessageTypeRandomNumber3 = 0,
    kMessageTypeGameBegin3,
    kMessageTypeMove3,
    kMessageTypeGameOver3,
    kMessageTypeAvatarNumber3,
    kMessageTypeCollisionStar3,
    kMessageTypeCollisionRock3
} MessageType3;

typedef struct {
    MessageType3 messageType;
} Message3;

typedef struct {
    Message3 message;
    uint32_t randomNumber;
} MessageRandomNumber3;

typedef struct {
    Message3 message;
    uint32_t collisionStar;
} MessageCollidionStar3;

typedef struct {
    Message3 message;
    uint32_t collisionRock;
} MessageCollisionRock3;

typedef struct {
    Message3 message;
} MessageGameBegin3;

typedef struct {
    Message3 message;
} MessageMoveBackground3;

typedef struct {
    Message3 message;
} MessageMove3;

typedef struct {
    Message3 message;
    BOOL player1Won;
} MessageGameOver3;

typedef struct {
    Message3 message;
    uint32_t avatarNumber;
}MessageAvatarNumber3;

// HelloWorldLayer
@interface CollectAndAvoidMultiplayerLayer : CCLayer <GCHelperDelegate,UIAlertViewDelegate>
{
    //player 1
    CGPoint thing_pos;
	CGPoint thing_vel;
	CGPoint thing_acc;
    //player2
    CGPoint thing2_pos;
	CGPoint thing2_vel;
	CGPoint thing2_acc;
    //Multiplayer
    uint32_t ourRandom;
    BOOL receivedRandom;
    BOOL receivedAvatar;
    NSString *otherPlayerID;
    BOOL isPlayer1;
    GameState3 gameState;
}

@property (nonatomic, strong) Player *player1;
@property (nonatomic, strong) Player *player2;
@property (nonatomic, strong) CCAction *walkActionPlayer1;
@property (nonatomic, strong) CCAction *walkActionPlayer2;
@property (nonatomic, strong) Obstacle *obstacle;
@property (nonatomic, strong) Obstacle *starObstacle;
@property (nonatomic, strong) CCSprite *background;
@property (nonatomic, strong) CCSprite *background2;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end

