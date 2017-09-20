//
//  SCYPlayer.m
//  SCYPlayer
//
//  Created by Saucheong Ye on 20/09/2017.
//  Copyright © 2017 sauchye.com. All rights reserved.
//
#define isiOS10Later ([[[UIDevice currentDevice] systemVersion] floatValue]) >= 10.0

#import "SCYPlayer.h"
#import <MediaPlayer/MediaPlayer.h>

@interface SCYPlayer ()

@property (nonatomic, strong) id timeObserve;
@property (nonatomic, strong) AVPlayerItem *currentItem;
@property (nonatomic, strong) NSURL * url;


@end

@implementation SCYPlayer

+ (instancetype)defaultManager{
    static SCYPlayer *magager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        magager = [[SCYPlayer alloc] init];
    });
    return magager;
}


- (AVPlayer *)player{
    if (!_player) {
        _player = [[AVPlayer alloc] init];
        _player.volume = 0.5;
    }
    return _player;
}

- (void)playWithIndex:(NSInteger)index{
    if (self.dataArray.count) {
        self.currentIndex = index;
        if (self.currentIndex < self.dataArray.count) {
            self.audioInfo = self.dataArray[index];
            [self stop];
            self.audioInfo.isPlaying = YES;
            self.audioInfo.isPlayFinish = NO;
            self.url = self.audioInfo.streamingURL;
            [self replaceItemWithURL:self.url];
        }
    }
}

- (void)replaceItemWithURL:(NSURL *)url {
    self.url = url;
    [self reloadCurrentItem];
}


- (void)reloadCurrentItem {
    
    if ([self.url.absoluteString hasPrefix:@"http"]) {
        self.currentItem = [AVPlayerItem playerItemWithURL:self.url];
        self.player = [AVPlayer playerWithPlayerItem:self.currentItem];
        if (isiOS10Later) {
            self.player.automaticallyWaitsToMinimizeStalling = NO;
        }
        [self addPlayItembserver];
        _state = SCYPlayerStateStarting;
    }else{
        _state = SCYPlayerStateURLError;
    }
}


- (void)playPreviewAudio{
    self.currentIndex --;
    if (self.currentIndex < 0) {
        self.currentIndex = self.dataArray.count-1;
    }
    [self playWithIndex:self.currentIndex];
}


- (void)playNextAudio{
    self.currentIndex ++;
    if (self.currentIndex > self.dataArray.count-1) {
        self.currentIndex = 0;
    }
    [self playWithIndex:self.currentIndex];
}



- (void)play {
    [self.player play];
    self.audioInfo.isPlaying = YES;
    _state = SCYPlayerStatePlaying;
    if (self.updateCurrentAudioPlayerSate) {
        self.updateCurrentAudioPlayerSate(_state);
    }
}

- (void)pause {
    [self.player pause];
    self.audioInfo.isPlaying = NO;
    _state = SCYPlayerStatePaused;
    if (self.updateCurrentAudioPlayerSate) {
        self.updateCurrentAudioPlayerSate(_state);
    }
}


- (void)stop {
    [self.player pause];
    [self removeObserver];
    [self removeData];
    self.currentItem = nil;
    self.player = nil;
    self.state = SCYPlayerStateStopped;
    if (self.updateCurrentAudioPlayerSate) {
        self.updateCurrentAudioPlayerSate(_state);
    }
}

- (void)remove{
    [self stop];
    self.dataArray = @[];
}


- (void)seekToTime:(CGFloat)seconds {
    if (seconds > 0) {
        [self.player seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
            if (finished) {
                if (self.audioInfo.isPlaying) {
                    [self play];
                }
                self.audioInfo.progress = seconds;
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [self setupLockScreenInfo];
                });
            }
        }];
    }else{
        [self.player seekToTime:kCMTimeZero];
    }
}

- (void)addPlayItembserver{
    [self.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [self.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - KVO
- (void)addObserver {
    AVPlayerItem * songItem = self.currentItem;
    //播放完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:songItem];
    
    __weak typeof(self) weakSelf = self;
    self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0)
                                                                 queue:dispatch_get_main_queue()
                                                            usingBlock:^(CMTime time) {
                                                                CGFloat current = CMTimeGetSeconds(time);
                                                                CGFloat total = CMTimeGetSeconds(songItem.duration);
                                                                
                                                                weakSelf.audioInfo.duration = total;
                                                                weakSelf.audioInfo.progress = current;
                                                                weakSelf.audioInfo.sliderProgress = current / total;
                                                                
                                                                if (weakSelf.updateCurrentAudioPlayer) {
                                                                    weakSelf.updateCurrentAudioPlayer(weakSelf.audioInfo);
                                                                }
                                                                NSLog(@"=====duration=====\n%.f", total);
                                                                NSLog(@"=====progress=====\n%.f", current);
                                                            }];
}


- (void)setupLockScreenInfo{
    if (self.audioInfo) {
        MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
        NSMutableDictionary *playingInfoDict = [NSMutableDictionary dictionary];
        [playingInfoDict setObject:self.audioInfo.album forKey:MPMediaItemPropertyAlbumTitle];
        [playingInfoDict setObject:self.audioInfo.artist forKey:MPMediaItemPropertyArtist];
        [playingInfoDict setObject:self.audioInfo.title forKey:MPMediaItemPropertyTitle];
        
        UIImage *image = [UIImage imageNamed:self.audioInfo.albumArtwork];
        if (image) {
            MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:image];
            [playingInfoDict setObject:artwork forKey:MPMediaItemPropertyArtwork];
        }
        [playingInfoDict setObject:@(1) forKey:MPNowPlayingInfoPropertyPlaybackRate];
        [playingInfoDict setObject:@(self.audioInfo.duration) forKey:MPMediaItemPropertyPlaybackDuration];
        [playingInfoDict setObject:[NSNumber numberWithFloat:(self.audioInfo.progress)] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        playingInfoCenter.nowPlayingInfo = playingInfoDict;
    }
}


- (void)removeObserver {
    AVPlayerItem * songItem = self.currentItem;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.timeObserve) {
        [self.player removeTimeObserver:self.timeObserve];
        self.timeObserve = nil;
    }
    
    [songItem removeObserver:self forKeyPath:@"status"];
    [songItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [songItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [songItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    //    [self.player removeObserver:self forKeyPath:@"rate"];
    [self.player replaceCurrentItemWithPlayerItem:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    AVPlayerItem * songItem = object;
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSArray * array = songItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue]; //本次缓冲的时间范围
        NSTimeInterval totalBuffer = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration); //缓冲总长度
        NSLog(@"共缓冲%.2f",totalBuffer);
        _state = SCYPlayerStateBuffering;
    }
    
    //    if ([keyPath isEqualToString:@"rate"]) {
    //        if (self.player.rate == 0.0) {
    //            _state = SUPlayerStatePaused;
    //            self.isPlaying = NO;
    //        }else {
    //            _state = SUPlayerStatePlaying;
    //            self.isPlaying = YES;
    //        }
    //    }
    
    if ([keyPath isEqualToString:@"status"]) {
        if (self.player.status == AVPlayerStatusReadyToPlay) {
            if (self.audioInfo.isPlaying) {
                CMTime duration = songItem.duration;
                float audioDurationSeconds = CMTimeGetSeconds(duration);
                _state = SCYPlayerStatePlaying;
                self.audioInfo.duration = audioDurationSeconds;
                [self play];
                [self addObserver];
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [self setupLockScreenInfo];
                });
            }
        }else{
            _state = SCYPlayerStateLoadError;
            self.audioInfo.isPlaying = NO;
        }
    }
    
    
    if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        //监听播放器在缓冲数据的状态
        _state = SCYPlayerStateBuffering;
        NSLog(@"缓冲不足暂停了");
    }
    
    if([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        CMTime duration = songItem.duration;
        float audioDurationSeconds = CMTimeGetSeconds(duration);
        self.audioInfo.duration = audioDurationSeconds;
        _state = SCYPlayerStatePlaying;
        if (self.audioInfo.isPlaying) {
            [self play];
        }
        NSLog(@"缓冲达到可播放程度了");
    }
    
    if (self.updateCurrentAudioPlayerSate) {
        self.updateCurrentAudioPlayerSate(_state);
    }
    
}

- (void)playbackFinished {
    NSLog(@"播放完成");
    [self pause];
    _state = SCYPlayerStateFinished;
    if (self.updateCurrentAudioPlayerSate) {
        self.updateCurrentAudioPlayerSate(_state);
    }
}


- (void)removeData{
    self.audioInfo.isPlaying = NO;
    self.audioInfo.progress = 0.0;
    self.audioInfo.duration = 0.0;
    self.audioInfo.cacheProgress = 0.0;
    self.audioInfo.sliderProgress = 0;
}


@end
