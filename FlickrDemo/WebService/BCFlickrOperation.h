//
//  BCFlickrPhotosOperation.h
//  FarfetchTest
//
//  Created by Boris Chirino on 16/01/16.
//  Copyright © 2016 Boris Chirino. All rights reserved.
//

#import "BCBaseOperation.h"

typedef NS_ENUM(NSUInteger, JSONResourceResult) {
    JSONResourceResultSizes,
    JSONResourceResultUser,
    JSONResourceResultPhotos,
};

typedef void(^BCFlickrPhotosOperationCompletion)(id response, NSError *error);


@interface BCFlickrOperation : BCBaseOperation

@property (nonatomic, strong) BCFlickrPhotosOperationCompletion completion;

@end
