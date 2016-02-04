//
//  FlickrItem.h
//  FarfetchTest
//
//  Created by Boris Chirino on 17/01/16.
//  Copyright © 2016 Boris Chirino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrItem : NSObject

@property NSUInteger photoID;
@property NSUInteger views;
@property (assign) BOOL ispublic;
@property (assign) BOOL isfriend;
@property NSDate   *taken;
@property NSString *desc;
@property NSString *title;
@property NSString *thumbnailUrl;
@property NSString *fullImageUrl;

@property UIImage *imageIcon;

@end
