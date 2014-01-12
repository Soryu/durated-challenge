//
//  SERBaseViewController.m
//  durated-stan
//
//  Created by Stanley Rost on 11.01.14.
//  Copyright (c) 2014 Stanley Rost. All rights reserved.
//

@import AssetsLibrary;
@import MobileCoreServices;

#import "SERBaseViewController.h"

#import "SERContentViewController.h"
#import "SERDuratedMenu.h"
#import "SERDuratedMenuItem.h"
#import "SERInviteViewController.h"
#import "SERMarketViewController.h"
#import "SERPostsViewController.h"
#import "SERProfileViewController.h"
#import "SERWishlistViewController.h"

static const CGFloat kAnimationDuration = 0.25;

typedef NS_ENUM(NSInteger, SERAnimation) {
  SERAnimationNone,
  SERAnimationLeft,
  SERAnimationRight,
};

@interface SERBaseViewController () <SERDuratedMenuDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

// UI

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) SERDuratedMenu *menu;

// Actions

// Content

@property (nonatomic, strong) UIViewController         *currentController;
@property (nonatomic, strong) SERContentViewController *contentController;

@property (nonatomic, strong) SERMarketViewController  *marketController;
@property (nonatomic, strong) SERPostsViewController   *postsController;
@property (nonatomic, strong) SERProfileViewController *profileController;

@end

@implementation SERBaseViewController

#pragma mark View handling

- (void)loadView
{
  self.view = [UIView new];
  
  self.contentView = [UIView new];
  self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:self.contentView];
  
  [self.view addSubview:self.menu];

  self.view.backgroundColor = [UIColor whiteColor];
  self.contentView.backgroundColor = [UIColor greenColor];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self setContentController:self.defaultContentController animation:SERAnimationNone];
}


#pragma mark UI

- (SERDuratedMenu *)menu
{
  if (!_menu)
  {
    _menu = [[SERDuratedMenu alloc] initWithFrame:self.view.bounds];
    _menu.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _menu.image = [UIImage imageNamed:@"durated-button"];
    _menu.highlightedImage = [UIImage imageNamed:@"durated-button-highlighted"];
    _menu.delegate = self;
  }
  
  return _menu;
}


#pragma mark Actions

- (void)menuButtonPressed:(id)sender
{
  // NOTE test code just to have something working
  SERContentViewController *newController = nil;
  
  if (self.contentController == self.marketController)
  {
    newController = self.profileController;
  }
  else if (self.contentController == self.profileController)
  {
    newController = self.postsController;
  }
  else
  {
    newController = self.marketController;
  }
  
  [self setContentController:newController animation:SERAnimationRight];
}

#pragma mark content controllers

- (void)setContentController:(SERContentViewController *)contentController animation:(SERAnimation)animation
{
  UIViewController *newController = [self viewControllerForContentController:contentController];
  UIViewController *oldController = self.currentController;

  self.currentController = newController;
  self.contentController = contentController;

  if (animation == SERAnimationNone)
  {
    [oldController.view removeFromSuperview];
    [oldController removeFromParentViewController];
    
    [self addChildViewController:newController];
    [newController didMoveToParentViewController:self];
    
    newController.view.frame = self.contentView.bounds;
    newController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.contentView addSubview:newController.view];
  }
  else
  {
    [self addChildViewController:newController];
    [newController didMoveToParentViewController:self];
    
    newController.view.frame = self.contentView.bounds;
    newController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.contentView addSubview:newController.view];
    
    CGFloat tx_new = 0;
    CGFloat ty_new = 0;
    CGFloat tx_old = 0;
    CGFloat ty_old = 0;

    if (animation == SERAnimationRight)
    {
      tx_new =  CGRectGetWidth(self.view.frame);
      tx_old = -CGRectGetWidth(self.view.frame);
    }
    else if (animation == SERAnimationLeft)
    {
      tx_new = -CGRectGetWidth(self.view.frame);
      tx_old =  CGRectGetWidth(self.view.frame);
    }
    
    newController.view.transform = CGAffineTransformMakeTranslation(tx_new, ty_new);
    
    [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
      newController.view.transform = CGAffineTransformIdentity;
      oldController.view.transform = CGAffineTransformMakeTranslation(tx_old, ty_old);
    } completion:^(BOOL finished) {
      oldController.view.transform = CGAffineTransformIdentity;
      [oldController.view removeFromSuperview];
      [oldController removeFromParentViewController];
    }];
  }
  
  SERDuratedMenuItem *firstItem = nil;
  SERDuratedMenuItem *lastItem  = nil;
  
  if (contentController.tag == SERContentTagMarket)
  {
    firstItem = [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"profile"] tag:SERContentTagProfile];
    lastItem  = [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"posts"]   tag:SERContentTagPosts];
  }
  else if (contentController.tag == SERContentTagProfile)
  {
    firstItem = [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"posts"]  tag:SERContentTagPosts];
    lastItem  = [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"market"] tag:SERContentTagMarket];
  }
  else if (contentController.tag == SERContentTagPosts)
  {
    firstItem = [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"market"]  tag:SERContentTagMarket];
    lastItem  = [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"profile"] tag:SERContentTagProfile];
  }
  
  NSAssert(firstItem && lastItem, @"items must be set");
  
  self.menu.items = @[
    firstItem,
    [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"invite"]   tag:SERContentTagInvite],
    [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"camera"]   tag:SERContentTagCamera],
    [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"wishlist"] tag:SERContentTagWishlist],
    lastItem,
  ];

}

- (void)prepareToShowCamera
{
  // FIXME quick'n'dirty solution for delay when bringing up the camera
  UIView *coverView = [UIView new];
  coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
  coverView.frame = self.view.bounds;
  [self.view addSubview:coverView];
  
  UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  [coverView addSubview:spinner];
  spinner.center = CGPointMake(CGRectGetMidX(coverView.bounds), CGRectGetMidY(coverView.bounds));
  [spinner startAnimating];
  
  // FIXME Quick hack to open the camera delayed so the button can animate back and the UI does not become unresponsive immediately
  double delayInSeconds = 0.1;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    [self showCameraAndExecute:^{
      [coverView removeFromSuperview];
    }];
  });
}

- (void)showCameraAndExecute:(void (^)())completionBlock
{
  UIImagePickerController *picker = [UIImagePickerController new];

  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
  {
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
  }
  else
  {
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  }
  
  picker.delegate = self;
  picker.mediaTypes = @[(NSString *)kUTTypeImage];
  
  [self presentViewController:picker animated:YES completion:completionBlock];
}

- (void)showModalControllerForTag:(SERContentTag)tag
{
  UIViewController *controller = nil;
  
  if (tag == SERContentTagInvite)
  {
    controller = [SERInviteViewController new];
  }
  else if (tag == SERContentTagWishlist)
  {
    controller = [SERWishlistViewController new];
  }
  
  NSAssert(controller, @"cound not figure out controller for tag: %ld", (long)tag);
  
  UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
  [self presentViewController:navigationController animated:YES completion:NULL];

  UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissPresentedController:)];
  [controller.navigationItem setLeftBarButtonItem:item];
}

- (SERContentViewController *)defaultContentController
{
  return [self marketController];
}

- (SERMarketViewController *)marketController
{
  if (!_marketController)
  {
    _marketController = [SERMarketViewController new];
    _marketController.tag = SERContentTagMarket;
  }
  
  return _marketController;
}

- (SERPostsViewController *)postsController
{
  if (!_postsController)
  {
    _postsController = [SERPostsViewController new];
    _postsController.tag = SERContentTagPosts;
  }
  
  return _postsController;
}

- (SERProfileViewController *)profileController
{
  if (!_profileController)
  {
    _profileController = [SERProfileViewController new];
    _profileController.tag = SERContentTagProfile;
  }
  
  return _profileController;
}

- (UIViewController *)viewControllerForContentController:(SERContentViewController *)contentController
{
  UIViewController *controller = contentController;
  
  // e.g.
  // if (contentController.tag == SERContentTagProfile)
  // {
  //   controller = [[UINavigationController alloc] initWithRootViewController:contentController];
  // }
  
  return controller;
}

#pragma mark SERDuratedMenuDelegate

- (void)menu:(SERDuratedMenu *)menu didSelectItem:(SERDuratedMenuItem *)item
{
  if (item.tag == SERContentTagCamera)
  {
    [self prepareToShowCamera];
  }
  else if (item.tag == SERContentTagInvite || item.tag == SERContentTagWishlist)
  {
    [self showModalControllerForTag:item.tag];
  }
  else
  {
    [self switchToControllerForTag:item.tag fromController:self.contentController];
  }
}

- (void)switchToControllerForTag:(SERContentTag)tag fromController:(SERContentViewController *)oldController
{
  SERContentViewController *newController = nil;
  if (tag == SERContentTagPosts)
  {
    newController = self.postsController;
  }
  else if (tag == SERContentTagProfile)
  {
    newController = self.profileController;
  }
  else if (tag == SERContentTagMarket)
  {
    newController = self.marketController;
  }
  
  NSAssert(oldController != newController, @"old and new controllers must be different: %@", newController);
  
  // TODO oh come on, this is too complex just to get the animation direction
  NSArray *order = @[@(SERContentTagMarket), @(SERContentTagPosts), @(SERContentTagProfile)];
  
  NSUInteger oldIndex = [order indexOfObject:@(oldController.tag)];
  NSUInteger newIndex = [order indexOfObject:@(newController.tag)];
  
  NSAssert(oldIndex != NSNotFound, @"old index not found");
  NSAssert(newIndex != NSNotFound, @"new index not found");
  
  NSInteger direction = (NSInteger)newIndex - (NSInteger)oldIndex;
  
  if (direction > 1)
  {
    direction -= [order count];
  }
  else if (direction < 1)
  {
    direction += [order count];
  }
  
  SERAnimation animation = direction == 1 ? SERAnimationRight : SERAnimationLeft;
  [self setContentController:newController animation:animation];
}

#pragma status bar

- (BOOL)prefersStatusBarHidden
{
  return YES;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
  return UIStatusBarStyleLightContent;
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
  [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark Helpers

- (void)dismissPresentedController:(id)sender
{
  [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
