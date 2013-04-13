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

-(id)init{
    if (self == [super init]) {
        _scoreForPlayerOne = 0;
        _scoreForPlayerTwo = 0;
    }
    return self;
}

-(void)countScoreForPlayerOne{
    self.scoreForPlayerOne += 1;
}

-(void)countScoreForPlayerTwo{
    self.scoreForPlayerTwo += 1;
}

@end
