//  GameplayScrollingLayer.h
//  SpaceViking
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Player.h"
//#import "GameControlLayer.h"

@interface GameplayScrollingLayer : CCLayer {
    CCSpriteBatchNode *sceneSpriteBatchNode;
    
    CCTMXTiledMap *tileMapNode;
    CCParallaxNode *parallaxNode;
}
//-(void)connectControlsWithJoystick:(SneakyJoystick*)leftJoystick 
//                     andJumpButton:(SneakyButton*)jumpButton 
//                   andAttackButton:(SneakyButton*)attackButton;    
@end
