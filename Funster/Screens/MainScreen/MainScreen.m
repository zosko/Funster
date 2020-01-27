//
//  ViewController.m
//  Funster
//
//  Created by Bosko Petreski on 8/1/19.
//  Copyright © 2019 Bosko Petreski. All rights reserved.
//

#import "MainScreen.h"
#import "Model_Media.h"
#import "TextCell.h"
#import "VideoCell.h"
#import "ImageCell.h"
#import "MBProgressHUD.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "UIImagePickerController+Block.h"
#import "CommentsScreen.h"
#import "APICalls.h"
#import "AdminScreen.h"
#import "EXPhotoViewer.h"

@import MobileCoreServices;
@import Accounts;

typedef void(^VideoExport)(NSData *dataVideo);
typedef void(^Failed)(NSString *message);

@interface MainScreen (){
    NSInteger pageMedia;
}

@end

@implementation MainScreen

#pragma mark - CustomFunctions
-(void)getMedia{
    arrMedia = NSMutableArray.new;
    
    pageMedia = 0;
    
    [tblMedia.refreshControl beginRefreshing];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [APICalls GetMedia:pageMedia success:^(NSDictionary * _Nonnull response) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [self->tblMedia.refreshControl endRefreshing];
            
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
        [self->tblMedia.refreshControl endRefreshing];
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
-(void)liked:(UIView *)view media:(Model_Media *)media btn:(UIButton *)btn{
    if([NSUserDefaults.standardUserDefaults.dictionaryRepresentation.allKeys containsObject:@"user_id"]){
        NSDictionary *params = @{@"media_id":@(media.media_id),
                                 @"user_id":[NSUserDefaults.standardUserDefaults objectForKey:@"user_id"]
        };
        
        if(media.isLiked){
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [APICalls Dislike:params success:^(NSDictionary * _Nonnull response) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                media.isLiked = NO;
                
                MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:view animated:YES];
                hub.label.text = @"Не ми се допадна";
                hub.mode = MBProgressHUDModeText;
                [hub hideAnimated:YES afterDelay:1];
                
                [btn setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
                
            } failed:^(NSString * _Nonnull message) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self showMessage:message];
            }];
        }
        else{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [APICalls Like:params success:^(NSDictionary * _Nonnull response) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                media.isLiked = YES;
                
                MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:view animated:YES];
                hub.label.text = @"Ми се допадна!";
                hub.mode = MBProgressHUDModeText;
                [hub hideAnimated:YES afterDelay:1];
                
                [btn setImage:[UIImage imageNamed:@"liked"] forState:UIControlStateNormal];
                
            } failed:^(NSString * _Nonnull message) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self showMessage:message];
            }];
        }
    }
    else{
        [self showMessage:@"Не сте најавени"];
    }
}
-(void)exportFile:(NSURL *)url success:(VideoExport)success failed:(Failed)failed{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs = [documentsDirectory stringByAppendingPathComponent:@"temp.mov"];
    NSURL *urlToSave = [NSURL fileURLWithPath:myPathDocs];
    
    NSError *error;
    BOOL fileRemoved = [[NSFileManager defaultManager] removeItemAtPath:myPathDocs error:&error];
    if (!fileRemoved) {
        NSLog(@"Error removing document path: %@", error.localizedDescription);
    }
    
    AVURLAsset *assetVideo = [AVURLAsset assetWithURL:url];
    AVAssetExportSession *encoder = [AVAssetExportSession.alloc initWithAsset:assetVideo presetName:AVAssetExportPresetHighestQuality];
    encoder.outputFileType = AVFileTypeQuickTimeMovie;
    encoder.outputURL = urlToSave;
    
    [encoder exportAsynchronouslyWithCompletionHandler:^{
        if (encoder.status == AVAssetExportSessionStatusCompleted){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSData *videoToSend = [NSData dataWithContentsOfURL:urlToSave];
                success(videoToSend);
            }];
        }
        else if (encoder.status == AVAssetExportSessionStatusCancelled){
            failed(@"Video export cancelled");
        }
        else{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                failed(encoder.error.description);
            }];
        }
    }];
}
-(double)getHeightOfString:(NSString *)text width:(double)width font:(UIFont *)font{
    CGRect frame = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{ NSFontAttributeName:font }
                                      context:nil];
    return frame.size.height;
}
-(void)mediaFromCamera:(BOOL)isCamera recording:(BOOL)isVideo{
    UIImagePickerController *pickerController = [UIImagePickerController new];
    pickerController.mediaTypes = isVideo ? @[(NSString *)kUTTypeMovie] : @[(NSString *) kUTTypeImage];
    pickerController.sourceType = isCamera ? UIImagePickerControllerSourceTypeCamera: UIImagePickerControllerSourceTypePhotoLibrary;
    if(isVideo){
        pickerController.videoMaximumDuration = 15;
    }
    pickerController.finalizationBlock = ^(UIImagePickerController *picker, NSDictionary *info) {
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        if(isVideo){
            NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
            
            [self exportFile:videoUrl success:^(NSData *dataVideo) {
                
                NSLog(@"file size: %@",[NSByteCountFormatter stringFromByteCount:dataVideo.length countStyle:NSByteCountFormatterCountStyleFile]);
                
                AVURLAsset *asset = [AVURLAsset assetWithURL:videoUrl];
                AVAssetImageGenerator *generate = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
                generate.appliesPreferredTrackTransform = YES;
                CMTime time = CMTimeMake(1, 60);
                CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:nil];
                
                UIImage *imgThumbNail = [UIImage imageWithCGImage:imgRef];
                NSData *dataPicture = UIImageJPEGRepresentation(imgThumbNail, 0.5);
                
                NSData *base64DataImg= [dataPicture base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
                NSString *strBase64Img = [NSString.alloc initWithData:base64DataImg encoding:NSUTF8StringEncoding];
                
                NSData *base64DataVid = [dataVideo base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
                NSString *strBase64Vid = [NSString.alloc initWithData:base64DataVid encoding:NSUTF8StringEncoding];
                
                NSDictionary *params = @{@"type":@(0),
                                         @"base64_video":strBase64Vid,
                                         @"base64_thumbnail":strBase64Img,
                                         @"user_id":[NSUserDefaults.standardUserDefaults objectForKey:@"user_id"]
                                         };
                
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [APICalls SendMedia:params success:^(NSDictionary * _Nonnull response) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    [self showMessage:@"Видеото е испратено!"];
                    
                } failed:^(NSString * _Nonnull message) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self showMessage:message];
                }];
                
            } failed:^(NSString *message) {
                NSLog(@"video export error: %@",message);
            }];
        }
        else{
            NSData *dataPicture = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage], 0.5);
            
            NSData *base64Data = [dataPicture base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
            NSString *strBase64 = [NSString.alloc initWithData:base64Data encoding:NSUTF8StringEncoding];
            
            NSDictionary *params = @{@"type":@(1),
                                     @"base64_image":strBase64,
                                     @"user_id":[NSUserDefaults.standardUserDefaults objectForKey:@"user_id"],
                                     };
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [APICalls SendMedia:params success:^(NSDictionary * _Nonnull response) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                [self showMessage:@"Сликата е испратена!"];
                
            } failed:^(NSString * _Nonnull message) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self showMessage:message];
            }];
        }
    };
    pickerController.cancellationBlock = ^(UIImagePickerController *picker) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    };
    [self presentViewController:pickerController animated:YES completion:nil];
}
-(void)alertImage{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Испрати ни слика" message:@"Сакаш да пратиш нешто ново?" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Од галерија" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self mediaFromCamera:NO recording:NO];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Камера" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self mediaFromCamera:YES recording:NO];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Откажи" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)alertVideo{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Испрати ни видео" message:@"Сакаш да пратиш нешто ново?" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Од галерија" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self mediaFromCamera:NO recording:YES];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Камера" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self mediaFromCamera:YES recording:YES];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Откажи" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)alertText{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Испрати виц" message:@"\n\n\n\n\n\n\n" preferredStyle:UIAlertControllerStyleAlert];
    
    alert.view.autoresizesSubviews = YES;
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.font = [UIFont systemFontOfSize:15];
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *leadConstraint = [NSLayoutConstraint constraintWithItem:alert.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:textView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-5.0];
    NSLayoutConstraint *trailConstraint = [NSLayoutConstraint constraintWithItem:alert.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:textView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:5.0];
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:alert.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:textView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-54.0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:alert.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:textView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:54.0];
    [alert.view addSubview:textView];
    [NSLayoutConstraint activateConstraints:@[leadConstraint, trailConstraint, topConstraint, bottomConstraint]];
    
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Испрати" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if(textView.text.length < 3){
            [self showMessage:@"Полето е задолжително"];
            return;
        }
        
        NSDictionary *params = @{@"type":@(2),
                                 @"text":textView.text,
                                 @"user_id":[NSUserDefaults.standardUserDefaults objectForKey:@"user_id"]
                                 };
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [APICalls SendMedia:params success:^(NSDictionary * _Nonnull response) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self showMessage:@"Вицот е испратен!"];
        } failed:^(NSString * _Nonnull message) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self showMessage:message];
        }];
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Откажи" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)loginPassword{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Најава" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Најава" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if(alert.textFields.firstObject.text.length < 3 ||
           alert.textFields.lastObject.text.length < 3){
            [self showMessage:@"Полињата се задолжителни"];
            return;
        }
        
        NSDictionary *params = @{@"email":alert.textFields.firstObject.text,
                                 @"password":alert.textFields.lastObject.text,
                                 };
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [APICalls Login:params success:^(NSDictionary * _Nonnull response) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if([response[@"status"] boolValue]){
                [self showMessage:@"Успешно!"];
                [NSUserDefaults.standardUserDefaults setObject:@([response[@"user_id"] integerValue]) forKey:@"user_id"];
                [NSUserDefaults.standardUserDefaults synchronize];
                [self getMedia];
            }
            else{
                [self showMessage:@"Неуспешно!"];
            }
            
        } failed:^(NSString * _Nonnull message) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self showMessage:message];
        }];
        
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Откажи" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"E-mail";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Лозинка";
        textField.secureTextEntry = YES;
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)registerPassword{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Регистрација" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Регистрирај" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if(alert.textFields[0].text.length < 3 ||
           alert.textFields[1].text.length < 3 ||
           alert.textFields[2].text.length < 3){
            [self showMessage:@"Полињата се задолжителни"];
            return;
        }
        
        if(![alert.textFields[1].text isEqualToString:alert.textFields[2].text]){
            [self showMessage:@"Лозинките не исти"];
            return;
        }
        
        NSDictionary *params = @{@"email":alert.textFields.firstObject.text,
                                 @"password":alert.textFields.lastObject.text,
                                 };
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [APICalls Register:params success:^(NSDictionary * _Nonnull response) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            [self showMessage:@"Успешно!"];
            
        } failed:^(NSString * _Nonnull message) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self showMessage:message];
        }];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Откажи" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"E-mail";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Лозинка";
        textField.secureTextEntry = YES;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Повтори лозинка";
        textField.secureTextEntry = YES;
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)openComments:(Model_Media *)media{
    if([NSUserDefaults.standardUserDefaults.dictionaryRepresentation.allKeys containsObject:@"user_id"]){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CommentsScreen" bundle:nil];
        CommentsScreen *controller = [storyboard instantiateViewControllerWithIdentifier:@"CommentsScreen"];
        controller.media_id = media.media_id;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else{
        [self showMessage:@"Не сте најавени"];
    }
}

#pragma mark - IBActions
-(IBAction)onBtnLogin:(id)sender{
    if([NSUserDefaults.standardUserDefaults.dictionaryRepresentation.allKeys containsObject:@"user_id"]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Одјава" message:@"Сакаш да се одјавиш?" preferredStyle:UIAlertControllerStyleActionSheet];
        
        if([[NSUserDefaults.standardUserDefaults objectForKey:@"user_id"] integerValue] == 1){
            [alert addAction:[UIAlertAction actionWithTitle:@"Администрација" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AdminScreen" bundle:nil];
                AdminScreen *controller = [storyboard instantiateViewControllerWithIdentifier:@"AdminScreen"];
                [self.navigationController pushViewController:controller animated:YES];
            }]];
        }
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Да" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [NSUserDefaults.standardUserDefaults removePersistentDomainForName:NSBundle.mainBundle.bundleIdentifier];
            [self getMedia];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Не" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Најава" message:@"За да испратиш смешка или да коментар или лајкуваш, треба да се најавиш" preferredStyle:UIAlertControllerStyleActionSheet];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Најава" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self loginPassword];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Регистрација" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self registerPassword];
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Откажи" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}
-(IBAction)onBtnAdd:(UIButton *)sender{
    if([NSUserDefaults.standardUserDefaults.dictionaryRepresentation.allKeys containsObject:@"user_id"]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Испрати ни видео, слика или виц" message:@"Сакаш да додадеш нешто ново?" preferredStyle:UIAlertControllerStyleActionSheet];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Видео" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self alertVideo];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Слика" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self alertImage];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Виц" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self alertText];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Откажи" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else{
        [self showMessage:@"Потребна е најава"];
    }
}

#pragma mark - UITableViewDelegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrMedia.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
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
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Model_Media *media = arrMedia[indexPath.row];
    
    if(media.type == TypeMedia_Video){
        VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoCell" forIndexPath:indexPath];
        
        __unsafe_unretained VideoCell *weakCell = cell;
        
        [cell.btnPlay sd_setBackgroundImageWithURL:media.thumbnail forState:UIControlStateNormal];
        [cell.btnPlay setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        cell.videoURL = media.link;
        [weakCell.btnLike setImage:[UIImage imageNamed:media.isLiked ? @"liked" : @"like"] forState:UIControlStateNormal];
        
        [cell setLike:^{
            [self liked:weakCell media:media btn:weakCell.btnLike];
        }];
        [cell setComment:^{
            [self openComments:media];
        }];
        [cell setPlay:^(BOOL isPlaying) {
            [weakCell.btnPlay sd_setBackgroundImageWithURL:isPlaying ? [NSURL URLWithString:@""] : media.thumbnail forState:UIControlStateNormal];
            [weakCell.btnPlay setImage:isPlaying ? UIImage.new : [UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        }];
        
        [cell setShare:^{
            UIActivityViewController *activityViewController = [UIActivityViewController.alloc initWithActivityItems:@[media.link] applicationActivities:nil];
            
            activityViewController.modalPresentationStyle = UIModalPresentationPopover;
            activityViewController.popoverPresentationController.sourceView = self.view;
            activityViewController.popoverPresentationController.sourceRect = weakCell.frame;
            
            [self presentViewController:activityViewController animated:YES completion:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
        
        return cell;
    }
    else if(media.type == TypeMedia_Image){
        ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];
        __unsafe_unretained ImageCell *weakCell = cell;
        [cell.imgPicture sd_setImageWithURL:media.link];
        
        [weakCell.btnLike setImage:[UIImage imageNamed:media.isLiked ? @"liked" : @"like"] forState:UIControlStateNormal];
        
        [cell setLike:^{
            [self liked:weakCell media:media btn:weakCell.btnLike];
        }];
        [cell setComment:^{
            [self openComments:media];
        }];
        [cell setShare:^{
            UIActivityViewController *activityViewController = [UIActivityViewController.alloc initWithActivityItems:@[media.link] applicationActivities:nil];
            
            activityViewController.modalPresentationStyle = UIModalPresentationPopover;
            activityViewController.popoverPresentationController.sourceView = self.view;
            activityViewController.popoverPresentationController.sourceRect = weakCell.frame;
            
            [self presentViewController:activityViewController animated:YES completion:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
        
        return cell;
    }
    else{ //Text
        TextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell" forIndexPath:indexPath];
        cell.lblText.text = media.text;
        __unsafe_unretained TextCell *weakCell = cell;
        
        [weakCell.btnLike setImage:[UIImage imageNamed:media.isLiked ? @"liked" : @"like"] forState:UIControlStateNormal];
        
        [cell setLike:^{
            [self liked:weakCell media:media btn:weakCell.btnLike];
        }];
        [cell setComment:^{
            [self openComments:media];
        }];
        [cell setShare:^{
            UIActivityViewController *activityViewController = [UIActivityViewController.alloc initWithActivityItems:@[media.text] applicationActivities:nil];
            
            activityViewController.modalPresentationStyle = UIModalPresentationPopover;
            activityViewController.popoverPresentationController.sourceView = self.view;
            activityViewController.popoverPresentationController.sourceRect = weakCell.frame;
            
            [self presentViewController:activityViewController animated:YES completion:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
        
        return cell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Model_Media *media = arrMedia[indexPath.row];
    
    if(media.type == TypeMedia_Image){
        ImageCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [EXPhotoViewer showImageFrom:cell.imgPicture];
    }
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger lastSectionIndex = [tableView numberOfSections] - 1;
    NSInteger lastRowIndex = [tableView numberOfRowsInSection:lastSectionIndex] - 1;
    if ((indexPath.section == lastSectionIndex) && (indexPath.row == lastRowIndex)) {
        if(pageMedia > 0){
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [APICalls GetMedia:pageMedia success:^(NSDictionary * _Nonnull response) {
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

#pragma mark - UIViewDelegate
-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self getMedia];
    
    tblMedia.refreshControl = UIRefreshControl.new;
    [tblMedia.refreshControl addTarget:self action:@selector(getMedia) forControlEvents:UIControlEventValueChanged];
}


@end
