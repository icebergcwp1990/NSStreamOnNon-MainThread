//
//  StreamHelper.m
//  NSStreamOnNon-MainThread
//
//  Created by Caowanping on 11/3/16.
//  Copyright (c) 2016 iceberg. All rights reserved.
//

#import "StreamHelper.h"

@interface StreamHelper ()<NSStreamDelegate>

@property (strong, nonatomic) NSInputStream* rawInputStream;
@property (strong, nonatomic) NSOutputStream* rawOutputStream;

@property (assign, nonatomic) BOOL readStreamIsConnected;
@property (assign, nonatomic) BOOL writeStreamIsConnected;

@end

@implementation StreamHelper

#pragma mark - SharedInstance

//单例模式
+ (instancetype)sharedInstance
{
    static StreamHelper * gStreamHepler = nil;
    
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        
        if (!gStreamHepler) {
            gStreamHepler = [StreamHelper new];
        }
        
    });
    
    return gStreamHepler;
    
}

#pragma mark - Ctreate&Init Stream

//链接指定端口的服务器
- (void)createStreamWithHost:(NSString * )host port:(UInt32)port
{
    assert(host != nil);
    assert( (port > 0) && (port < 65536) );
    
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL,
                                       (__bridge CFStringRef)host,
                                       port,
                                       &readStream,
                                       &writeStream);
    
    assert( (readStream != NULL) || (writeStream != NULL) );
    
    NSDictionary *sslSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                 (id)kCFBooleanFalse, kCFStreamSSLValidatesCertificateChain,
                                 NSStreamSocketSecurityLevelSSLv3, NSStreamSocketSecurityLevelKey,
                                 nil];
    
    CFReadStreamSetProperty(readStream,
                            kCFStreamPropertySSLSettings,
                            (__bridge CFTypeRef)(sslSettings));
    
    //__bridge_transfer将CF对象的内存控制权完全转接过来，CF对象不需要再手动释放
    self.rawInputStream = (__bridge_transfer NSInputStream *)readStream;
    self.rawOutputStream = (__bridge_transfer NSOutputStream *)writeStream;
    
    [self.rawInputStream setDelegate:self];
    [self.rawOutputStream setDelegate:self];
    
    //部署在主线程的RunLoop中
    /*
    [self.rawInputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.rawOutputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
     */
    
    //部署在子线程的RunLoop中
    [self performSelector:@selector(scheduleInCurrentThread)
                 onThread:[[self class] networkThread]
               withObject:nil
            waitUntilDone:YES];
    
    [self.rawInputStream open];
    [self.rawOutputStream open];
}

//清理操作
- (void)clearUpStream
{
    [self.rawInputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.rawOutputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.rawInputStream close];
    [self.rawOutputStream close];
    
    self.rawInputStream = nil;
    self.rawOutputStream = nil;
}

+ (NSThread *)networkThread
{
    static NSThread *networkThread = nil;
    static dispatch_once_t oncePredicate;
    
    //创建子线程，保证单例
    dispatch_once(&oncePredicate, ^{
        networkThread =
        [[NSThread alloc] initWithTarget:self
                                selector:@selector(networkThreadMain:)
                                  object:nil];
        [networkThread start];
    });
    
    return networkThread;
}

+ (void)networkThreadMain:(id)unused {
    
    //类似主线程的死循环，保证子线程的RunLoop休眠后能被唤醒
    do {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] run];
        }
    } while (YES);
}

- (void)scheduleInCurrentThread
{
    //部署到子线程的RunLoop中
    [self.rawInputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                   forMode:NSRunLoopCommonModes];
    
    [self.rawOutputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                    forMode:NSRunLoopCommonModes];
}

#pragma mark NSStreamDelegate

//NSStream 代理函数
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    
    switch (eventCode)
    {
        case NSStreamEventNone:
        {
            break;
        }
        case NSStreamEventEndEncountered:
        {
            [self clearUpStream];
            
            break;
        }
        case NSStreamEventErrorOccurred:
        {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"Failed to open stream" forKey:NSLocalizedDescriptionKey];
            NSError* error = [NSError errorWithDomain:@"stream" code:eventCode userInfo:details];
            NSLog(@"%@" , error);
            
            [self clearUpStream];
            
            break;
        }
        case NSStreamEventHasBytesAvailable:
        {
            const int kBufferSize = 1024 *4;
            
            uint8_t buf[kBufferSize];
            
            NSInteger numBytesRead = [(NSInputStream *)stream read:buf maxLength:kBufferSize];
            
            if (numBytesRead > 0)
            {
                NSData * data = [NSData dataWithBytes:buf length:numBytesRead];
                
                NSLog(@"Length of read data: %ld" , [data length]);
                
            } else if (numBytesRead == 0) {
                
                NSLog(@" >> End of stream reached");
                
            } else {
                
                NSLog(@" >> Read error occurred");
            }
            
            break;
        }
        case NSStreamEventHasSpaceAvailable:
        {
            break;
        }
        case NSStreamEventOpenCompleted:
        {
            if ([stream isKindOfClass:[NSInputStream class]]) {
                self.readStreamIsConnected = YES;
            } else if ([stream isKindOfClass:[NSOutputStream class]]) {
                self.writeStreamIsConnected = YES;
            }
            
            break;
        }
    }
}

@end
