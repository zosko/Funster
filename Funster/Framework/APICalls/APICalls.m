//
//  APICalls.m
//  Funster
//
//  Created by Bosko Petreski on 8/14/19.
//  Copyright © 2019 Bosko Petreski. All rights reserved.
//

#import "APICalls.h"

@implementation APICalls

+(void)post:(NSDictionary *)params url:(NSString *)url success:(APISuccess)success failed:(APIFailed)failed{
    NSString *strURL = [NSString stringWithFormat:@"%@%@",API_URL,url];
    
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strURL]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:bodyData];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if([[NSThread currentThread] isMainThread]){
            if(error){
                failed(error.userInfo[@"NSLocalizedDescription"]);
            }
            else{
                id dictReturn = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if(dictReturn){
                    success(dictReturn);
                }
                else{
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                    failed([NSString stringWithFormat:@"Error CODE: %d",(int)httpResponse.statusCode]);
                }
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(error){
                    failed(error.userInfo[@"NSLocalizedDescription"]);
                }
                else{
                    id dictReturn = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if(dictReturn){
                        success(dictReturn);
                    }
                    else{
                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                        failed([NSString stringWithFormat:@"Error CODE: %d",(int)httpResponse.statusCode]);
                    }
                }
            });
        }
    }] resume];
}

+(void)Login:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed{
    [self post:params url:@"/login" success:^(NSDictionary * _Nonnull response) {
        success(response);
    } failed:^(NSString * _Nonnull message) {
        failed(message);
    }];
}
+(void)Register:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed{
    [self post:params url:@"/register" success:^(NSDictionary * _Nonnull response) {
        success(response);
    } failed:^(NSString * _Nonnull message) {
        failed(message);
    }];
}
+(void)SendMedia:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed{
    [self post:params url:@"/media/add" success:^(NSDictionary * _Nonnull response) {
        success(response);
    } failed:^(NSString * _Nonnull message) {
        failed(message);
    }];
}
+(void)GetMedia:(NSInteger)page success:(APISuccess)success failed:(APIFailed)failed{
    [self post:@{} url:[NSString stringWithFormat:@"/media/page/%ld",page] success:^(NSDictionary * _Nonnull response) {
        success(response);
    } failed:^(NSString * _Nonnull message) {
        failed(message);
    }];
}
+(void)Like:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed{
    [self post:params url:@"/like" success:^(NSDictionary * _Nonnull response) {
        success(response);
    } failed:^(NSString * _Nonnull message) {
        failed(message);
    }];
}
+(void)Dislike:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed{
    [self post:params url:@"/dislike" success:^(NSDictionary * _Nonnull response) {
        success(response);
    } failed:^(NSString * _Nonnull message) {
        failed(message);
    }];
}
+(void)GetComments:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed{
    [self post:params url:@"/comments" success:^(NSDictionary * _Nonnull response) {
        success(response);
    } failed:^(NSString * _Nonnull message) {
        failed(message);
    }];
}
+(void)SendComment:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed{
    [self post:params url:@"/comments/add" success:^(NSDictionary * _Nonnull response) {
        success(response);
    } failed:^(NSString * _Nonnull message) {
        failed(message);
    }];
}
+(void)RemoveComment:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed{
    [self post:params url:@"/comments/remove" success:^(NSDictionary * _Nonnull response) {
        success(response);
    } failed:^(NSString * _Nonnull message) {
        failed(message);
    }];
}
+(void)EditComment:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed{
    [self post:params url:@"/comments/edit" success:^(NSDictionary * _Nonnull response) {
        success(response);
    } failed:^(NSString * _Nonnull message) {
        failed(message);
    }];
}

+(void)GetAdminMedia:(NSInteger)page success:(APISuccess)success failed:(APIFailed)failed{
    [self post:@{} url:[NSString stringWithFormat:@"/admin/media/page/%ld",page] success:^(NSDictionary * _Nonnull response) {
        success(response);
    } failed:^(NSString * _Nonnull message) {
        failed(message);
    }];
}
+(void)GetAdminUsers:(NSInteger)page success:(APISuccess)success failed:(APIFailed)failed{
    [self post:@{} url:[NSString stringWithFormat:@"/admin/users/page/%ld",page] success:^(NSDictionary * _Nonnull response) {
        success(response);
    } failed:^(NSString * _Nonnull message) {
        failed(message);
    }];
}
+(void)EditUser:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed{
    [self post:params url:@"/admin/users/edit" success:^(NSDictionary * _Nonnull response) {
        success(response);
    } failed:^(NSString * _Nonnull message) {
        failed(message);
    }];
}
+(void)RemoveUser:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed{
    [self post:params url:@"/admin/users/remove" success:^(NSDictionary * _Nonnull response) {
        success(response);
    } failed:^(NSString * _Nonnull message) {
        failed(message);
    }];
}
+(void)RemoveMedia:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed{
    [self post:params url:@"/admin/media/remove" success:^(NSDictionary * _Nonnull response) {
        success(response);
    } failed:^(NSString * _Nonnull message) {
        failed(message);
    }];
}
+(void)ApproveMedia:(NSDictionary *)params success:(APISuccess)success failed:(APIFailed)failed{
    [self post:params url:@"/admin/media/approve" success:^(NSDictionary * _Nonnull response) {
        success(response);
    } failed:^(NSString * _Nonnull message) {
        failed(message);
    }];
}

@end
