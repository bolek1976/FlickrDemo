//
//  BCFlickrPhotosOperation.m
//  FarfetchTest
//
//  Created by Boris Chirino on 16/01/16.
//  Copyright © 2016 Boris Chirino. All rights reserved.
//

#import "BCFlickrOperation.h"
#import "BCGlobalConfig.h"
#import "Constants.h"

@interface BCFlickrOperation ()
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (assign) BOOL userHavePublicPhotos;

@end

@implementation BCFlickrOperation

- (instancetype)initWithResource:(NSString *)resource predicate:(NSString *)predicate{
    self = [super init];
    if (self) {
        self.resource = resource;
        self.predicate = predicate;
    }
    return self;
}

- (void)start{
    
    if ([self isCancelled]) {
        // Must move the operation to the finished state if it is canceled.
        [self finish];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    self.isOperationExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    NSString *params = [NSString stringWithFormat:@"?%@&%@&%@&%@%@&%@",@"api_key=29b77877743e39b4eeec042ac1360bd4",
                        @"format=json",
                        @"nojsoncallback=1",
                        @"method=",
                        self.resource, self.predicate];
    
    NSURL *finalUrl = [NSURL URLWithString:params relativeToURL:[[BCGlobalConfig shared] baseURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: finalUrl ];
    request.HTTPMethod = @"GET";
    
    self.dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error)
        {
            NSError *serializationError = nil;
            id result = [NSJSONSerialization JSONObjectWithData:data
                                                        options:NSJSONReadingAllowFragments
                                                          error:&serializationError];
            if (serializationError)
            {
                [self finish];
                NSLog(@"error serializing");
            }
            else
              {
                self.result = result;
                if ([result[@"code"] intValue] == 1) {
                    [self finish];
                    NSString *errorDescription = @"User not found";
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorDescription};
                    NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:FlickrApiErrorEmptyResponse userInfo:userInfo];
                    self.completion(nil, error);
                    return ;
                }
                
                if ([self.resource isEqualToString:@"flickr.photos.getSizes"]) {
                    [self parseResponseFor:JSONResourceResultSizes];
                }else if ([self.resource isEqualToString:@"flickr.people.getPublicPhotos"]){
                    [self parseResponseFor:JSONResourceResultPhotos];
                }else if ([self.resource isEqualToString:@"flickr.people.findByUsername"]){
                    [self parseResponseFor:JSONResourceResultUser];
                }
            }
            
            @synchronized(self) {
                if (self.completion) {
                    self.completion(self.result, nil);
                }
            }
        }
        else // error
        {
            [self finish];
            self.completion(nil, error);
        }
        [self finish];
    }];
    
    [self.dataTask resume];
}

-(void)parseResponseFor:(JSONResourceResult)parseType{

    if (parseType == JSONResourceResultSizes)
    {
        @synchronized(self) {
            __weak typeof(self) weakOpRef = self;
            NSMutableDictionary *thumbnail = [NSMutableDictionary new];
            for (NSDictionary *sizeItem in self.result[@"sizes"][@"size"]) {
                if ([sizeItem[@"label"] isEqualToString:@"Thumbnail"]) {
                    [thumbnail setObject:[sizeItem valueForKey:@"source"] forKey:@"thumbnail"];
                    [thumbnail setObject:weakOpRef.operationID forKey:@"photo_id"];
                }
                if ([sizeItem[@"label"] isEqualToString:@"Large"]) {
                    [thumbnail setObject:[sizeItem valueForKey:@"source"] forKey:@"original"];
                }else if ([sizeItem[@"label"] isEqualToString:@"Original"]){ // if large is not present on the json
                    [thumbnail setObject:[sizeItem valueForKey:@"source"] forKey:@"original"];
                }
            }
            self.result = thumbnail;
        }

    }
    else if (parseType == JSONResourceResultPhotos)
    {
        @synchronized(self) {
            if ([self.result[@"photos"][@"total"] intValue] == 0) {
                NSString *errorDescription = @"This user has no public photos";
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorDescription};
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:FlickrApiErrorEmptyResponse userInfo:userInfo];
                self.result = nil;
                self.userHavePublicPhotos = NO;
                [self cancel];
                self.completion(nil, error);
                return ;
            }
            
            self.userHavePublicPhotos = YES;
            NSMutableArray *photos = [NSMutableArray new];
            for (NSDictionary *sizeItem in self.result[@"photos"][@"photo"]) {
                [photos addObject:sizeItem[@"id"]];
            }
            self.result = @{@"photo_ids":photos};
        }

    }
    else if (parseType == JSONResourceResultUser)
    {
        @synchronized(self) {
            self.result = @{@"user_id":self.result[@"user"][@"id"]};
        }
    }
    
//    if (self.completion) {
//        self.completion(self.result, nil);
//    }

}



@end
