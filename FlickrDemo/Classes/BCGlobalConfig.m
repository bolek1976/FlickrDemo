//
//  BCGlobalConfig.m
//  FarfetchTest
//
//  Created by Boris Chirino on 16/01/16.
//  Copyright © 2016 Boris Chirino. All rights reserved.
//

#import "BCGlobalConfig.h"


static BCGlobalConfig * _instance = nil;

@implementation BCGlobalConfig
+(id)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [BCGlobalConfig new];
    });
    return _instance;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        // Session configuration is created ephemeral because this app is optimized for memory architecture, it does not
        // persist any data to disk
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.timeoutIntervalForRequest = 20;
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                 delegate:self
                                            delegateQueue:nil];
    }
    return self;
}


- (NSURL *)baseURL{
    if (!_baseURL) {
        _baseURL =[NSURL URLWithString:@"https://api.flickr.com/services/rest/"];
    }
    return _baseURL;
}

@end
