//
//  Player.m
//  ThesisGame
//
//  Created by Alexandru Savu on 2/15/13.
//
//

#import "Player.h"

@implementation Player

-(void)checkAndClampSpritePosition {
    if (self.characterState != kStateJumping) {
        if ([self position].y > 110.0f)
            [self setPosition:ccp([self position].x,110.0f)];
    }
    [super checkAndClampSpritePosition];
}

@end
