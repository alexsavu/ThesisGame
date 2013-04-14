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

-(id)init{
    if (self == [super init]) {
        _scoreForPlayerOne = 0;
        _scoreForPlayerTwo = 0;
        _numberOfStars = 0;
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

@end
