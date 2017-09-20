//
//  AudioInfo.h
//  SCYPlayer
//
//  Created by Saucheong Ye on 20/09/2017.
//  Copyright © 2017 sauchye.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioInfo : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *album;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *albumArtwork;
@property (nonatomic, strong) NSURL *streamingURL;


@property (nonatomic, assign) float progress;
@property (nonatomic, assign) float duration;
@property (nonatomic, assign) float cacheProgress;
@property (nonatomic, assign) float sliderProgress;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isPlayFinish;


+ (NSArray *)allAudioInfo;


@end
