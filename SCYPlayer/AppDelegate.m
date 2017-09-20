//
//  AppDelegate.m
//  SCYPlayer
//
//  Created by Saucheong Ye on 20/09/2017.
//  Copyright © 2017 sauchye.com. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate (){
    UIBackgroundTaskIdentifier _bgTaskId;
}

@end

@implementation AppDelegate

+ (AppDelegate *)delegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.player = [SCYPlayer defaultManager];
    // 后台
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];

    [application beginReceivingRemoteControlEvents];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    //后台播放
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    //需要持续播放网络歌曲，申请后台任务id
    _bgTaskId = [AppDelegate backgroundPlayerID:_bgTaskId];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [application endReceivingRemoteControlEvents];
}


+ (UIBackgroundTaskIdentifier)backgroundPlayerID:(UIBackgroundTaskIdentifier)backTaskId{
    //设置并激活音频会话类别
    AVAudioSession *session=[AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    //允许应用程序接收远程控制
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    //设置后台任务ID
    UIBackgroundTaskIdentifier newTaskId = UIBackgroundTaskInvalid;
    newTaskId=[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    if(newTaskId!=UIBackgroundTaskInvalid&&backTaskId!=UIBackgroundTaskInvalid){
        [[UIApplication sharedApplication] endBackgroundTask:backTaskId];
    }
    return newTaskId;
}


#pragma mark - Event

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - event
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    
    switch (event.subtype){
        case UIEventSubtypeRemoteControlPlay:
            [self.player play];
            break;
            
        case UIEventSubtypeRemoteControlPause:
            [self.player pause];
            break;
            
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self.player playPreviewAudio];
            break;
            
        case UIEventSubtypeRemoteControlNextTrack:
            [self.player playNextAudio];
            break;
            
        case UIEventSubtypeRemoteControlStop:
            [self.player pause];
            break;
            
        case UIEventSubtypeRemoteControlTogglePlayPause:
            self.player.audioInfo.isPlaying ? [self.player pause] : [self.player play];
            break;
            
        default:
            break;
    }
}

@end
