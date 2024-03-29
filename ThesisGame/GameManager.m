//
//  GameManager.m
//  ThesisGame
//
//  Created by Alexandru Savu on 2/15/13.
//
//

#import "GameManager.h"
#import "CollectMultiplayerLayer.h"
#import "MainMenuLayer.h"
#import "CollectSinglelayerLayer.h"
#import "AvoidSingleplayerLayer.h"
#import "AvoidMultiplayerLayer.h"
#import "SingleMultiplayerMenu.h"
#import "SingleplayerSceneSelection.h"
#import "MultiplayerSceneSelection.h"
#import "CollectAndAvoidMultiplayerLayer.h"
#import "AvatarSelection.h"
#import "StoryLayer.h"

@implementation GameManager
@synthesize isMusicON;
@synthesize isSoundEffectsON;
@synthesize hasPlayerDied;

static GameManager* _sharedGameManager = nil;   
+(GameManager*)sharedGameManager {
    @synchronized([GameManager class])                            
    {
        if(!_sharedGameManager)
           _sharedGameManager = [[GameManager alloc] init];
        return _sharedGameManager;
    }
    return nil;
}

+(id)alloc
{
    @synchronized ([GameManager class])
    {
        NSAssert(_sharedGameManager == nil,
                 @"Attempted to allocated a second instance of the Game Manager singleton");
        _sharedGameManager = [super alloc];
        return _sharedGameManager;
    }
    return nil;
}

-(id)init {
    self = [super init];
    if (self != nil) {
        // Game Manager initialized
        CCLOG(@"Game Manager Singleton, init");
        isMusicON = YES;
        isSoundEffectsON = YES;
        hasPlayerDied = NO;
        currentScene = kNoSceneUninitialized;
    }
    return self;
}
-(void)runSceneWithID:(SceneTypes)sceneID {
    SceneTypes oldScene = currentScene;
    currentScene = sceneID;
    
    id sceneToRun = nil;
    switch (sceneID) {
        case kMainMenuScene:
            sceneToRun = [MainMenuLayer node];
            break;
        case kAvatarSelection:
            sceneToRun = [AvatarSelection node];
            break;
//        case kCreditsScene:
//            sceneToRun = [CreditsScene node];
//            break;
        case kStoryScene:
            sceneToRun = [StoryLayer node];
            break;
//        case kLevelCompleteScene:
//            sceneToRun = [LevelCompleteScene node];
//            break;
        case kSingleMultiplayerScene:
            sceneToRun = [SingleMultiplayerMenu node];
            break;
        case kSingleplayerSceneSelection:
            sceneToRun = [SingleplayerSceneSelection node];
            break;
        case kMultiplayerSceneSelection:
            sceneToRun = [MultiplayerSceneSelection node];
            break;
        case kGameLevel1:
            sceneToRun = [CollectSinglelayerLayer node];
            break;
            
        case kGameLevel2:
            sceneToRun = [AvoidSingleplayerLayer node];
            break;
        case kGameLevel3:
            sceneToRun = [CollectMultiplayerLayer node];
            break;
        case kGameLevel4:
            sceneToRun = [AvoidMultiplayerLayer node];
            break;
        case kGameLevel5:
            sceneToRun = [CollectAndAvoidMultiplayerLayer node];
            break;
        case kCutSceneForLevel2:
            // Placeholder for Platform Level
            break;
            
        default:
            CCLOG(@"Unknown ID, cannot switch scenes");
            return;
            break;
    }
    if (sceneToRun == nil) {
        // Revert back, since no new scene was found
        currentScene = oldScene;
        return;
    }
    
    // Menu Scenes have a value of < 100
    if (sceneID < 100) {
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            CGSize screenSize = [CCDirector sharedDirector].winSizeInPixels;
            if (screenSize.width == 960.0f) {
                // iPhone 4 Retina
                [sceneToRun setScaleX:0.9375f];
                [sceneToRun setScaleY:0.8333f];
                CCLOG(@"GameMgr:Scaling for iPhone 4 (retina)");
                
            } else {
                [sceneToRun setScaleX:0.4688f];
                [sceneToRun setScaleY:0.4166f];
                CCLOG(@"GameMgr:Scaling for iPhone 3GS or older (non-retina)");
                
            }
        }
    }
    
    if ([[CCDirector sharedDirector] runningScene] == nil) {
        [[CCDirector sharedDirector] runWithScene:sceneToRun];
        
    } else {
        
        [[CCDirector sharedDirector] replaceScene:sceneToRun];
    }
}

-(CGSize)getDimensionsOfCurrentScene {
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    CGSize levelSize;
    switch (currentScene) {
        case kMainMenuScene:
        case kCreditsScene:
        case kLevelCompleteScene:
        case kGameLevel1:
//            levelSize = screenSize;
            levelSize = CGSizeMake(screenSize.width * 2.0f, screenSize.height);
            break;
        case kGameLevel2:
            levelSize = CGSizeMake(screenSize.width * 2.0f, screenSize.height);
            break;
            
        default:
            CCLOG(@"Unknown Scene ID, returning default size");
            levelSize = screenSize;
            break;
    }
    return levelSize;
}

@end

