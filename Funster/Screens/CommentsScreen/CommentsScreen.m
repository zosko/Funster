//
//  CommentsScreen.m
//  Funster
//
//  Created by Bosko Petreski on 8/6/19.
//  Copyright © 2019 Bosko Petreski. All rights reserved.
//

#import "CommentsScreen.h"
#import "MBProgressHUD.h"
#import "APICalls.h"

@interface CommentsScreen (){
    NSInteger pageComments;
}

@end

@implementation CommentsScreen

#pragma mark - CustomFunctions
-(void)showMessage:(NSString *)message{
    MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hub.label.text = message;
    hub.mode = MBProgressHUDModeText;
    [hub hideAnimated:YES afterDelay:2];
}
-(void)getComments{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *params = @{@"media_id":@(self.media_id),
                             @"page":@(pageComments)
                             };
    [APICalls GetComments:params success:^(NSDictionary * _Nonnull response) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        self->pageComments++;
        
        NSArray *apiReturn = response[@"comments"];
        if(apiReturn.count == 0){
            self->pageComments = -10;
        }
        
        [self->arrComments addObjectsFromArray:apiReturn];
        [self->tblComments reloadData];
        
    } failed:^(NSString * _Nonnull message) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self showMessage:message];
    }];
}
-(double)getHeightOfString:(NSString *)text width:(double)width font:(UIFont *)font{
    CGRect frame = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{ NSFontAttributeName:font }
                                      context:nil];
    return frame.size.height;
}

#pragma mark - UITableViewDelegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrComments.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *comment = arrComments[indexPath.row][@"comment"];
    return [self getHeightOfString:comment width:self.view.frame.size.width font:[UIFont systemFontOfSize:17]] + 30;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
    cell.textLabel.text = arrComments[indexPath.row][@"comment"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",arrComments[indexPath.row][@"nickname"]];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger lastSectionIndex = [tableView numberOfSections] - 1;
    NSInteger lastRowIndex = [tableView numberOfRowsInSection:lastSectionIndex] - 1;
    if ((indexPath.section == lastSectionIndex) && (indexPath.row == lastRowIndex)) {
        if(pageComments > 0){
            [self getComments];
        }
    }
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return YES;
}
-(nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewRowAction *actionEdit = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Измени" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Измени коментар" message:@"\n\n\n\n\n\n\n" preferredStyle:UIAlertControllerStyleAlert];
        
        alert.view.autoresizesSubviews = YES;
        
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
        textView.font = [UIFont systemFontOfSize:15];
        textView.text = self->arrComments[indexPath.row][@"comment"];
        textView.autocorrectionType = UITextAutocorrectionTypeNo;
        textView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSLayoutConstraint *leadConstraint = [NSLayoutConstraint constraintWithItem:alert.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:textView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-5.0];
        NSLayoutConstraint *trailConstraint = [NSLayoutConstraint constraintWithItem:alert.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:textView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:5.0];
        
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:alert.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:textView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-54.0];
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:alert.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:textView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:54.0];
        [alert.view addSubview:textView];
        [NSLayoutConstraint activateConstraints:@[leadConstraint, trailConstraint, topConstraint, bottomConstraint]];
        
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Зачувај" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if(textView.text.length < 3){
                [self showMessage:@"Полето е задолжително"];
                return;
            }
            
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Откажи" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }];
    UITableViewRowAction *actionDelete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Избриши" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
    }];
    
    return @[actionEdit,actionDelete];
}

#pragma mark - IBActions
-(IBAction)onBtnBack:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)onTxtEnterComment:(UITextField *)sender{
    [sender resignFirstResponder];
    
    NSDictionary *params = @{@"comment":sender.text,
                             @"media_id":@(self.media_id),
                             @"user_id":[NSUserDefaults.standardUserDefaults objectForKey:@"user_id"]
                             };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [APICalls SendComment:params success:^(NSDictionary * _Nonnull response) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        sender.text = @"";
        [self showMessage:@"Испрaтен коментар"];
        
        self->pageComments = 0;
        self->arrComments = NSMutableArray.new;
        [self getComments];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self->tblComments setContentOffset:CGPointZero animated:YES];
        });
        
    } failed:^(NSString * _Nonnull message) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self showMessage:message];
    }];
}

#pragma mark - UIViewDelegates
-(void)viewDidLoad {
    [super viewDidLoad];
    
    pageComments = 0;
    arrComments = NSMutableArray.new;
    
    tblComments.tableFooterView = UIView.new;
    
    [self getComments];
    
    [NSNotificationCenter.defaultCenter addObserverForName:UIKeyboardWillShowNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
       
        NSDictionary *info = note.userInfo;
        CGRect keyboardFrame = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        [UIView animateWithDuration:0.1 animations:^{
            self->viewBottom.frame = CGRectMake(self->viewBottom.frame.origin.x,
                                                self->viewBottom.frame.origin.y - (keyboardFrame.size.height + 20),
                                                self->viewBottom.frame.size.width,
                                                self->viewBottom.frame.size.height);
        }];
        
    }];
    
    [NSNotificationCenter.defaultCenter addObserverForName:UIKeyboardWillHideNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *info = note.userInfo;
        CGRect keyboardFrame = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        [UIView animateWithDuration:0.1 animations:^{
            self->viewBottom.frame = CGRectMake(self->viewBottom.frame.origin.x,
                                                self->viewBottom.frame.origin.y + (keyboardFrame.size.height + 20),
                                                self->viewBottom.frame.size.width,
                                                self->viewBottom.frame.size.height);
        }];
    }];
}

@end
