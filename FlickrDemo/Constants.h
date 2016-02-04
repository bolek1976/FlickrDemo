//
//  Constants.h
//  FarfetchTest
//
//  Created by Boris Chirino on 16/01/16.
//  Copyright © 2016 Boris Chirino. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

typedef NS_ENUM(NSUInteger, FlickrPhotoSize) {
    FlickrPhotoSizeSquare = 75,
    FlickrPhotoSizeLargeSquare = 150,
    FlickrPhotoSizeThumbnail = 100,
    FlickrPhotoSizeSmall = 240,
    FlickrPhotoSizeMedium = 500,
    FlickrPhotoSizeLarge = 1024
};

typedef NS_ENUM(NSUInteger, FlickrApiError) {
    FlickrApiErrorURLParsing		= 100,
    FlickrApiErrorResponseParsing   = 101,
    FlickrApiErrorEmptyResponse     = 102,
    FlickrApiErrorServiceUnavailable = 105,
    FlickrApiErrorNoInternet		= 200,
    
    FlickrApiErrorAuthenticating	= 300,
    FlickrApiErrorNoTokenToCheck	= 301,
    FlickrApiErrorNotAuthorized	    = 302,
    
    FlickrApiErrorInvalidArgs       = 400,
};



#endif /* Constants_h */
