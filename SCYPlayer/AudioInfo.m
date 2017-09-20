//
//  AudioInfo.m
//  SCYPlayer
//
//  Created by Saucheong Ye on 20/09/2017.
//  Copyright © 2017 sauchye.com. All rights reserved.
//

#import "AudioInfo.h"

@implementation AudioInfo


+ (NSArray *)allAudioInfo{
    
    AudioInfo *simpleThings = [[AudioInfo alloc] init];
    simpleThings.title = @"Simple Things";
    simpleThings.album = @"Simple Things - Single";
    simpleThings.artist = @"Something Like Seduction";
    simpleThings.albumArtwork = @"Simple Things";
    simpleThings.streamingURL = [NSURL URLWithString:@"http://download.lingyongqian.cn/music/AdagioSostenuto.mp3"];
    
    AudioInfo *inhaleTheFumes = [[AudioInfo alloc] init];
    inhaleTheFumes.title = @"Inhale the Fumes";
    inhaleTheFumes.album = @"Lost In Emerald Cove";
    inhaleTheFumes.artist = @"Something Like Seduction";
    inhaleTheFumes.albumArtwork = @"Lost In Emerald Cove";
    inhaleTheFumes.streamingURL = [NSURL URLWithString:@"http://download.lingyongqian.cn/music/ForElise.mp3"];
    
    AudioInfo *obligations = [[AudioInfo alloc] init];
    obligations.title = @"Obligations";
    obligations.album = @"Lost In Emerald Cove";
    obligations.artist = @"Something Like Seduction";
    obligations.albumArtwork = @"Lost In Emerald Cove";
    obligations.streamingURL = [NSURL URLWithString:@"http://testaudio.yxxy.tv/audio/1502442257.mp3"];
    return @[simpleThings, inhaleTheFumes, obligations];
}
@end
