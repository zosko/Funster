//
//  AdminScreen.h
//  Funster
//
//  Created by Bosko Petreski on 8/19/19.
//  Copyright © 2019 Bosko Petreski. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdminScreen : UIViewController <UITableViewDelegate,UITableViewDataSource>{
    IBOutlet UITableView *tblMedia;
    NSMutableArray *arrMedia;
}


@end

NS_ASSUME_NONNULL_END
