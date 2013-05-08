//
//  PPAlterImageViewController.m
//  Photo_Phun
//
//  Created by Alex Silva on 5/7/13.
//  Copyright (c) 2013 Alex Silva. All rights reserved.
//

#import "PPAlterImageViewController.h"
#import "FlickrPhoto.h"
#import "PPDataFetcher.h"

@interface PPAlterImageViewController ()

@property (strong, nonatomic) NSArray *filterPreviewsInfo;

@property (strong, nonatomic) UINavigationBar *navBar;

@end

@implementation PPAlterImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureImageViewBorder:10.0];
    [self configureNavBarAndButton];
}

-(void)viewDidAppear:(BOOL)animated
{
    if(self.flickrPhoto.largeImage) {
        self.largeImage.image = [PPAlterImageViewController cropBiggestCenteredSquareImageFromImage: self.flickrPhoto.largeImage withSide:520.0];
    }
    else {
        
        self.largeImage.image = [PPAlterImageViewController cropBiggestCenteredSquareImageFromImage: self.flickrPhoto.thumbnail withSide:520.0];
        
        [PPDataFetcher loadImageForPhoto:self.flickrPhoto thumbnail:NO completionBlock:^(UIImage *photoImage, NSError *error) {
            if(!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.largeImage.image = [PPAlterImageViewController cropBiggestCenteredSquareImageFromImage: self.flickrPhoto.largeImage withSide:520.0];
                });
            }
        }];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configureImageViewBorder:(CGFloat)borderWidth
{
    CALayer* layer = [self.largeImage layer];
    [layer setBorderWidth:borderWidth];
    //[self.largeImage setContentMode:UIViewContentModeCenter];
    [layer setBorderColor:[UIColor whiteColor].CGColor];
    [layer setShadowOffset:CGSizeMake(-3.0, 3.0)];
    [layer setShadowRadius:3.0];
    [layer setShadowOpacity:1.0];
}

-(void)configureNavBarAndButton
{
    _navBar = [[UINavigationBar alloc] init];
    [_navBar setFrame:CGRectMake(0,0,self.view.bounds.size.width,52)];
    [self.view addSubview:_navBar];
    UINavigationItem *navItem = [[UINavigationItem alloc]initWithTitle:@"Edit Photo"];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.userInteractionEnabled = YES;
    [doneButton setBackgroundImage:[UIImage imageNamed:@"bar_button"] forState:UIControlStateNormal];
    [doneButton setBackgroundImage:[UIImage imageNamed:@"bar_button_selected"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [doneButton setShowsTouchWhenHighlighted:YES];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton.layer setCornerRadius:4.0f];
    [doneButton.layer setMasksToBounds:YES];
    [doneButton.layer setBorderWidth:1.0f];
    [doneButton.layer setBorderColor: [[UIColor grayColor] CGColor]];
    doneButton.frame = CGRectMake(0.0, 100.0, 60.0, 30.0);
    [doneButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    [navItem setLeftBarButtonItem:doneBtn];
    [_navBar setItems:@[navItem]];
}

- (UIImage *)imageByCropping:(UIImage *)image toSize:(CGSize)size
{
    double x = (image.size.width - size.width) / 2.0;
    double y = (image.size.height - size.height) / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, size.height, size.width);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}

+ (UIImage*) cropBiggestCenteredSquareImageFromImage:(UIImage*)image withSide:(CGFloat)side
{
    // Get size of current image
    CGSize size = [image size];
    if( size.width == size.height && size.width == side){
        return image;
    }
    
    CGSize newSize = CGSizeMake(side, side);
    double ratio;
    double delta;
    CGPoint offset;
    
    //make a new square size, that is the resized imaged width
    CGSize sz = CGSizeMake(newSize.width, newSize.width);
    
    //figure out if the picture is landscape or portrait, then
    //calculate scale factor and offset
    if (image.size.width > image.size.height) {
        ratio = newSize.height / image.size.height;
        delta = ratio*(image.size.width - image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / image.size.width;
        delta = ratio*(image.size.height - image.size.width);
        offset = CGPointMake(0, delta/2);
    }
    
    //make the final clipping rect based on the calculated values
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * image.size.width),
                                 (ratio * image.size.height));
    
    //start a new context, with scale factor 0.0 so retina displays get
    //high quality image
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    return [self.filterPreviewsInfo count];
    
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //TODO: return cell
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select item
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Deselect item
}

- (IBAction)doneButtonPressed:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{}];
}
@end