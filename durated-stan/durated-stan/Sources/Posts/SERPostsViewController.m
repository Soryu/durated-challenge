//
//  SERPostsViewController.m
//  durated-stan
//
//  Created by Stanley Rost on 11.01.14.
//  Copyright (c) 2014 Stanley Rost. All rights reserved.
//

#import "SERPostsViewController.h"

@interface SERPostsViewController ()

@end

@implementation SERPostsViewController

- (void)loadView
{
  UIImage *image = [UIImage imageNamed:@"mock-posts.png"];
  UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
  imageView.contentMode = UIViewContentModeTopLeft;
  
  self.view = imageView;
}

@end
