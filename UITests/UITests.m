//
//  UITests.m
//  UITests
//
//  Created by Boris Chirino on 04/02/16.
//  Copyright © 2016 Boris Chirino. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface UITests : XCTestCase

@end

@implementation UITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// ======================================= IPHONE UI TEST

-(void)testUserNotFound{
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.navigationBars[@"Photos"].buttons[@"Search"] tap];
    
    XCUIElementQuery *collectionViewsQuery = app.alerts.collectionViews;
    [collectionViewsQuery.textFields[@"Flickr username"] typeText:@"12wse34t-3"];
    [collectionViewsQuery.buttons[@"Search"] tap];
    sleep(3);
    XCTAssertEqual(app.tables.cells.count, 0);
    
}

- (void)testUserBolek1976
{
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.navigationBars[@"Photos"].buttons[@"Search"] tap];
    
    XCUIElementQuery *collectionViewsQuery = app.alerts.collectionViews;
    [collectionViewsQuery.textFields[@"Flickr username"] typeText:@"bolek1976"];
    [collectionViewsQuery.buttons[@"Search"] tap];
    
    sleep(40);
    
    XCTAssertEqual(app.tables.cells.count, 18);
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

@end
