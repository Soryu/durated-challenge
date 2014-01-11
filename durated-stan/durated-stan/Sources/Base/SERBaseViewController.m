//
//  SERBaseViewController.m
//  durated-stan
//
//  Created by Stanley Rost on 11.01.14.
//  Copyright (c) 2014 Stanley Rost. All rights reserved.
//

#import "SERBaseViewController.h"
#import "SERMarketViewController.h"
#import "SERPostsViewController.h"
#import "SERProfileViewController.h"
#import "SERDuratedMenu.h"
#import "SERDuratedMenuItem.h"
#import "SERContentViewController.h"

static const CGFloat kAnimationDuration = 0.25;

typedef NS_ENUM(NSInteger, SERAnimation) {
  SERAnimationNone,
  SERAnimationLeft,
  SERAnimationRight,
};

@interface SERBaseViewController () <SERDuratedMenuDelegate>

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

#warning DEBUG colored backgrounds for debugging
  self.view.backgroundColor = [UIColor redColor];
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
    _menu.items = @[
      [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"profile"] tag:SERMenuTagProfile],
      // [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"market"] tag:SERMenuTagMarket],
      [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"invite"] tag:SERMenuTagInvite],
      [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"camera"] tag:SERMenuTagCamera],
      [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"wishlist"] tag:SERMenuTagWishlist],
      [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"posts"] tag:SERMenuTagPosts],
    ];
    
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
  
  DLog(@"switching to %@", newController);
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
  
  if (contentController.tag == SERMenuTagMarket)
  {
    self.menu.items = @[
      [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"profile"]  tag:SERMenuTagProfile],
      [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"invite"]   tag:SERMenuTagInvite],
      [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"camera"]   tag:SERMenuTagCamera],
      [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"wishlist"] tag:SERMenuTagWishlist],
      [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"posts"]    tag:SERMenuTagPosts],
    ];    
  }
  else if (contentController.tag == SERMenuTagProfile)
  {
    self.menu.items = @[
      [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"posts"]    tag:SERMenuTagPosts],
      [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"invite"]   tag:SERMenuTagInvite],
      [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"camera"]   tag:SERMenuTagCamera],
      [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"wishlist"] tag:SERMenuTagWishlist],
      [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"market"]   tag:SERMenuTagMarket],
    ];    
  }
  else if (contentController.tag == SERMenuTagPosts)
  {
    self.menu.items = @[
      [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"market"]   tag:SERMenuTagMarket],
      [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"invite"]   tag:SERMenuTagInvite],
      [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"camera"]   tag:SERMenuTagCamera],
      [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"wishlist"] tag:SERMenuTagWishlist],
      [[SERDuratedMenuItem alloc] initWithImage:[UIImage imageNamed:@"profile"]  tag:SERMenuTagProfile],
    ];    
  }  
}

- (void)showCamera
{
  DLog(@".");
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
    _marketController.tag = SERMenuTagMarket;
  }
  
  return _marketController;
}

- (SERPostsViewController *)postsController
{
  if (!_postsController)
  {
    _postsController = [SERPostsViewController new];
    _postsController.tag = SERMenuTagPosts;
  }
  
  return _postsController;
}

- (SERProfileViewController *)profileController
{
  if (!_profileController)
  {
    _profileController = [SERProfileViewController new];
    _profileController.tag = SERMenuTagProfile;
  }
  
  return _profileController;
}

- (UIViewController *)viewControllerForContentController:(SERContentViewController *)contentController
{
  UIViewController *controller = contentController;
  
  // e.g.
  // if (contentController.tag == SERMenuTagProfile)
  // {
  //   controller = [[UINavigationController alloc] initWithRootViewController:contentController];
  // }
  
  return controller;
}

#pragma mark SERDuratedMenuDelegate

- (void)menu:(SERDuratedMenu *)menu didSelectItem:(SERDuratedMenuItem *)item
{
  DLog(@"%d %@", item.tag, item);
  
  if (item.tag == SERMenuTagCamera)
  {
    [self showCamera];
  }
  else if (item.tag == SERMenuTagInvite)
  {
    // TODO invite
  }
  else if (item.tag == SERMenuTagWishlist)
  {
    // TODO wishlist
  }
  else
  {
    [self switchToControllerForTag:item.tag fromController:self.contentController];
  }
}

- (void)switchToControllerForTag:(SERMenuTag)tag fromController:(SERContentViewController *)oldController
{
  SERContentViewController *newController = nil;
  if (tag == SERMenuTagPosts)
  {
    newController = self.postsController;
  }
  else if (tag == SERMenuTagProfile)
  {
    newController = self.profileController;
  }
  else if (tag == SERMenuTagMarket)
  {
    newController = self.marketController;
  }
  
  NSAssert(oldController != newController, @"old and new controllers must be different: %@", newController);
  
  // TODO oh come on, this is too complex just to get the animation direction
  NSArray *order = @[@(SERMenuTagMarket), @(SERMenuTagPosts), @(SERMenuTagProfile)];
  
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

@end
