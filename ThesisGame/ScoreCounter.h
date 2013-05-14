//
//  ScoreCounter.h
//  ThesisGame
//
//  Created by Alex Savu on 4/13/13.
//
//

#import <Foundation/Foundation.h>

@interface ScoreCounter : NSObject

@property (nonatomic) NSInteger scoreForPlayerOne;
@property (nonatomic) NSInteger scoreForPlayerTwo;
@property (nonatomic) NSInteger numberOfStars;
@property (nonatomic) NSInteger livesLeftPlayer1;
@property (nonatomic) NSInteger livesLeftPlayer2;
@property (nonatomic) NSInteger timeCounter;
@property (nonatomic) NSInteger timeCounterAvoidMultiplayer;

-(void)countScoreForPlayerOne;
-(void)countScoreForPlayerTwo;
-(void)colectStars;
-(void)substractLivesPlayer1;
-(void)substractLivesPlayer2;
-(void)countDownTimer;
-(void)countTimeAvoidMultiplayer;

@end
