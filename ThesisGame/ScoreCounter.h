//
//  ScoreCounter.h
//  ThesisGame
//
//  Created by Alex Savu on 4/13/13.
//
//

#import <Foundation/Foundation.h>

@interface ScoreCounter : NSObject

@property (nonatomic) int scoreForPlayerOne;
@property (nonatomic) int scoreForPlayerTwo;

-(void)countScoreForPlayerOne;
-(void)countScoreForPlayerTwo;

@end
