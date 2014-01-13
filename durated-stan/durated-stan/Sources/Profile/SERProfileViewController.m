//
//  SERProfileViewController.m
//  durated-stan
//
//  Created by Stanley Rost on 11.01.14.
//  Copyright (c) 2014 Stanley Rost. All rights reserved.
//

#import "SERProfileViewController.h"

@interface SERProfileViewController ()

@end

@implementation SERProfileViewController

- (void)loadView
{
  UIImage *image = [UIImage imageNamed:@"mock-profile.jpg"];
  UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
  imageView.contentMode = UIViewContentModeTopLeft;
  
  self.view = imageView;
}

@end
