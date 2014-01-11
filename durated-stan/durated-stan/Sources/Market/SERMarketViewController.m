//
//  SERMarketViewController.m
//  durated-stan
//
//  Created by Stanley Rost on 11.01.14.
//  Copyright (c) 2014 Stanley Rost. All rights reserved.
//

#import "SERMarketViewController.h"

@interface SERMarketViewController ()

@end

@implementation SERMarketViewController

- (void)loadView
{
  UIImage *image = [UIImage imageNamed:@"mock-market.jpg"];
  UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
  imageView.contentMode = UIViewContentModeTopLeft;
  
  self.view = imageView;
}

@end
