//
//  BackgroundLayer.m
//  ThesisGame
//
//  Created by Alexandru Savu on 2/8/13.
//
//

#import "BackgroundLayer.h"

@implementation BackgroundLayer

-(id) init {
    self = [super init];
    if (self != nil) {
    CCSprite *backgroundImage;
    if([[[UIDevice currentDevice] platform] isEqualToString:@"iPad 4 (WiFi)"]) {
        backgroundImage = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
    } else {
        backgroundImage = [CCSprite spriteWithFile:@"Default.png"];
    }
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        [backgroundImage setPosition:CGPointMake(screenSize.width/2, screenSize.height/2)];
        [self addChild:backgroundImage z:0 tag:0];
    }
    return self;
}

@end
