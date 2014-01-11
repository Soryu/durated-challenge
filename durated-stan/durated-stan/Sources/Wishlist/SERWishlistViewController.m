//
//  SERWishlistViewController.m
//  durated-stan
//
//  Created by Stanley Rost on 11.01.14.
//  Copyright (c) 2014 Stanley Rost. All rights reserved.
//

#import "SERWishlistViewController.h"
#import "UIColor+SER.h"

@implementation SERWishlistViewController

- (id)init
{
  self = [super init];
  
  if (self)
  {
    self.title = NSLocalizedString(@"Wishlist", nil);
  }
  
  return self;
}

- (void)loadView
{
  self.view = [UIView new];
  self.view.backgroundColor = [UIColor brandColor];
}

@end
