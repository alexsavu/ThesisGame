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
@property (nonatomic) NSInteger livesLeft;
@property (nonatomic) NSInteger timeCounter;

-(void)countScoreForPlayerOne;
-(void)countScoreForPlayerTwo;
-(void)colectStars;
-(void)substractLives;
-(void)countDownTimer;

@end
