//
//  UIDevice+Hardware.h
//  ThesisGame
//
//  Created by Alexandru Savu on 2/7/13.
//
//

#import <UIKit/UIKit.h>
#include <sys/types.h>
#include <sys/sysctl.h>

@interface UIDevice (Hardware)
- (NSString *) platform;
- (BOOL)hasRetinaDisplay;
- (BOOL)hasMultitasking;
- (BOOL)hasCamera;
@end
