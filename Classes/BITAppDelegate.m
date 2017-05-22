/*
 * Author: Andreas Linde <mail@andreaslinde.de>
 *
 * Copyright (c) 2012-2013 HockeyApp, Bit Stadium GmbH.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#import "BITAppDelegate.h"
#import "BITDemoViewController.h"
#import "HockeySDK.h"

//@import MobileCenter;
//@import MobileCenterAnalytics;
//@import MobileCenterDistribute;


@interface BITAppDelegate () <BITHockeyManagerDelegate> {}

@end


@implementation BITAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"5cced9fcfb54402fb3c3cb053327f0cf"
                                                         delegate:self];
  [BITHockeyManager sharedHockeyManager].authenticator.authenticationSecret = @"2565286864653912f3927ac63ea29e68";

  // optionally enable logging to get more information about states.
  [BITHockeyManager sharedHockeyManager].logLevel = BITLogLevelVerbose;

  [[BITHockeyManager sharedHockeyManager] startManager];

//  [MSMobileCenter setLogLevel:MSLogLevelVerbose];
//  [MSMobileCenter start:@"5d71ab11-d5ce-42c5-988e-fceda812b28c" withServices:@[[MSAnalytics class],[MSDistribute class]]];

  [self.window makeKeyAndVisible];

  if ([self didCrashInLastSessionOnStartup]) {
    [self waitingUI];
  } else {
    [self setupApplication];
  }

  return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  return [[BITHockeyManager sharedHockeyManager].authenticator handleOpenURL:url
                                                           sourceApplication:sourceApplication
                                                                  annotation:annotation];
}

- (void)waitingUI {
  // show intermediate UI
  [self.demoViewController.view addSubview:self.demoViewController.waitingView];
  [self.demoViewController.waitingView setHidden:NO];
  [self.demoViewController.navigationItem.leftBarButtonItem setEnabled:NO];
}

- (void)setupApplication {
  // setup your app specific code
  [self.demoViewController.waitingView setHidden:YES];
  [self.demoViewController.waitingView removeFromSuperview];
  [self.demoViewController.navigationItem.leftBarButtonItem setEnabled:YES];
  [self.window makeKeyAndVisible];
  [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
}

- (BOOL)didCrashInLastSessionOnStartup {
  return ([[BITHockeyManager sharedHockeyManager].crashManager didCrashInLastSession] &&
          [[BITHockeyManager sharedHockeyManager].crashManager timeIntervalCrashInLastSessionOccurred] < 5);
}


#pragma mark - BITHockeyManagerDelegate

//- (NSString *)userIDForHockeyManager:(BITHockeyManager *)hockeyManager componentManager:(BITHockeyBaseManager *)componentManager {
//  return @"userID";
//}

//- (NSString *)userNameForHockeyManager:(BITHockeyManager *)hockeyManager componentManager:(BITHockeyBaseManager *)componentManager {
//  return @"userName";
//}
//
//- (NSString *)userEmailForHockeyManager:(BITHockeyManager *)hockeyManager componentManager:(BITHockeyBaseManager *)componentManager {
//  return @"userEmail";
//}

#pragma mark - BITCrashManagerDelegate

- (NSString *)applicationLogForCrashManager:(BITCrashManager *)crashManager {
  return @"applicationLog";
}

//- (BITHockeyAttachment *)attachmentForCrashManager:(BITCrashManager *)crashManager {
//  NSURL *url = [[NSBundle mainBundle] URLForResource:@"Default-568h@2x" withExtension:@"png"];
//  NSData *data = [NSData dataWithContentsOfURL:url];
//  
//  BITCrashAttachment *attachment = [[BITCrashAttachment alloc] initWithFilename:@"image.png"
//                                                            crashAttachmentData:data
//                                                                    contentType:@"image/png"];
//  return attachment;
//}

- (void)crashManagerWillCancelSendingCrashReport:(BITCrashManager *)crashManager {
  if ([self didCrashInLastSessionOnStartup]) {
    [self setupApplication];
  }
}

- (void)crashManager:(BITCrashManager *)crashManager didFailWithError:(NSError *)error {
  if ([self didCrashInLastSessionOnStartup]) {
    [self setupApplication];
  }
}
       
- (void)crashManagerDidFinishSendingCrashReport:(BITCrashManager *)crashManager {
  if ([self didCrashInLastSessionOnStartup]) {
    [self setupApplication];
  }
}

@end
