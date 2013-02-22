//
//  GameManager.h
//  ThesisGame
//
//  Created by Alexandru Savu on 2/15/13.
//
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface GameManager : NSObject {
    BOOL isMusicON;
    BOOL isSoundEffectsON;
    BOOL hasPlayerDied;
    SceneTypes currentScene;
}
@property (readwrite) BOOL isMusicON;
@property (readwrite) BOOL isSoundEffectsON;
@property (readwrite) BOOL hasPlayerDied;

+(GameManager*)sharedGameManager;
-(void)runSceneWithID:(SceneTypes)sceneID;
-(CGSize)getDimensionsOfCurrentScene;
//-(void)openSiteWithLinkType:(LinkTypes)linkTypeToOpen ;

@end