//
//  SCYPlayer.h
//  SCYPlayer
//
//  Created by Saucheong Ye on 20/09/2017.
//  Copyright © 2017 sauchye.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioInfo.h"

typedef NS_ENUM(NSInteger, SCYPlayerState) {
    SCYPlayerStateStarting,
    SCYPlayerStateBuffering,
    SCYPlayerStatePlaying,
    SCYPlayerStatePaused,
    SCYPlayerStateFinished,
    SCYPlayerStateStopped,
    SCYPlayerStateLoadError,
    SCYPlayerStateURLError
};


@interface SCYPlayer : NSObject
@property (nonatomic, assign) SCYPlayerState state;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AudioInfo *audioInfo;
@property (nonatomic, strong) NSArray <AudioInfo *> *dataArray;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, copy) void(^updateCurrentAudioPlayer)(AudioInfo *audioInfo);
@property (nonatomic, copy) void(^updateCurrentAudioPlayerSate)(SCYPlayerState state);


+ (instancetype)defaultManager;

- (void)playWithIndex:(NSInteger)index;

- (void)replaceItemWithURL:(NSURL *)url;

- (void)playNextAudio;///< Next

- (void)playPreviewAudio;///< Preview
- (void)play;
- (void)pause;
- (void)stop;
- (void)remove;

- (void)setupLockScreenInfo;///< 锁屏信息

- (void)seekToTime:(CGFloat)seconds;




@end
