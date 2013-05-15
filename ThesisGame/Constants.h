//  Constants.h
// Constants used

#define kMainMenuTagValue 10
#define kSceneMenuTagValue 20
#define kAvatarMenuTagValue 30
#define kSingleMultiplayerMenuTagValue 40

typedef enum {
    kNoSceneUninitialized=0,
    kMainMenuScene=1,
    kAvatarSelection=2,
    kCreditsScene=3,
    kStoryScene=4,
    kLevelCompleteScene=5,
    kSingleMultiplayerScene=6,
    kSingleplayerSceneSelection=7,
    kMultiplayerSceneSelection=8,
    kGameLevel1=101,
    kGameLevel2=102,
    kGameLevel3=103,
    kGameLevel4=104,
    kGameLevel5=105,
    kCutSceneForLevel2=201
} SceneTypes;