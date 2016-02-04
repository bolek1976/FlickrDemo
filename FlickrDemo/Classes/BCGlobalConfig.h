//
//  BCGlobalConfig.h
//  FarfetchTest
//
//  Created by Boris Chirino on 16/01/16.
//  Copyright © 2016 Boris Chirino. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BCGlobalConfig : NSObject <NSURLSessionDataDelegate>

@property NSURLSession *session;
@property (nonatomic) NSURL *baseURL;

+(id)shared;


@end
