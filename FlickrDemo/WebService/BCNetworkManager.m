//
//  BCNetworkManager.m
//  FarfetchTest
//
//  Created by Boris Chirino on 16/01/16.
//  Copyright © 2016 Boris Chirino. All rights reserved.
//

#import "BCNetworkManager.h"
#import "BCFlickrOperation.h"
#import "AppDelegate.h"
#import "BCGlobalConfig.h"
#import "KSReachability.h"
#import "Constants.h"


static BCNetworkManager * _instance = nil;

NSString *const BCFarFetchErrorDomain = @"com.bcf.fftest.ErrorDomain";

@interface BCNetworkManager ()

/**
 *  Hold the response from operations, sometimes used by a second dependant operation to complete the 
 *  response object.
 */
@property (nonatomic, strong) NSMutableDictionary   *photoInformation;
@end

@implementation BCNetworkManager

+(id)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [BCNetworkManager new];
    });
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _operationCoordinator = [NSOperationQueue new];
        // Limit the amount of connection increase the chance of responce, too many connection to same host
        // may drop that connection if the server is configured to receive specific amount of connection from same
        // host.
        _operationCoordinator.maxConcurrentOperationCount = 5;
        
        _photoInformation = [NSMutableDictionary new];
        
        _imageCache = [NSMutableDictionary new];
    }
    return self;
}

NSString *userPredicate;
NSString *photoid;


+(void)publicPhotosIdsForUsername:(NSString*)username completion:( void(^)(id response) )completion fail:(void (^)(NSError *))failedBlock{

    [BCNetworkManager checkInternetConnectionGivingUpWithBlock:failedBlock];
    
    NSString *predicate = [NSString stringWithFormat:@"username=%@",username];
    
            BCFlickrOperation *userNameOperation = [[BCFlickrOperation alloc]
                                                initWithResource:@"flickr.people.findByUsername"
                                                       predicate:predicate];
    
    __block BCFlickrOperation *publicPhotosIds  =  [[BCFlickrOperation alloc]
                                                   initWithResource:@"flickr.people.getPublicPhotos"
                                                          predicate:@""];
    
//    __weak typeof(publicPhotosIds) weakPhotosOp = publicPhotosIds;
    
    userNameOperation.completion = ^(NSDictionary *response, NSError *error){
        if (error == nil) {
            userPredicate = response[@"user_id"];
            publicPhotosIds.predicate = [NSString stringWithFormat:@"user_id=%@",userPredicate];
        }else{
            [[[BCNetworkManager shared] operationCoordinator] cancelAllOperations];
            failedBlock(error);
        }
    };
    
    publicPhotosIds.completion = ^(NSDictionary *response, NSError *error){
            if (response) {
                NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:response];
                [mutableDict setObject:@([response[@"photo_ids"] count]) forKey:@"count"];
                completion(mutableDict);
            }else if (error){
                [[[BCNetworkManager shared] operationCoordinator] cancelAllOperations];

                failedBlock(error);
                return ;
            }
            else if (response == nil) {
                [[[BCNetworkManager shared] operationCoordinator] cancelAllOperations];

                NSString *errorDescription = @"Error retrieving objects";
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorDescription};
                NSError *error = [NSError errorWithDomain:BCFarFetchErrorDomain code:FlickrApiErrorURLParsing userInfo:userInfo];
                failedBlock(error);
            }
    };


    [publicPhotosIds addDependency:userNameOperation];
    
    [[[BCNetworkManager shared] operationCoordinator] addOperation:userNameOperation];
    [[[BCNetworkManager shared] operationCoordinator] addOperation:publicPhotosIds];
    
}

+(void)thumbnailUrlsForPhotosIds:(NSArray*)photosIDs completion:( void(^)(NSDictionary* response) )completion fail:(void (^)(NSError *))failedBlock{
    NSAssert(photosIDs!=nil, @"photosIDs is null");
    
    [BCNetworkManager checkInternetConnectionGivingUpWithBlock:failedBlock];
    
    for (NSString *photoID in photosIDs) {
        NSString *predicate = [NSString stringWithFormat:@"photo_id=%@",photoID];
        __block BCFlickrOperation *photoSizes = [[BCFlickrOperation alloc] initWithResource:@"flickr.photos.getSizes" predicate:predicate];

        photoSizes.completion = ^(NSDictionary *response, NSError *error)
        {
            //dispatch_async(dispatch_get_main_queue(), ^{
                if (response == nil) {
                    NSString *errorDescription = @"Error retrieving objects";
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorDescription};
                    NSError *error = [NSError errorWithDomain:BCFarFetchErrorDomain code:FlickrApiErrorURLParsing userInfo:userInfo];
                    failedBlock(error);
                }else if (error){
                    failedBlock(error);
                }else{
                    completion(response);
                }
          //});
        };
        
        [[[BCNetworkManager shared] operationCoordinator] addOperation:photoSizes];
    }
}


- (void)photosInfoForPhotosIDs:(NSArray*)photosId
                    completion:(void(^)(NSDictionary* response, BOOL moreComming))completion
                          fail:(void (^)(NSError * error))failedBlock
{
    [BCNetworkManager checkInternetConnectionGivingUpWithBlock:failedBlock];
    
    
    __block BCFlickrOperation  *photoInfoOp      = nil;
    __block  BCFlickrOperation *photoThumbnailOp = nil;

    NSMutableArray *operations = [NSMutableArray new];
    for (NSString *pid in photosId) {
        NSString *predicate = [NSString stringWithFormat:@"photo_id=%@",pid];
        photoInfoOp = [[BCFlickrOperation alloc] initWithResource:@"flickr.photos.getInfo" predicate:predicate];
        photoThumbnailOp = [[BCFlickrOperation alloc] initWithResource:@"flickr.photos.getSizes" predicate:predicate];
        
        
        photoInfoOp.completion = ^(NSDictionary *response, NSError *error)
        {
            if (response.count > 0) {
                @synchronized(self) {
                    NSMutableDictionary  *photoInformation = [NSMutableDictionary new];
                    NSString *photoID = response[@"photo"][@"id"];
                    photoInformation[@"id"]         = photoID;
                    photoInformation[@"taken"]      = response[@"photo"][@"dates"][@"taken"];
                    photoInformation[@"isfavorite"] = response[@"photo"][@"isfavorite"];
                    photoInformation[@"title"]      = response[@"photo"][@"title"][@"_content"];
                    photoInformation[@"desc"]       = response[@"photo"][@"description"][@"_content"];
                    photoInformation[@"public"]     = response[@"photo"][@"visibility"][@"ispublic"];
                    photoInformation[@"friend"]     = response[@"photo"][@"visibility"][@"isfriend"];
                    photoInformation[@"views"]      = response[@"photo"][@"views"];
                    self.photoInformation[photoID] = photoInformation;
                }
            }
        };
        
        
        photoThumbnailOp.completion = ^(NSDictionary *response, NSError *error)
        {
            if (response.count > 0) {
                @synchronized(self) {
                    NSString *photoID = response[@"photo_id"];
                    NSMutableDictionary *storedData = [self.photoInformation objectForKey:photoID];
                    storedData[@"thumbnail"] = response[@"thumbnail"];
                    storedData[@"original"] = response[@"original"];
                    NSInteger opCounts = [[BCNetworkManager shared] operationCoordinator].operationCount;
                    BOOL moreOps = opCounts > 1;
                    completion(storedData, moreOps);
                }
            }
        };

        [photoThumbnailOp addDependency:photoInfoOp];
        [operations addObject:photoInfoOp];
        [operations addObject:photoThumbnailOp];
    }
    
    
    [[[BCNetworkManager shared] operationCoordinator] addOperations:operations waitUntilFinished:NO];

}


- (void)photoInfoForPhotoID:(NSString*)photoId completion:(void(^)(NSDictionary* response))completion fail:(void (^)(NSError * error))failedBlock{
    [BCNetworkManager checkInternetConnectionGivingUpWithBlock:failedBlock];

    NSString *predicate = [NSString stringWithFormat:@"photo_id=%@",photoId];


     BCFlickrOperation *photoInfoOp = [[BCFlickrOperation alloc] initWithResource:@"flickr.photos.getInfo" predicate:predicate];
    
    photoInfoOp.completion = ^(NSDictionary *response, NSError *error)
    {
        NSMutableDictionary  *photoInformation = [NSMutableDictionary new];

        @synchronized(self) {
            NSString *photoID = response[@"photo"][@"id"];
            photoInformation[@"id"]         = photoID;
            photoInformation[@"taken"]      = response[@"photo"][@"dates"][@"taken"];
            photoInformation[@"isfavorite"] = response[@"photo"][@"isfavorite"];
            photoInformation[@"title"]      = response[@"photo"][@"title"][@"content"];
            photoInformation[@"desc"]       = response[@"photo"][@"description"][@"content"];
            photoInformation[@"public"]     = response[@"photo"][@"visibility"][@"ispublic"];
            photoInformation[@"friend"]     = response[@"photo"][@"visibility"][@"isfriend"];
            photoInformation[@"views"]      = response[@"photo"][@"views"];
            self.photoInformation[photoID] = photoInformation;
            completion(photoInformation);
        }
        
        if (response.count == 0) {
            NSString *errorDescription = @"Error retrieving objects, photoInfoOP operation";
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorDescription};
            NSError *error = [NSError errorWithDomain:BCFarFetchErrorDomain code:FlickrApiErrorURLParsing userInfo:userInfo];
            failedBlock(error);
        }else if (error){
            failedBlock(error);
        }
    };

    [[[BCNetworkManager shared] operationCoordinator] addOperation:photoInfoOp];
}




- (void)downloadImageFromURL:(NSURL *)url completion:(void (^)(NSData *imageData, NSError *error))completion
{
    if (!url)
    {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Unable to obtain the image url."};
        NSError *responseError = [NSError errorWithDomain:BCFarFetchErrorDomain
                                                     code:FlickrApiErrorResponseParsing userInfo:userInfo];
        completion(nil, responseError);
        return;
    }
    
    if ([[self.imageCache allKeys] containsObject:url.absoluteString])
    {
        NSData *cachedImageData =  [self.imageCache objectForKey:url.absoluteString];
        completion(cachedImageData, nil);
        return;
    }
    
    NSLog(@"Downloading full image from :%@", url);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    __weak typeof(self) weakSelf = self;
    
    NSURLSession *session = [[BCGlobalConfig shared] session];

    
    // NSURLSessionDownloadTask is used for future releases on big resource being downloaded, move to background
    // the download and keep working on background.
    NSURLSessionDownloadTask *downloadTask =
    [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *downloadError = nil;
        if (![response.MIMEType isEqualToString:@"image/jpeg"])
        {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Image response may be not an image."};
            NSError *responseError = [NSError errorWithDomain:BCFarFetchErrorDomain
                                                      code:FlickrApiErrorResponseParsing userInfo:userInfo];
            completion(nil, responseError);
        }
        else
        {
            // On really big files dataWithContentsOfURL raise exceptions ontimeout of such things
                NSData *downloadedItem = nil;
                @try {
                    downloadedItem =  [NSData dataWithContentsOfURL:location options:NSDataReadingMappedAlways error:&downloadError];
                }
                @catch (NSException *exception) {
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Error downloading file."};
                    NSError *responseError = [NSError errorWithDomain:BCFarFetchErrorDomain
                                                                 code:0 userInfo:userInfo];
                    completion(nil, responseError);
                }
                @finally {
                    
                }
            
            
            if (!error) {
                [weakSelf.imageCache setObject:downloadedItem forKey:url.absoluteString];
                completion(downloadedItem, nil);
            }else{
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Error downloading file."};
                NSError *responseError = [NSError errorWithDomain:BCFarFetchErrorDomain
                                                             code:0 userInfo:userInfo];
                completion(nil, responseError);
            }
        }
    }];
    [downloadTask resume];
}






#pragma mark Helpers
+(void)checkInternetConnectionGivingUpWithBlock:(void (^)(NSError *))giveup{
    BOOL internetReachable = [BCNetworkManager internetConnected];
    
    if (!internetReachable) {
        NSString *errorDescription = @"Your internet connection appears to be offline";
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorDescription};
        NSError *error = [NSError errorWithDomain:BCFarFetchErrorDomain code:FlickrApiErrorNoInternet userInfo:userInfo];
        giveup(error);
    }
}

+(BOOL)internetConnected{
    BOOL internetReachability = [(AppDelegate*)[UIApplication sharedApplication].delegate reachability].reachable;
    return internetReachability;
}

@end
