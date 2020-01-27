//
//  CommentsScreen.h
//  Funster
//
//  Created by Bosko Petreski on 8/6/19.
//  Copyright © 2019 Bosko Petreski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model_Media.h"

NS_ASSUME_NONNULL_BEGIN

@interface CommentsScreen : UIViewController <UITableViewDelegate,UITableViewDataSource>{
    IBOutlet UITableView *tblComments;
    NSMutableArray *arrComments;
    
    IBOutlet UITextField *txtComment;
    IBOutlet UIView *viewBottom;
}
@property (nonatomic,assign) NSInteger media_id;
@end

NS_ASSUME_NONNULL_END
