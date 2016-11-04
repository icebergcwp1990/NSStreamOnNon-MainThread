//
//  StreamHelper.h
//  NSStreamOnNon-MainThread
//
//  Created by Caowanping on 11/3/16.
//  Copyright (c) 2016 iceberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StreamHelper : NSObject

+ (instancetype)sharedInstance;

- (void)createStreamWithHost:(NSString * )host port:(UInt32)port;

@end
