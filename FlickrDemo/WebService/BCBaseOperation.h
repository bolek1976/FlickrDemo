//
//  BCBaseOperation.h
//  FarfetchTest
//
//  Created by Boris Chirino on 16/01/16.
//  Copyright © 2016 Boris Chirino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCBaseOperation : NSOperation
/**
 *  flag to indicate that the operation is executing
 */
@property (nonatomic, assign) BOOL isOperationExecuting;

/**
 *  flag to indicate that the operation is finished
 */
@property (nonatomic, assign) BOOL isOperationFinished;

/**
 *  describe the parameter photo_id, user_id, farm_id, etc.
 */
@property NSString *resource;


/**
 *  flickr endpoint used in method @b parameter
 */
@property NSString *predicate;


/**
 *  session to handle request
 */
@property NSURLSession *session;


/**
 *  hold operation response, ususally json objects
 */
@property NSDictionary *result;


/**
 *  this property match with the photoId or userID, it depend of operation
 */
@property (nonatomic, strong) NSString *operationID;





/**
 *  finish current operation
 */
- (void) finish;


/**
 *  build up an NSoperation object
 *
 *  @param resource  describe the parameter photo_id, user_id, farm_id, etc.
 *  @param predicate flickr endpoint used in method @b parameter
 *
 *  @return subclass of NSOperation
 */
- (instancetype)initWithResource:(NSString*)resource predicate:(NSString*)predicate;

@end
