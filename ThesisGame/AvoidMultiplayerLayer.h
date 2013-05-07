//
//  AvoidMultiplayerLayer.h
//  ThesisGame
//
//  Created by Alex Savu on 4/13/13.
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
    kGameStateWaitingForMatch2 = 0,
    kGameStateWaitingForRandomNumber2,
    kGameStateWaitingForStart2,
    kGameStateActive2,
    kGameStateDone2,
    kGameStateWaitingForAvatarNumber2
} GameState2;

typedef enum {
    kEndReasonWin2,
    kEndReasonLose2,
    kEndReasonDisconnect2
} EndReason2;

typedef enum {
    kMessageTypeRandomNumber2 = 0,
    kMessageTypeGameBegin2,
    kMessageTypeMove2,
    kMessageTypeGameOver2,
    kMessageTypeAvatarNumber2,
} MessageType2;

typedef struct {
    MessageType2 messageType;
} Message2;

typedef struct {
    Message2 message;
    uint32_t randomNumber;
} MessageRandomNumber2;

typedef struct {
    Message2 message;
} MessageGameBegin2;

typedef struct {
    Message2 message;
} MessageMoveBackground2;

typedef struct {
    Message2 message;
} MessageMove2;

typedef struct {
    Message2 message;
    BOOL player1Won;
} MessageGameOver2;

typedef struct {
    Message2 message;
    uint32_t avatarNumber;
}MessageAvatarNumber2;

// HelloWorldLayer
@interface AvoidMultiplayerLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate, GCHelperDelegate,UIAlertViewDelegate>
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
    GameState2 gameState;
}

@property (nonatomic, strong) Player *player1;
@property (nonatomic, strong) Player *player2;
@property (nonatomic, strong) CCAction *walkAction;
@property (nonatomic, strong) Obstacle *obstacle;
@property (nonatomic, strong) CCSprite *background;
@property (nonatomic, strong) CCSprite *background2;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
