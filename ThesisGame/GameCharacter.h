//  GameCharacter.h
//  SpaceViking

#import <Foundation/Foundation.h>
#import "GameObject.h"

@interface GameCharacter : GameObject {
    int characterHealth;
}

-(void)checkAndClampSpritePosition;

@end
