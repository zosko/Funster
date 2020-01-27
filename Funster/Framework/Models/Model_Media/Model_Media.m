//
//  Model_Media.m
//  Funster
//
//  Created by Bosko Petreski on 8/2/19.
//  Copyright © 2019 Bosko Petreski. All rights reserved.
//

#import "Model_Media.h"
#import "APICalls.h"

@implementation Model_Media

-(Model_Media *)initWithResponse:(NSDictionary *)response{
    self = [super init];
    if(self) {
        self.media_id = [response[@"id"] integerValue];
        self.link = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",API_URL,response[@"link"]]];
        self.type = [response[@"type"] integerValue];
        self.text = [NSString stringWithFormat:@"%@",response[@"text"]];
        self.likes = [response[@"likes"] integerValue];
        
        if(![response[@"users_id_likes"] isEqual:NSNull.null]){
            NSArray *arrLikesUsers = [response[@"users_id_likes"] componentsSeparatedByString:@","];
            for(NSNumber *num in arrLikesUsers){
                if(num.integerValue == [[NSUserDefaults.standardUserDefaults objectForKey:@"user_id"] integerValue]){
                    self.isLiked = YES;
                    break;
                }
            }
        }
        
        self.thumbnail = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",API_URL,response[@"thumbnail"]]];
    }
    return self;
}

@end
