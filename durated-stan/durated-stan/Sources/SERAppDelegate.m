//
//  SERAppDelegate.m
//  durated-stan
//
//  Created by Stanley Rost on 11.01.14.
//  Copyright (c) 2014 Stanley Rost. All rights reserved.
//

#import "SERAppDelegate.h"
#import "SERBaseViewController.h"

@interface SERAppDelegate ()

@property (nonatomic, strong) SERBaseViewController *baseController;

@end

@implementation SERAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  self.baseController = [SERBaseViewController new];
  self.window.rootViewController = self.baseController;
  
  self.window.backgroundColor = [UIColor whiteColor];
  [self.window makeKeyAndVisible];
  return YES;
}

@end
