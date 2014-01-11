//
//  SERContentViewController.h
//  durated-stan
//
//  Created by Stanley Rost on 11.01.14.
//  Copyright (c) 2014 Stanley Rost. All rights reserved.
//

#import <UIKit/UIKit.h>

// FIXME rename to content tag or such
typedef NS_ENUM(NSInteger, SERMenuTag) {
  SERMenuTagProfile,
  SERMenuTagPosts,
  SERMenuTagMarket,
  SERMenuTagCamera,
  SERMenuTagInvite,
  SERMenuTagWishlist,
};

@interface SERContentViewController : UIViewController

@property (nonatomic) SERMenuTag tag;

@end
