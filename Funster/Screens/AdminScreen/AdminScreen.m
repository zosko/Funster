//
//  AdminScreen.m
//  Funster
//
//  Created by Bosko Petreski on 8/19/19.
//  Copyright © 2019 Bosko Petreski. All rights reserved.
//

#import "AdminScreen.h"
#import "Model_Media.h"
#import "TextCell.h"
#import "VideoCell.h"
#import "ImageCell.h"
#import "MBProgressHUD.h"
#import "APICalls.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"

@interface AdminScreen (){
    NSInteger pageMedia;
    BOOL showUsers;
}

@end

@implementation AdminScreen

#pragma mark - IBActions
-(IBAction)onBtnBack:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)onBtnMedia:(UIButton *)sender{
    [self getAdminMedias];
}
-(IBAction)onBtnUsers:(UIButton *)sender{
    [self getAdminUsers];
}

#pragma mark - CustomFunctions
-(void)getAdminUsers{
    arrMedia = NSMutableArray.new;
    
    pageMedia = 0;
    showUsers = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [APICalls GetAdminUsers:pageMedia success:^(NSDictionary * _Nonnull response) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        self->pageMedia++;
        
        NSArray *apiReturn = response[@"users"];
        
        [self->arrMedia addObjectsFromArray:apiReturn];
        
        if(apiReturn.count == 0){
            self->pageMedia = -10;
        }
        
        [self->tblMedia reloadData];
        
    } failed:^(NSString * _Nonnull message) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self showMessage:message];
    }];
}
-(void)getAdminMedias{
    arrMedia = NSMutableArray.new;
    showUsers = NO;
    pageMedia = 0;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [APICalls GetAdminMedia:pageMedia success:^(NSDictionary * _Nonnull response) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        self->pageMedia++;
        
        NSArray *apiReturn = response[@"media"];
        
        if(apiReturn.count == 0){
            self->pageMedia = -10;
        }
        
        for(NSDictionary *response in apiReturn){
            [self->arrMedia addObject:[Model_Media.alloc initWithResponse:response]];
        }
        [self->tblMedia reloadData];
        
    } failed:^(NSString * _Nonnull message) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self showMessage:message];
    }];
}
-(void)showMessage:(NSString *)message{
    MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hub.label.text = message;
    hub.mode = MBProgressHUDModeText;
    [hub hideAnimated:YES afterDelay:2];
}
-(double)getHeightOfString:(NSString *)text width:(double)width font:(UIFont *)font{
    CGRect frame = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{ NSFontAttributeName:font }
                                      context:nil];
    return frame.size.height;
}

#pragma mark - UITableViewDelegates
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return showUsers;
}
-(nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewRowAction *actionEdit = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Измени" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Промена" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Промени" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if(alert.textFields.firstObject.text.length < 3){
                [self showMessage:@"Полињата се задолжителни"];
                return;
            }
            
            NSDictionary *params = @{@"user_id":self->arrMedia[indexPath.row][@"id"],
                                     @"nickname":alert.textFields.firstObject.text,
                                     };
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [APICalls EditUser:params success:^(NSDictionary * _Nonnull response) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                [self showMessage:@"Успешно!"];
                [self getAdminUsers];
                
            } failed:^(NSString * _Nonnull message) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self showMessage:message];
            }];
        }]];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"nickname";
            textField.text = [NSString stringWithFormat:@"%@",self->arrMedia[indexPath.row][@"nickname"]];
        }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Откажи" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }];
    UITableViewRowAction *actionDelete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Избриши" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        NSDictionary *params = @{@"user_id":self->arrMedia[indexPath.row][@"id"],};
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [APICalls RemoveUser:params success:^(NSDictionary * _Nonnull response) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            [self showMessage:@"Успешно!"];
            [self getAdminUsers];
            
        } failed:^(NSString * _Nonnull message) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self showMessage:message];
        }];
    }];
    
    return @[actionEdit,actionDelete];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrMedia.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(showUsers){
        return 40;
    }
    else{
        Model_Media *media = arrMedia[indexPath.row];
        if(media.type == TypeMedia_Video){
            return 260;
        }
        else if(media.type == TypeMedia_Image){
            return 260;
        }
        else{
            return [self getHeightOfString:media.text width:290 font:[UIFont systemFontOfSize:20]] + 90;
        }
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(showUsers){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UsersCell" forIndexPath:indexPath];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@",arrMedia[indexPath.row][@"nickname"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",arrMedia[indexPath.row][@"email"]];
        
        return cell;
    }
    else{
        Model_Media *media = arrMedia[indexPath.row];
        
        if(media.type == TypeMedia_Video){
            VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoCell" forIndexPath:indexPath];
            
            __unsafe_unretained VideoCell *weakCell = cell;
            
            [cell.btnPlay sd_setBackgroundImageWithURL:media.thumbnail forState:UIControlStateNormal];
            [cell.btnPlay setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            
            [cell setLike:^{
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [APICalls ApproveMedia:@{@"media_id":@(media.media_id)} success:^(NSDictionary * _Nonnull response) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self getAdminMedias];
                } failed:^(NSString * _Nonnull message) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self showMessage:message];
                }];
            }];
            [cell setComment:^{
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [APICalls RemoveMedia:@{@"media_id":@(media.media_id)} success:^(NSDictionary * _Nonnull response) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self getAdminMedias];
                } failed:^(NSString * _Nonnull message) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self showMessage:message];
                }];
            }];
            [cell setPlay:^(BOOL isPlaying) {
                [weakCell.btnPlay sd_setBackgroundImageWithURL:isPlaying ? [NSURL URLWithString:@""] : media.thumbnail forState:UIControlStateNormal];
                [weakCell.btnPlay setImage:isPlaying ? UIImage.new : [UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            }];
            
            return cell;
        }
        else if(media.type == TypeMedia_Image){
            ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];
            
            [cell.imgPicture sd_setImageWithURL:media.link];
            
            [cell setLike:^{
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [APICalls ApproveMedia:@{@"media_id":@(media.media_id)} success:^(NSDictionary * _Nonnull response) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self getAdminMedias];
                } failed:^(NSString * _Nonnull message) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self showMessage:message];
                }];
            }];
            [cell setComment:^{
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [APICalls RemoveMedia:@{@"media_id":@(media.media_id)} success:^(NSDictionary * _Nonnull response) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self getAdminMedias];
                } failed:^(NSString * _Nonnull message) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self showMessage:message];
                }];
            }];
            
            return cell;
        }
        else{ //Text
            TextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell" forIndexPath:indexPath];
            cell.lblText.text = media.text;
            
            [cell setLike:^{
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [APICalls ApproveMedia:@{@"media_id":@(media.media_id)} success:^(NSDictionary * _Nonnull response) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self getAdminMedias];
                } failed:^(NSString * _Nonnull message) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self showMessage:message];
                }];
            }];
            [cell setComment:^{
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [APICalls RemoveMedia:@{@"media_id":@(media.media_id)} success:^(NSDictionary * _Nonnull response) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self getAdminMedias];
                } failed:^(NSString * _Nonnull message) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self showMessage:message];
                }];
            }];
            
            return cell;
        }
    }
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger lastSectionIndex = [tableView numberOfSections] - 1;
    NSInteger lastRowIndex = [tableView numberOfRowsInSection:lastSectionIndex] - 1;
    if ((indexPath.section == lastSectionIndex) && (indexPath.row == lastRowIndex)) {
        if(pageMedia > 0){
            
            if(showUsers){
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [APICalls GetAdminUsers:pageMedia success:^(NSDictionary * _Nonnull response) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    self->pageMedia++;
                    
                    NSArray *apiReturn = response[@"media"];
                    if(apiReturn.count == 0){
                        self->pageMedia = -10;
                    }
                    
                    [self->arrMedia addObjectsFromArray:apiReturn];
                    
                    [self->tblMedia reloadData];
                    
                } failed:^(NSString * _Nonnull message) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self showMessage:message];
                }];
            }
            else{
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [APICalls GetAdminMedia:pageMedia success:^(NSDictionary * _Nonnull response) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    self->pageMedia++;
                    
                    NSArray *apiReturn = response[@"media"];
                    if(apiReturn.count == 0){
                        self->pageMedia = -10;
                    }
                    
                    for(NSDictionary *response in apiReturn){
                        [self->arrMedia addObject:[Model_Media.alloc initWithResponse:response]];
                    }
                    [self->tblMedia reloadData];
                    
                } failed:^(NSString * _Nonnull message) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self showMessage:message];
                }];
            }
        }
    }
}

#pragma mark - UIViewDelegate
-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self getAdminMedias];
}

@end
