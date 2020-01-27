//
//  ImageCell.m
//  Funster
//
//  Created by Bosko Petreski on 8/2/19.
//  Copyright © 2019 Bosko Petreski. All rights reserved.
//

#import "ImageCell.h"

@implementation ImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.btnLike addTarget:self action:@selector(onBtnLike:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnComment addTarget:self action:@selector(onBtnComment:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnShare addTarget:self action:@selector(onBtnShare:) forControlEvents:UIControlEventTouchUpInside];
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
-(IBAction)onBtnShare:(UIButton *)sender{
    self.share();
}

@end
