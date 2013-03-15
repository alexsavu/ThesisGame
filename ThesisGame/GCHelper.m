//
//  GCHelper.m
//  ThesisGame
//
//  Created by Alexandru Savu on 2/1/13.
//
//

#import "GCHelper.h"
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] \
compare:v options:NSNumericSearch] == NSOrderedAscending)

@implementation GCHelper
@synthesize gameCenterAvailable;
@synthesize presentingViewController = _presentingViewController;
@synthesize match = _match;
@synthesize delegate = _delegate;
@synthesize playersDict = _playersDict;
//Invite
@synthesize pendingInvite = _pendingInvite;
@synthesize pendingPlayersToInvite = _pendingPlayersToInvite;

#pragma mark Initialization

static GCHelper *sharedHelper = nil;
+ (GCHelper *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[GCHelper alloc] init];
    }
    return sharedHelper;
}

- (BOOL)isGameCenterAvailable {
	// check for presence of GKLocalPlayer API
	Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	
	// check if the device is running iOS 4.1 or later
	NSString *reqSysVer = @"4.1";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
	
	return (gcClass && osVersionSupported);
}

- (id)init {
    if ((self = [super init])) {
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc =
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
        }
    }
    return self;
}

#pragma mark Internal functions

- (void)authenticationChanged {
    
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
        NSLog(@"Authentication changed: player authenticated.");
        userAuthenticated = TRUE;
        [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *acceptedInvite, NSArray *playersToInvite) {
            
            NSLog(@"Received invite");
            self.pendingInvite = acceptedInvite;
            self.pendingPlayersToInvite = playersToInvite;
            [self.delegate inviteReceived];
        };
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated");
        userAuthenticated = FALSE;
    }
    
}

- (void)lookupPlayers {
    
    NSLog(@"Looking up %d players...", self.match.playerIDs.count);
    [GKPlayer loadPlayersForIdentifiers:self.match.playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
        
        if (error != nil) {
            NSLog(@"Error retrieving player info: %@", error.localizedDescription);
            matchStarted = NO;
            [self.delegate matchEnded];
        } else {
            
            // Populate players dict
            self.playersDict = [NSMutableDictionary dictionaryWithCapacity:players.count];
            for (GKPlayer *player in players) {
                NSLog(@"Found player: %@", player.alias);
                [self.playersDict setObject:player forKey:player.playerID];
            }
            
            // Notify delegate match can begin
            matchStarted = YES;
            [self.delegate matchStarted];
            
        }
    }];
    
}

#pragma mark User functions

- (void)checkLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    if (localPlayer.isAuthenticated)
    {
        /* Perform additional tasks for the authenticated player here */
        NSLog(@"IS AUTHENTICATED");
    }
    else
    {
        /* Perform additional tasks for the non-authenticated player here */
        NSLog(@"IS NOT AUTHENTICATED");
    }
}

- (void)authenticateLocalUser {
    
    if (!gameCenterAvailable) return;
    
    NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];
    } else {
        NSLog(@"Already authenticated!");
    }
    
//    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
//    
//    if (SYSTEM_VERSION_LESS_THAN(@"6.0"))
//    {
//        // ios 5.x and below
//        [localPlayer authenticateWithCompletionHandler:^(NSError *error)
//         {
////             [self checkLocalPlayer];
//         }];
//    }
//    else
//    {
//        // ios 6.0 and above
//        [localPlayer setAuthenticateHandler:(^(UIViewController* viewcontroller, NSError *error) {
//            NSLog(@"Error: %@", error);
//            if (!error && viewcontroller)
//            {
//                [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
//                [self.presentingViewController presentViewController:viewcontroller animated:YES completion:nil];
//            }
//            else
//            {
//                [self checkLocalPlayer];
//            }
//        })];
//    }
}

- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController
                       delegate:(id<GCHelperDelegate>)theDelegate {
    
    if (!gameCenterAvailable) return;
    
    matchStarted = NO;
    self.match = nil;
    self.presentingViewController = viewController;
    self.delegate = theDelegate;
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
    
    if (self.pendingInvite != nil) {
        
        [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
        GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithInvite:self.pendingInvite];
        mmvc.matchmakerDelegate = self;
        [self.presentingViewController presentViewController:mmvc animated:YES completion:nil];
        
        self.pendingInvite = nil;
        self.pendingPlayersToInvite = nil;
        
    } else {
        
        [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
        GKMatchRequest *request = [[GKMatchRequest alloc] init];
        request.minPlayers = minPlayers;
        request.maxPlayers = maxPlayers;
        request.playersToInvite = self.pendingPlayersToInvite;
        
        GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
        mmvc.matchmakerDelegate = self;
        
        [self.presentingViewController presentViewController:mmvc animated:YES completion:nil];
        
        self.pendingInvite = nil;
        self.pendingPlayersToInvite = nil;
    }
}

#pragma mark GKMatchmakerViewControllerDelegate

// The user has cancelled matchmaking
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

// Matchmaking has failed with an error
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Error finding match: %@", error.localizedDescription);
}

// A peer-to-peer match has been found, the game should start
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)theMatch {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    self.match = theMatch;
    self.match.delegate = self;
    if (!matchStarted && self.match.expectedPlayerCount == 0) {
        NSLog(@"Ready to start match!");
        [self lookupPlayers];
    }
}

#pragma mark GKMatchDelegate

// The match received data sent from the player.
- (void)match:(GKMatch *)theMatch didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    if (self.match != theMatch) return;
    
    [self.delegate match:theMatch didReceiveData:data fromPlayer:playerID];
}

// The player state changed (eg. connected or disconnected)
- (void)match:(GKMatch *)theMatch player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
    if (self.match != theMatch) return;
    
    switch (state) {
        case GKPlayerStateConnected:
            // handle a new player connection.
            NSLog(@"Player connected!");
            
            if (!matchStarted && theMatch.expectedPlayerCount == 0) {
                NSLog(@"Ready to start match!");
                [self lookupPlayers];
            }
            
            break;
        case GKPlayerStateDisconnected:
            // a player just disconnected.
            NSLog(@"Player disconnected!");
            matchStarted = NO;
            [self.delegate matchEnded];
            break;
    }
}

// The match was unable to connect with the player due to an error.
- (void)match:(GKMatch *)theMatch connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error {
    
    if (self.match != theMatch) return;
    
    NSLog(@"Failed to connect to player with error: %@", error.localizedDescription);
    matchStarted = NO;
    [self.delegate matchEnded];
}

// The match was unable to be established with any players due to an error.
- (void)match:(GKMatch *)theMatch didFailWithError:(NSError *)error {
    
    if (self.match != theMatch) return;
    
    NSLog(@"Match failed with error: %@", error.localizedDescription);
    matchStarted = NO;
    [self.delegate matchEnded];
}

@end

