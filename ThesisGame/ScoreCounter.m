//
//  ScoreCounter.m
//  ThesisGame
//
//  Created by Alex Savu on 4/13/13.
//
//

#import "ScoreCounter.h"

@implementation ScoreCounter
@synthesize scoreForPlayerOne = _scoreForPlayerOne;
@synthesize scoreForPlayerTwo = _scoreForPlayerTwo;
@synthesize numberOfStars = _numberOfStars;
@synthesize livesLeftPlayer1 = _livesLeftPlayer1;
@synthesize livesLeftPlayer2 = _livesLeftPlayer2;
@synthesize timeCounter = _timeCounter;

-(id)init{
    if (self == [super init]) {
        self.scoreForPlayerOne = 0;
        self.scoreForPlayerTwo = 0;
        self.numberOfStars = 0;
        self.livesLeftPlayer1 = 5;
        self.livesLeftPlayer2 = 5;
        self.timeCounter = 30;
    }
    return self;
}

-(void)countScoreForPlayerOne{
    self.scoreForPlayerOne += 1;
}

-(void)countScoreForPlayerTwo{
    self.scoreForPlayerTwo += 1;
}

-(void)colectStars{
    self.numberOfStars += 1;
}

-(void)substractLivesPlayer1{
    self.livesLeftPlayer1 -= 1;
}

-(void)substractLivesPlayer2{
    self.livesLeftPlayer2 -= 1;
}

-(void)countDownTimer{
    self.timeCounter -= 1;
}

@end
