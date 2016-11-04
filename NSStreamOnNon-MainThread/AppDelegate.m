//
//  AppDelegate.m
//  NSStreamOnNon-MainThread
//
//  Created by Caowanping on 11/3/16.
//  Copyright (c) 2016 iceberg. All rights reserved.
//

#import "AppDelegate.h"
#import "StreamHelper.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    NSString * serverURL = @"www.serverIP.com";
    NSString * serverPort = @"1234";
    
    StreamHelper * streamHelper = [StreamHelper sharedInstance];
    
    [streamHelper createStreamWithHost:serverURL port:serverPort];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
