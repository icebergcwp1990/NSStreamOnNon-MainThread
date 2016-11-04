//
//  NSStreamOnNon_MainThreadTests.m
//  NSStreamOnNon-MainThreadTests
//
//  Created by Caowanping on 11/3/16.
//  Copyright (c) 2016 iceberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

@interface NSStreamOnNon_MainThreadTests : XCTestCase

@end

@implementation NSStreamOnNon_MainThreadTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
