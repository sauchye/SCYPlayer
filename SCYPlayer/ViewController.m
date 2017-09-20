//
//  ViewController.m
//  SCYPlayer
//
//  Created by Saucheong Ye on 20/09/2017.
//  Copyright © 2017 sauchye.com. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *albumImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (nonatomic, strong) SCYPlayer *player;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.slider.value = 0.f;
    NSArray *audioInfo = [AudioInfo allAudioInfo];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.player = delegate.player;
    self.player.dataArray = audioInfo;
    
    [self.playButton setTitle:@"play" forState:UIControlStateSelected];
    [self.playButton setTitle:@"pause" forState:UIControlStateNormal];
    self.playButton.selected = YES;
    __weak typeof(self) weakSelf = self;
    [self.player setUpdateCurrentAudioPlayer:^(AudioInfo *audioInfo) {
        weakSelf.currentLabel.text = [weakSelf convertStringWithTime:audioInfo.progress];
        weakSelf.totalLabel.text   = [weakSelf convertStringWithTime:audioInfo.duration];
        weakSelf.slider.value      = audioInfo.sliderProgress;
        weakSelf.albumImage.image  = [UIImage imageNamed:audioInfo.albumArtwork];
        weakSelf.titleLabel.text   = audioInfo.title;
    }];
    
    [self.player setUpdateCurrentAudioPlayerSate:^(SCYPlayerState state) {
        if (state == SCYPlayerStateStarting) {
            NSLog(@"SCYPlayerStateStarting");
        }else if (state == SCYPlayerStateBuffering){
            NSLog(@"SCYPlayerStateStarting");
        }else if (state == SCYPlayerStatePlaying){
            NSLog(@"SCYPlayerStatePlaying");
        }else if (state == SCYPlayerStatePaused){
            NSLog(@"SCYPlayerStatePaused");
        }else if (state == SCYPlayerStateLoadError){
            NSLog(@"SCYPlayerStateLoadError");
            weakSelf.playButton.selected = NO;
        }else if (state == SCYPlayerStateURLError){
            NSLog(@"SCYPlayerStateURLError");
            weakSelf.playButton.selected = NO;
        }else if (state == SCYPlayerStateFinished){
            NSLog(@"SCYPlayerStateFinished");
            [weakSelf.player playNextAudio];
        }
    }];

}


- (IBAction)play:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (!sender.selected) {
        if (self.player.audioInfo.isPlaying) {
            [self.player play];
        }else{
            [self.player playWithIndex:0];
        }
    }else{
        [self.player pause];
    }
}

- (IBAction)next:(id)sender {
    [self.player playNextAudio];
    self.playButton.selected = NO;
}

- (IBAction)preview:(id)sender {
    [self.player playPreviewAudio];
    self.playButton.selected = NO;
}

- (IBAction)valueChanged:(UISlider *)sender {
    float seekTime = sender.value * self.player.audioInfo.duration;
    [self.player seekToTime:seekTime];
    self.currentLabel.text = [self convertStringWithTime:seekTime];
}


- (NSString *)convertStringWithTime:(float)time {
    if (isnan(time)) time = 0.f;
    int  second = time;
    int min = second / 60.0;
    int sec = second % 60;
    NSString * minStr  = [NSString stringWithFormat:@"%02d",min];
    NSString * secStr  =  [NSString stringWithFormat:@"%02d",sec];
    NSString * timeStr = [NSString stringWithFormat:@"%@:%@",minStr, secStr];
    return timeStr;
}


@end
