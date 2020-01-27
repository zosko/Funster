//
//  Model_Media.h
//  Funster
//
//  Created by Bosko Petreski on 8/2/19.
//  Copyright © 2019 Bosko Petreski. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TypeMedia) {
    TypeMedia_Video,
    TypeMedia_Image,
    TypeMedia_Text,
};

@interface Model_Media : NSObject

@property (nonatomic,assign) NSInteger media_id;
@property (nonatomic,strong) NSURL *link;
@property (nonatomic,assign) TypeMedia type;
@property (nonatomic,strong) NSString *text;
@property (nonatomic,strong) NSURL *thumbnail;
@property (nonatomic,assign) NSInteger likes;
@property (nonatomic,assign) BOOL isLiked;

-(Model_Media *)initWithResponse:(NSDictionary *)response;
@end

NS_ASSUME_NONNULL_END
