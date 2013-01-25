//
//  HelloWorldLayer.h
//  ThesisGame
//
//  Created by Alexandru Savu on 1/24/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
    CGPoint thing_pos;
	CGPoint thing_vel;
	CGPoint thing_acc;
}

@property (nonatomic, strong) CCSprite * redCircle;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
