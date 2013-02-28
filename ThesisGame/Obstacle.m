//
//  Obstacle.m
//  ThesisGame
//
//  Created by Alexandru Savu on 2/28/13.
//
//

#import "Obstacle.h"

@implementation Obstacle

-(void)checkAndClampSpritePosition {
    if (self.characterState != kStateJumping) {
        if ([self position].y > 110.0f)
            [self setPosition:ccp([self position].x,110.0f)];
    }
    [super checkAndClampSpritePosition];
}

@end
