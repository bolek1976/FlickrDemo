//
//  ViewController.m
//  FarfetchTest
//
//  Created by Boris Chirino on 16/01/16.
//  Copyright © 2016 Boris Chirino. All rights reserved.
//

#import "MasterViewController.h"
#import "BCNetworkManager.h"
#import "FlickrDemo-Swift.h"
#import "FlickrItem.h"
#import "IconDownloader.h"
#import "DetailViewController.h"
#import "FlickrCellV1.h"

@interface MasterViewController ()<UIScrollViewDelegate>
@property NSString *username;
@property NSMutableArray *flickrItems;
@property (nonatomic, weak) FlickrItem *selectedItem;
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

- (IBAction)findUser:(id)sender;

@end

@implementation MasterViewController

#pragma mark viewLifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    _flickrItems = [[NSMutableArray alloc] initWithCapacity:0];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View Delegates & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.flickrItems.count;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedItem = self.flickrItems[indexPath.row];
    [self performSegueWithIdentifier:@"detailSegue" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FlickrCellV1 *cell = nil;
    
    FlickrItem *flickrItem = (self.flickrItems)[indexPath.row];
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"flickrCellV1" forIndexPath:indexPath];
    
    if (flickrItem.title.length > 0) {
        cell.titleLabel.text = flickrItem.title;
    }else{
        cell.titleLabel.text = [[(FlickrItem*)flickrItem taken] stringWithDateStyle:NSDateFormatterMediumStyle
                                                                          timeStyle:NSDateFormatterShortStyle];
    }

    cell.visitorLabel.text = [NSString stringWithFormat:@"%lu", [(FlickrItem*)self.flickrItems[indexPath.row] views] ];
    //cell.textLabel.text = [[(FlickrItem*)self.flickrItems[indexPath.row] taken] string];
    

    
    if (!flickrItem.imageIcon)
    {
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
        {
            [self startIconDownload:flickrItem forIndexPath:indexPath];
        }
        // if a download is deferred or in progress, return a placeholder image
        cell.thumbNailView.image = [UIImage imageNamed:@"placeholder"];
        //cell.imageView.image = [UIImage imageNamed:@"placeholder"];
    }
    else
    {
        //cell.imageView.image = flickrItem.imageIcon;
        cell.thumbNailView.image = flickrItem.imageIcon;
    }


    return cell;
}


#pragma mark UI ACTIONS
- (IBAction)findUser:(id)sender
{
    
    __weak typeof(self) weakSelf = self;

    if ([[[BCNetworkManager shared] operationCoordinator] operationCount] > 0) {
        UIAlertController *opsInprogress = [UIAlertController alertControllerWithTitle:nil message:@"There's still work to be done, cancel it and see what we get so far ?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Yes, cancel" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [[[BCNetworkManager shared] operationCoordinator] cancelAllOperations];
                                                              }];
        
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Wait" style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction * action) {
                                                            [SVProgressHUD showWithStatus:@"Loading"];
                                                           [opsInprogress dismissViewControllerAnimated:YES completion:nil];
                                                       }];
        [opsInprogress addAction:defaultAction];
        [opsInprogress addAction:cancel];
        [self presentViewController:opsInprogress animated:YES completion:nil];
        
        dismisHud();

    }
    else
    {
        UIAlertController *findUserDialog = [UIAlertController alertControllerWithTitle:nil message:@"Type username to search for" preferredStyle:UIAlertControllerStyleAlert];
        
        [findUserDialog addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Flickr username";
        }];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Search" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  weakSelf.username = [findUserDialog textFields][0].text;
                                                                  [weakSelf searchFlickrUser];
                                                              }];
        
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction * action) {
                                                       }];
        [findUserDialog addAction:defaultAction];
        [findUserDialog addAction:cancel];
        [self presentViewController:findUserDialog animated:YES completion:nil];
   
    }
}



#pragma mark private methods
- (void)startIconDownload:(FlickrItem *)flickrItem forIndexPath:(NSIndexPath *)indexPath
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    IconDownloader *iconDownloader = (self.imageDownloadsInProgress)[indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.flickrItem = flickrItem;
        [iconDownloader setCompletionHandler:^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            FlickrCellV1 *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            // Display the newly loaded image
            //cell.imageView.image = flickrItem.imageIcon;
            cell.thumbNailView.image = flickrItem.imageIcon;
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
        }];
        (self.imageDownloadsInProgress)[indexPath] = iconDownloader;
        [iconDownloader startDownload];
    }
}



-(void)searchFlickrUser{
        [self doUsernameSearchWithText:self.username];
}


- (void)doUsernameSearchWithText:(NSString*)username{
    [self.flickrItems removeAllObjects];
    [self.tableView reloadData];
    
    [SVProgressHUD showWithStatus:@"Loading"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [BCNetworkManager publicPhotosIdsForUsername:username completion:^(id response) {
            if ( [response[@"count"] intValue] > 0)
            {
                [[BCNetworkManager shared] photosInfoForPhotosIDs:response[@"photo_ids"] 
                                                       completion:^(NSDictionary *response, BOOL moreComming) {
                    NSLog(@" \n -------- %@ \n", response);                                                
                   if (!moreComming) {
                       dismisHud();
                       dispatch_async(dispatch_get_main_queue(), ^{
                         [self.tableView reloadData];
                     });
                   }
                   else if (response != nil)
                   {
                       FlickrItem *item = [FlickrItem new];
                       item.views = [response[@"views"] integerValue];
                       item.photoID = [response[@"id"] integerValue];
                       item.isfriend = response[@"friend"];
                       item.taken = [NSDate dateFromString:response[@"taken"]];
                       item.title = response[@"title"];
                       item.thumbnailUrl = response[@"thumbnail"];
                       item.fullImageUrl = response[@"original"];
                       @synchronized(self) {
                           [self.flickrItems addObject:item];
                       }
                   }
                } fail:^(NSError *error) {
                    dismisHud();
                }];
            }
            else
            {
                dismisHud();
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[DPNotify sharedNotify] showNotifyInView:self.view title:@"No photos" dismissOnTap:YES];
                });
            }
        } fail:^(NSError *error) {
            dismisHud();
            dispatch_async(dispatch_get_main_queue(), ^{
                [[DPNotify sharedNotify] showNotifyInView:self.view title:error.localizedDescription dismissOnTap:YES];
            });
        }];
}



- (void)loadImagesForOnscreenRows
{
    if (self.flickrItems.count > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            FlickrItem *item = (self.flickrItems)[indexPath.row];
            if (!item.imageIcon)
            {
                [self startIconDownload:item forIndexPath:indexPath];
            }
        }
    }
}



#pragma mark - UIScrollViewDelegate

// -------------------------------------------------------------------------------
//	scrollViewDidEndDragging:willDecelerate:
//  Load images for all onscreen rows when scrolling is finished.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self loadImagesForOnscreenRows];
    }
}

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:scrollView
//  When scrolling stops, proceed to load the app icons that are on screen.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}


static inline void dismisHud(){
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [SVProgressHUD dismiss];
    });
}


#pragma mark

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if ([segue.identifier isEqualToString:@"detailSegue"]) {
        UINavigationController *nc = (UINavigationController*)segue.destinationViewController;
        
        DetailViewController *vc =   (DetailViewController*)[nc topViewController];
        vc.detailItem = self.selectedItem;
        
        vc.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        vc.navigationItem.leftItemsSupplementBackButton = YES;

    }
    
}



@end
