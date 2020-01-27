//
//  ViewController.h
//  Funster
//
//  Created by Bosko Petreski on 8/1/19.
//  Copyright © 2019 Bosko Petreski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainScreen : UIViewController <UITableViewDelegate,UITableViewDataSource>{
    IBOutlet UITableView *tblMedia;
    NSMutableArray *arrMedia;
}

@end

