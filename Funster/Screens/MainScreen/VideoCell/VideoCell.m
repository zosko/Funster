//
//  VideoCell.m
//  Funster
//
//  Created by Bosko Petreski on 8/2/19.
//  Copyright © 2019 Bosko Petreski. All rights reserved.
//

#import "VideoCell.h"

@implementation VideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.btnLike addTarget:self action:@selector(onBtnLike:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnComment addTarget:self action:@selector(onBtnComment:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnPlay addTarget:self action:@selector(onBtnPlay:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnShare addTarget:self action:@selector(onBtnShare:) forControlEvents:UIControlEventTouchUpInside];
        
    self.videoURL = [NSURL URLWithString:@"https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"];
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:[AVPlayer playerWithURL:self.videoURL]];
    playerLayer.frame = self.viewVideo.bounds;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
-(IBAction)onBtnLike:(UIButton *)sender{
    self.like();
}
-(IBAction)onBtnComment:(UIButton *)sender{
    self.comment();
}
-(IBAction)onBtnPlay:(UIButton *)sender{
    
    if(isPlaying){
        [playerLayer.player pause];
        [playerLayer removeFromSuperlayer];
    }
    else{
        [playerLayer.player play];
        [self.viewVideo.layer addSublayer:playerLayer];
    }
    
    isPlaying = !isPlaying;
    self.play(isPlaying);
}
-(IBAction)onBtnShare:(UIButton *)sender{
    self.share();
}

@end
