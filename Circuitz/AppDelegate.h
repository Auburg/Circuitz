//
//  AppDelegate.h
//  Circuitz
//
//  Created by Tanvir Kazi on 18/10/2011.
//  Copyright Hackers 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
