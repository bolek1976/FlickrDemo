//
//  FlickrCellV1.h
//  FarfetchTest
//
//  Created by Boris Chirino on 19/01/16.
//  Copyright © 2016 Boris Chirino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrCellV1 : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbNailView;
@property (weak, nonatomic) IBOutlet UILabel *visitorLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
