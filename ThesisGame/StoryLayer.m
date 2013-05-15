//
//  StoryLayer.m
//  ThesisGame
//
//  Created by Alex Savu on 5/15/13.
//
//

#import "StoryLayer.h"

@implementation StoryLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	StoryLayer *layer = [StoryLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void)startGamePlay {
	CCLOG(@"Intro complete, asking Game Manager to start the Game play");
	[[GameManager sharedGameManager] runSceneWithID:kAvatarSelection];
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	CCLOG(@"Touches received, skipping intro");
	[self startGamePlay];
}


-(id)init {
	self = [super init];
	if (self != nil) {
		// Accept touch input
		self.isTouchEnabled = YES;
		
		// Create the intro image
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CCSprite *introImage = [CCSprite spriteWithFile:@"intro_1~ipad.png"];
		[introImage setPosition:ccp(screenSize.width/2, screenSize.height/2)];
		[self addChild:introImage];
		
		// Create the intro animation, and load it from intro1 to intro7.png
		CCAnimation *introAnimation = [CCAnimation animation];
        [introAnimation setDelayPerUnit:2.5f];
		for (int frameNumber=1; frameNumber < 3; frameNumber++) {
			CCLOG(@"Adding image intro_%d~ipad.png to the introAnimation.",frameNumber);
			[introAnimation addSpriteFrameWithFilename:[NSString stringWithFormat:@"intro_%d~ipad.png",frameNumber]];
		}
		
		// Create the actions to play the intro
		id animationAction = [CCAnimate actionWithAnimation:introAnimation];
		id startGameAction = [CCCallFunc actionWithTarget:self selector:@selector(startGamePlay)];
		id introSequence = [CCSequence actions:animationAction,startGameAction,nil];
		
		[introImage runAction:introSequence];
	}
	return self;
}

@end
