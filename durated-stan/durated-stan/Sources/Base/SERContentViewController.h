//
//  SERContentViewController.h
//  durated-stan
//
//  Created by Stanley Rost on 11.01.14.
//  Copyright (c) 2014 Stanley Rost. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SERContentTag) {
  SERContentTagProfile,
  SERContentTagPosts,
  SERContentTagMarket,
  SERContentTagCamera,
  SERContentTagInvite,
  SERContentTagWishlist,
};

@interface SERContentViewController : UIViewController

@property (nonatomic) SERContentTag tag;

@end
