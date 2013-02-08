//
//  GCHelper.h
//  ThesisGame
//
//  Created by Alexandru Savu on 2/1/13.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol GCHelperDelegate
- (void)matchStarted;
- (void)matchEnded;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data
   fromPlayer:(NSString *)playerID;
- (void)inviteReceived;
@end


// Modify @interface line to support protocols as follows
@interface GCHelper : NSObject <GKMatchmakerViewControllerDelegate, GKMatchDelegate> {
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    BOOL matchStarted;
}



@property (assign, readonly) BOOL gameCenterAvailable;
@property (retain) UIViewController *presentingViewController;
@property (retain) GKMatch *match;
@property (assign) id <GCHelperDelegate> delegate;
@property (retain) NSMutableDictionary *playersDict;
//Invite
@property (retain) GKInvite *pendingInvite;
@property (retain) NSArray *pendingPlayersToInvite;

+ (GCHelper *)sharedInstance;
- (void)authenticateLocalUser;
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController
                       delegate:(id<GCHelperDelegate>)theDelegate;

@end
