//
//  BCNetworkManager.h
//  FarfetchTest
//
//  Created by Boris Chirino on 16/01/16.
//  Copyright © 2016 Boris Chirino. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface BCNetworkManager : NSObject

@property NSOperationQueue *operationCoordinator;

@property NSMutableDictionary *imageCache;


+(id)shared;




/**
 *  Fetch photosids for specified userid
 *
 *  @param userID      a valid userID ex: 87180922@N02
 *  @param completion  completion block to execute once all ids ara fetched and parsed
 *  @param failedBlock executed if the operation fail
 *  @warning the completion block is executed on an arbitrary thread, if you're refreshing the UI, make sure to do it on the main queue.

 */
+(void)publicPhotosIdsForUsername:(NSString*)username
                     completion:( void(^)(id response) )completion
                           fail:(void(^)(NSError *error))failedBlock;



/**
 *  Given an array of photos ids this methods retrieve the thumbnail key from the flickr method
 *  @b flickr.photos.getSizes @b
 *
 *  @param photosIDs   array of photosIds
 *  @param completion  the block to execute if the operation has succeed
 *  @param failedBlock the block to execute if the operation has failed
 *  @warning the completion block is executed on an arbitrary thread, if you're refreshing the UI, make sure to do it on the main queue.

 */

+(void)thumbnailUrlsForPhotosIds:(NSArray*)photosIDs
                      completion:( void(^)(NSDictionary* response) )completion
                            fail:(void(^)(NSError *error))failedBlock;




/**
 *  retrieve photo information for a given id
 *  The NSDictionary in the response is the result of combining the response from these two mentioned operation.
 *  @param photoId     photo id
 *  @param completion  the block to execute if the operation has succeed
 *  @param failedBlock the block to execute if the operation has failed
 */
-(void)photoInfoForPhotoID:(NSString*)photoId
                completion:(void(^)(NSDictionary* response))completion
                      fail:(void (^)(NSError *error))failedBlock;




/**
 *  Plural variant of @a photoInfoForPhotoID:completion:fail using an array of ids. This method use 2 operation objects with dependency.
 *  First one retrieve the photo info from @b flickr.photos.getInfo endpoint and the later get the url for the thumbnail
 *  at @b flickr.photos.getSizes.
 *  The NSDictionary in the response is the result of combining the response from these two mentioned operation.
 *
 *
 *  @param photosId    array of photos ids
 *  @param completion  the block to execute if the operation has succeed
 *  @param failedBlock the block to execute if the operation has failed
 *  @warning the completion block is executed on an arbitrary thread, if you're refreshing the UI, make sure to do it on the main queue.
 */
- (void)photosInfoForPhotosIDs:(NSArray*)photosId
                    completion:(void(^)(NSDictionary* response, BOOL moreComming))completion
                          fail:(void (^)(NSError * error))failedBlock;




/**
 *  Return an image as NSData object. The method use NSUrlSession class.
 *
 *  @param url url of the image
 *  @param completion completion handler to execute once the operation finished
 *  @attention this method cache the image based on the url. Subsequent call to the same url does not perform the connection just give the image from the cache.
 */
- (void)downloadImageFromURL:(NSURL*)url completion:(void(^)(NSData *imageData, NSError *error))completion;


@end
