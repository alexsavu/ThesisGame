//
//  GameObject.h
//  ThesisGame
//
//  Created by Alexandru Savu on 2/15/13.
//
//

#import "CCSprite.h"
#import "cocos2d.h"
#import "GameManager.h"
#import "KKPixelMaskSprite.h"

@interface GameObject : KKPixelMaskSprite{
    BOOL isActive;
    BOOL reactsToScreenBoundaries;
    CGSize screenSize;
}
@property (readwrite) BOOL isActive;
@property (readwrite) BOOL reactsToScreenBoundaries;
@property (readwrite) CGSize screenSize;
-(void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray*)listOfGameObjects;
-(CGRect)adjustedBoundingBox;
-(CCAnimation*)loadPlistForAnimationWithName:(NSString*)animationName andClassName:(NSString*)className;

@end
