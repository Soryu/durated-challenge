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

static const CGFloat kButtonBottomMargin = 20;
static const CGFloat kAnimationDuration = 0.25;

typedef NS_ENUM(NSInteger, SERAnimation) {
  SERAnimationNone,
  SERAnimationLeft,
  SERAnimationRight,
};

@interface SERBaseViewController ()

// UI

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *menuButton;

// Actions

- (void)menuButtonPressed:(id)sender;

// Content

@property (nonatomic, strong) UIViewController         *currentController;
@property (nonatomic, strong) UIViewController         *contentController;
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
  
  [self.view addSubview:self.menuButton];

#warning DEBUG colored backgrounds for debugging
  self.view.backgroundColor = [UIColor redColor];
  self.contentView.backgroundColor = [UIColor greenColor];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self setContentController:self.defaultContentController animation:SERAnimationNone];
}

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];
  
  self.menuButton.center = ({
    CGRect frame      = self.menuButton.frame;
    CGRect superFrame = self.menuButton.superview.frame;

    CGPoint center;
    center.x = CGRectGetMidX(superFrame);
    center.y = CGRectGetHeight(superFrame) - CGRectGetHeight(frame) / 2 - kButtonBottomMargin;
    center;
  });
}


#pragma mark UI

- (UIButton *)menuButton
{
  if (!_menuButton)
  {
    _menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_menuButton setImage:[UIImage imageNamed:@"durated-button"] forState:UIControlStateNormal];
    [_menuButton sizeToFit];
    
    [_menuButton addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  }
  
  return _menuButton;
}


#pragma mark Actions

- (void)menuButtonPressed:(id)sender
{
  // NOTE test code just to have something working
  UIViewController *newController = nil;
  
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

- (void)setContentController:(UIViewController *)newController animation:(SERAnimation)animation
{
  UIViewController *contentController = newController;
  if ([newController respondsToSelector:@selector(topViewController)])
    contentController = [newController performSelector:@selector(topViewController)];
  
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
  
}

- (UIViewController *)defaultContentController
{
  return [self marketController];
}

- (SERMarketViewController *)marketController
{
  if (!_marketController)
  {
    _marketController = [SERMarketViewController new];
  }
  
  return _marketController;
}

- (SERPostsViewController *)postsController
{
  if (!_postsController)
  {
    _postsController = [SERPostsViewController new];
  }
  
  return _postsController;
}

- (SERProfileViewController *)profileController
{
  if (!_profileController)
  {
    _profileController = [SERProfileViewController new];
  }
  
  return _profileController;
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
