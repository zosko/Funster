//
//  ImageCell.h
//  Funster
//
//  Created by Bosko Petreski on 8/2/19.
//  Copyright © 2019 Bosko Petreski. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^Clicked)(void);

@interface ImageCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UIImageView *imgPicture;
@property (nonatomic,strong) IBOutlet UIButton *btnComment;
@property (nonatomic,strong) IBOutlet UIButton *btnLike;
@property (nonatomic,strong) IBOutlet UIButton *btnShare;
@property (nonatomic,copy) Clicked comment;
@property (nonatomic,copy) Clicked like;
@property (nonatomic,copy) Clicked share;

@end

NS_ASSUME_NONNULL_END
