//
//  AppDelegate.h
//  SCYPlayer
//
//  Created by Saucheong Ye on 20/09/2017.
//  Copyright © 2017 sauchye.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCYPlayer.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SCYPlayer *player;

+ (AppDelegate *)delegate;

@end

