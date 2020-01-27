//
//  VideoCell.h
//  Funster
//
//  Created by Bosko Petreski on 8/2/19.
//  Copyright © 2019 Bosko Petreski. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVKit;

NS_ASSUME_NONNULL_BEGIN

typedef void(^Clicked)(void);
typedef void(^ClickedPlay)(BOOL isPlaying);

@interface VideoCell : UITableViewCell{
    AVPlayerLayer *playerLayer;
    BOOL isPlaying;
}
@property (nonatomic,strong) IBOutlet UIView *viewVideo;
@property (nonatomic,strong) IBOutlet UIButton *btnComment;
@property (nonatomic,strong) IBOutlet UIButton *btnLike;
@property (nonatomic,strong) IBOutlet UIButton *btnPlay;
@property (nonatomic,strong) IBOutlet UIButton *btnShare;
@property (nonatomic,strong) NSURL *videoURL;
@property (nonatomic,copy) Clicked comment;
@property (nonatomic,copy) Clicked like;
@property (nonatomic,copy) ClickedPlay play;
@property (nonatomic,copy) Clicked share;

@end

NS_ASSUME_NONNULL_END
