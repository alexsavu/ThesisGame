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
@synthesize livesLeft = _livesLeft;
@synthesize timeCounter = _timeCounter;

-(id)init{
    if (self == [super init]) {
        _scoreForPlayerOne = 0;
        _scoreForPlayerTwo = 0;
        _numberOfStars = 0;
        _livesLeft = 5;
        _timeCounter = 30;
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

-(void)substractLives{
    self.livesLeft -= 1;
}

-(void)countDownTimer{
    self.timeCounter -= 1;
}

@end
