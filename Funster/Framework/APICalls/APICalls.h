//
//  APICalls.h
//  Funster
//
//  Created by Bosko Petreski on 8/14/19.
//  Copyright © 2019 Bosko Petreski. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define API_URL @"http://localhost:16003"

typedef void(^APISuccess)(NSDictionary *response);
typedef void(^APIFailed)(NSString *message);

@interface APICalls : NSObject

+(void)Login:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed;
+(void)Register:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed;
+(void)SendMedia:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed;
+(void)GetMedia:(NSInteger)page success:(APISuccess)success failed:(APIFailed)failed;
+(void)Like:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed;
+(void)Dislike:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed;
+(void)GetComments:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed;
+(void)SendComment:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed;
+(void)RemoveComment:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed;
+(void)EditComment:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed;

+(void)GetAdminMedia:(NSInteger)page success:(APISuccess)success failed:(APIFailed)failed;
+(void)GetAdminUsers:(NSInteger)page success:(APISuccess)success failed:(APIFailed)failed;
+(void)EditUser:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed;
+(void)RemoveUser:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed;
+(void)RemoveMedia:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed;
+(void)ApproveMedia:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed;

@end

NS_ASSUME_NONNULL_END
