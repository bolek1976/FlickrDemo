//
//  DetailViewController.m
//  FarfetchTest
//
//  Created by Boris Chirino on 16/01/16.
//  Copyright © 2016 Boris Chirino. All rights reserved.
//  thanks to
//  https://github.com/evgenyneu/ios-imagescroll/blob/master/ImageScroll/ImageScrollViewController.m

#import "DetailViewController.h"
#import "BCNetworkManager.h"
#import "FlickrItem.h"
#import "FlickrDemo-Swift.h"
#import "BCGlobalConfig.h"

const NSInteger infoViewTag = 100000;

@interface DetailViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) IBOutlet UIImageView  *imageView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottom;

@property (nonatomic) CGFloat lastZoomScale;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *infoButton;

- (IBAction)showPhotoInfo:(id)sender;

@end

@implementation DetailViewController

#pragma mark viewLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.backIndicatorImage = [UIImage imageNamed:@"Tiles-20"];
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = [UIImage imageNamed:@"Tiles-20"];
    
    if (self.detailItem) {
        [SVProgressHUD showWithStatus:@"Loading"];
        
        [[BCNetworkManager shared] downloadImageFromURL:[NSURL URLWithString:self.detailItem.fullImageUrl]
                                             completion:^(NSData *imageData, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                if (!error) {
                    [self.imageView setImage: [UIImage imageWithData:imageData] ];
                    [self updateZoom];
                }else{
                    self.imageView.image = [UIImage imageNamed: @"screen-placeholder"];
                    [self updateZoom];
                    [[DPNotify sharedNotify] showNotifyInView:self.scrollView title:error.localizedDescription dismissOnTap:YES];
                }
            });
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.infoButton.enabled = (self.detailItem != nil);
    [self updateZoom];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // check to see if any downloadtask is pending and cancel it.
    [[[BCGlobalConfig shared] session] getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        for (NSURLSessionDownloadTask *downloadTask in downloadTasks) {
            [downloadTask cancel];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void) scrollViewDidZoom:(UIScrollView *)scrollView {
    [self updateConstraints];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
}


#pragma mark private methods

- (void) updateConstraints {
    float imageWidth = self.imageView.image.size.width;
    float imageHeight = self.imageView.image.size.height;
    
    float viewWidth = self.view.bounds.size.width;
    float viewHeight = self.view.bounds.size.height;
    
    // center image if it is smaller than screen
    float hPadding = (viewWidth - self.scrollView.zoomScale * imageWidth) / 2;
    if (hPadding < 0) hPadding = 0;
    
    float vPadding = (viewHeight - self.scrollView.zoomScale * imageHeight) / 2;
    if (vPadding < 0) vPadding = 0;
    
    self.constraintLeft.constant = hPadding;
    self.constraintRight.constant = hPadding;
    
    self.constraintTop.constant = vPadding;
    self.constraintBottom.constant = vPadding;
    
    // Makes zoom out animation smooth and starting from the right point not from (0, 0)
    [self.view layoutIfNeeded];
}


- (void) updateZoom {
    float minZoom = MIN(self.view.bounds.size.width / self.imageView.image.size.width,
                        self.view.bounds.size.height / self.imageView.image.size.height);
    
    if (minZoom > 1) minZoom = 1;
    
    self.scrollView.minimumZoomScale = minZoom;
    
    // Force scrollViewDidZoom fire if zoom did not change
    if (minZoom == self.lastZoomScale) minZoom += 0.000001;
    
    self.lastZoomScale = self.scrollView.zoomScale = minZoom;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark UI ACTIONS

- (IBAction)showPhotoInfo:(id)sender {
    
    UIView *infoView = [self.view viewWithTag:infoViewTag];
    if (infoView) return;
    
    UIView *_infoView = [UIView new];
    [_infoView setBackgroundColor:[UIColor blackColor]];
    [_infoView setTranslatesAutoresizingMaskIntoConstraints:NO];
    _infoView.layer.borderColor = [UIColor grayColor].CGColor;
    _infoView.layer.borderWidth = 1.5f;
    _infoView.layer.cornerRadius = 10.0f;
    _infoView.tag = infoViewTag;
    _infoView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideInfoView:)];
    [_infoView addGestureRecognizer:tapGesture];
    
    UILabel *_photoTitleLabel = [UILabel new];
    [_photoTitleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    _photoTitleLabel.textColor = [UIColor whiteColor];
    _photoTitleLabel.text = self.detailItem.title;
    _photoTitleLabel.textAlignment = NSTextAlignmentCenter;
    _photoTitleLabel.font = [UIFont systemFontOfSize:13 weight:0.1];
    [_infoView addSubview:_photoTitleLabel];
    
    UILabel *_dateTaken = [UILabel new];
    [_dateTaken setTranslatesAutoresizingMaskIntoConstraints:NO];
    _dateTaken.textColor = [UIColor whiteColor];
    _dateTaken.text = [NSString stringWithFormat:@"%@", [self.detailItem.taken stringWithDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterShortStyle]];
    
    
    _dateTaken.textAlignment = NSTextAlignmentCenter;
    _dateTaken.font = [UIFont systemFontOfSize:13 weight:0.1];
    [_infoView addSubview:_dateTaken];
    
    UILabel *_totalViewers = [UILabel new];
    [_totalViewers setTranslatesAutoresizingMaskIntoConstraints:NO];
    _totalViewers.textColor = [UIColor whiteColor];
    _totalViewers.text = [NSString stringWithFormat:@"Total viwers : %lu",  self.detailItem.views];
    _totalViewers.textAlignment = NSTextAlignmentCenter;
    _totalViewers.font = [UIFont systemFontOfSize:13 weight:0.1];
    [_infoView addSubview:_totalViewers];


    
    UILabel *_headerLabel = [UILabel new];
    [_headerLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    _headerLabel.textColor = [UIColor whiteColor];
    _headerLabel.text = self.detailItem.desc.length > 0 ? self.detailItem.desc : @"Photo details";
    _headerLabel.textAlignment = NSTextAlignmentCenter;
    _headerLabel.font = [UIFont systemFontOfSize:13 weight:0.4];
    [_infoView addSubview:_headerLabel];
    
    [self.view addSubview:_infoView];
    UIView *_superView = self.view;

    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_infoView, _superView, _photoTitleLabel,_headerLabel,_dateTaken, _totalViewers);
    
    //black container view constraints
    [_superView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_infoView(300)]" options:0 metrics:nil views:viewsDict]];
    [_superView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_infoView(200)]" options:0 metrics:nil views:viewsDict]];
    
    
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:_infoView
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_superView
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:1
                                      constant:0];
    
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:_infoView
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_superView
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1
                                                                constant:0];

    
    
    [_superView addConstraint:centerX];
    [_superView addConstraint:centerY];

    // View Container subviews constraints
    [_infoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_photoTitleLabel]-|" options:0 metrics:nil views:viewsDict]];
    
    [_infoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_dateTaken]-|" options:0 metrics:nil views:viewsDict]];
    
    [_infoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_headerLabel]-|" options:0 metrics:nil views:viewsDict]];

    [_infoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_totalViewers]-|" options:0 metrics:nil views:viewsDict]];


    [_infoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[_headerLabel(20)]-(40)-[_photoTitleLabel(20)]-[_dateTaken(20)]-[_totalViewers(20)]" options:0 metrics:nil views:viewsDict]];

    [self.view layoutIfNeeded];
}

-(void)hideInfoView:(id)sender{
    UIView *infoView = [self.view viewWithTag:infoViewTag];
    if (infoViewTag) {
        [infoView removeFromSuperview];
    }
}


@end
